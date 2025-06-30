package rules

import (
	"encoding/json"
	"fmt"
	"github.com/go-git/go-git/v5/plumbing"
	"github.com/sirupsen/logrus"
	"main/internal/cmd/rules/types"
	"main/internal/config"
	"main/internal/git"
	"main/internal/jsonnet"
	mainTypes "main/internal/types"
	"main/internal/util"
	"os"
	"path/filepath"
)

// prepareGitRules uses jsonnet to build Git sourced rules to prepare for output
func prepareGitRules(ctx *config.AppContext, currentState *types.ChartState, chart *mainTypes.RulesGitSource) error {
	if chart.Source == "" {
		chart.Source = "_mixin.jsonnet"
	}
	tempDir := ctx.GetTmpDir()

	url := chart.Repository.RepoURL
	clonePath := filepath.Join(tempDir, chart.Repository.Name)

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

	logrus.Infof("Cloning %s to %s", chart.Repository.RepoURL, clonePath)
	util.CheckErr(git.ShallowClone(configParams, clonePath))

	if chart.Mixin != "" {
		currentState.Cwd = tempDir

		sourceCwd := chart.Cwd
		mixinFile := chart.Source

		mixinDir := filepath.Join(clonePath, sourceCwd)
		currentState.MixinDir = mixinDir
		util.CheckErr(jsonnet.InitJsonnetBuilder(mixinDir))

		// TODO: this is where python checks for content field in charts
		// It seems as though it is an override mechanism that may be unused currently

		logrus.Infof("Generatring rules from %s", mixinFile)
		vm := jsonnet.NewVm(currentState.MixinDir)
		renderedJson, err := vm.EvaluateAnonymousSnippet(
			mixinFile,
			chart.Mixin,
		)
		if err != nil {
			return err
		}

		var alerts types.Alerts
		util.CheckErr(json.Unmarshal([]byte(renderedJson), &alerts))

		currentState.Alerts = alerts
		currentState.Url = url
	} else {
		sourcePath := filepath.Join(tempDir, chart.Source)
		sourceContent := util.Must(os.ReadFile(sourcePath))
		currentState.RawText = string(sourceContent)
		fmt.Println(currentState.RawText)

		var alerts types.Alerts
		util.CheckErr(json.Unmarshal(sourceContent, &alerts))
		currentState.Alerts = alerts
	}

	return nil
}
