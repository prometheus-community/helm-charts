package dashboards

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"

	"github.com/go-git/go-git/v5/plumbing"
	"github.com/sirupsen/logrus"

	"main/internal/config"
	"main/internal/git"
	"main/internal/jsonnet"
	"main/internal/log"
	"main/internal/types"
)

func prepareGitDashboard(ctx *config.AppContext, currentState *chartState, chart *types.DashboardGitSource) error {
	if chart.Source == "" {
		chart.Source = "_mixin.jsonnet"
	}
	tempDir := ctx.GetTmpDir()

	url := chart.Repository.RepoURL
	baseName := filepath.Base(url)
	clonePath := filepath.Join(tempDir, baseName)

	// Remove the clonePath if it exists from previous runs...
	_ = os.RemoveAll(clonePath)

	branch := "main"
	if chart.Repository.Branch != "" {
		branch = chart.Repository.Branch
	}
	branchHead := chart.Repository.HeadHash()
	if branchHead == plumbing.ZeroHash {
		var headErr error
		branchHead, headErr = git.FindBranchHead(chart.Repository.RepoURL, branch)
		if headErr != nil {
			return headErr
		}
	}

	configParams := git.RepoConfig{
		Name:    chart.Repository.Name,
		RepoURL: chart.Repository.RepoURL,
		Branch:  branch,
	}
	configParams.SetHeadFromHash(branchHead)
	log.Log.Infof("Cloning %s to %s", chart.Repository.RepoURL, clonePath)
	cloneErr := git.ShallowClone(configParams, clonePath)
	if cloneErr != nil {
		return cloneErr
	}

	mixinFile := chart.Source
	mixinDir := fmt.Sprintf("%s/%s/", clonePath, chart.Cwd)
	currentState.mixinDir = mixinDir
	jbErr := jsonnet.InitJsonnetBuilder(mixinDir)
	if jbErr != nil {
		return jbErr
	}

	filePath := filepath.Join(mixinDir, mixinFile)
	if chart.Content != "" {
		file, err := os.Create(filePath)
		if err != nil {
			return err
		}
		defer file.Close() // Ensure the file is closed when the function exits
		_, err = file.WriteString(chart.Content)
		if err != nil {
			logrus.Errorf("Error writing to file %s: %v\n", filePath, err)
			return err
		}
	}

	mixinVarsJSON, err := json.Marshal(chart.MixinVars)
	if err != nil {
		logrus.Errorf("Error encoding mixin_vars to JSON: %v\n", err)
		return err
	}

	currentState.url = url
	currentState.cwd = tempDir
	currentState.rawText = fmt.Sprintf("((import \"%s\") + %s)", mixinFile, mixinVarsJSON)
	currentState.source = filepath.Base(mixinFile)
	return nil
}
