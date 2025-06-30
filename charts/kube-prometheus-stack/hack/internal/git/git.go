package git

import (
	"fmt"
	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/config"
	"github.com/go-git/go-git/v5/plumbing"
	"gopkg.in/yaml.v3"
)

type RepoConfig struct {
	Name        string `yaml:"name"`
	RepoURL     string `yaml:"repo_url"`
	Branch      string `yaml:"branch"`
	HeadSha     string `yaml:"head_sha"`
	headShaHash plumbing.Hash
}

func (rc *RepoConfig) HeadHash() plumbing.Hash {
	return rc.headShaHash
}

func (rc *RepoConfig) SetHeadFromHash(headHash plumbing.Hash) {
	rc.headShaHash = headHash
	rc.HeadSha = headHash.String()
}

func (rc *RepoConfig) UnmarshalYAML(value *yaml.Node) error {
	// Create a shadow type to avoid recursion
	type raw RepoConfig
	var aux raw
	if err := value.Decode(&aux); err != nil {
		return err
	}
	*rc = RepoConfig(aux)
	rc.headShaHash = plumbing.NewHash(rc.HeadSha)
	return nil
}

func (rc RepoConfig) MarshalYAML() (interface{}, error) {
	return struct {
		Name    string `yaml:"name"`
		RepoURL string `yaml:"repo_url"`
		Branch  string `yaml:"branch"`
		HeadSha string `yaml:"head_sha"`
	}{
		Name:    rc.Name,
		RepoURL: rc.RepoURL,
		Branch:  rc.Branch,
		HeadSha: rc.headShaHash.String(),
	}, nil
}

func FindRepoHeadSha(repoUrl string) (plumbing.Hash, error) {
	remote := git.NewRemote(nil, &config.RemoteConfig{
		Name: "origin",
		URLs: []string{repoUrl},
	})
	refs, err := remote.List(&git.ListOptions{})
	if err != nil {
		return plumbing.ZeroHash, err
	}

	var headTarget *plumbing.ReferenceName
	for _, ref := range refs {
		if ref.Name() == plumbing.HEAD {
			target := ref.Target()
			headTarget = &target
			break
		}
	}

	if headTarget == nil {
		return plumbing.ZeroHash, fmt.Errorf("HEAD reference not found")
	}

	// Now find the actual reference it points to (the default branch's tip)
	for _, ref := range refs {
		if ref.Name() == *headTarget {
			return ref.Hash(), nil
		}
	}

	return plumbing.ZeroHash, fmt.Errorf("could not resolve HEAD target %s", *headTarget)
}

func FindBranchHead(repoUrl string, branch string) (plumbing.Hash, error) {
	// Check if the branch is already a valid SHA
	if plumbing.IsHash(branch) {
		return plumbing.NewHash(branch), nil
	}

	remote := git.NewRemote(nil, &config.RemoteConfig{
		Name: "origin",
		URLs: []string{repoUrl},
	})
	refs, err := remote.List(&git.ListOptions{
		Timeout: 30,
	})
	if err != nil {
		return plumbing.ZeroHash, fmt.Errorf("failed to list remote refs: %v", err)
	}

	branchRef := plumbing.NewBranchReferenceName(branch)

	for _, ref := range refs {
		refName := ref.Name()
		if refName == branchRef {
			return ref.Hash(), nil
		}
	}

	return plumbing.ZeroHash, fmt.Errorf("branch %s not found in remote", branch)
}
