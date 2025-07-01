package git

import (
	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing"
)

func ShallowClone(config RepoConfig, destDir string) error {
	cloneOptions := git.CloneOptions{
		URL:               config.RepoURL,
		Depth:             1,
		RecurseSubmodules: git.NoRecurseSubmodules,
		Progress:          nil,
		ReferenceName:     plumbing.NewBranchReferenceName(config.Branch),
		SingleBranch:      true,
	}

	_, err := git.PlainClone(destDir, false, &cloneOptions)

	return err
}
