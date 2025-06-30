package config

import (
	"os"
	"path/filepath"

	"gopkg.in/yaml.v3"

	"main/internal/git"
	"main/internal/util"
)

var Repos = map[string]git.RepoConfig{
	"etcd": {
		Name:    "etcd",
		RepoURL: "https://github.com/etcd-io/etcd.git",
		Branch:  "main",
	},
	"kube-prometheus": {
		Name:    "kube-prometheus",
		RepoURL: "https://github.com/prometheus-operator/kube-prometheus.git",
		Branch:  "main",
	},
	"kubernetes-mixin": {
		Name:    "kubernetes-mixin",
		RepoURL: "https://github.com/kubernetes-monitoring/kubernetes-mixin.git",
		Branch:  "master",
	},
}

func UpdateRepoRefsConfig(configRoot string) error {
	// First populate the head SHA
	for key, repoConfig := range Repos {
		if repoConfig.HeadSha != "" {
			continue
		}
		headSha := util.Must(git.FindRepoHeadSha(repoConfig.RepoURL))
		repoConfig.SetHeadFromHash(headSha)
		Repos[key] = repoConfig
	}

	preparedRefs := make(map[string]git.RepoConfig)
	for _, repoConfig := range Repos {
		preparedRefs[repoConfig.Name] = repoConfig
	}

	yamlBytes := util.Must(yaml.Marshal(preparedRefs))
	configFilepath := filepath.Join(configRoot, "refs.yaml")

	return os.WriteFile(configFilepath, yamlBytes, 0644)
}

func LoadRepoRefsConfig(configRoot string) error {
	configFilepath := filepath.Join(configRoot, "refs.yaml")
	fileData := util.Must(os.ReadFile(configFilepath))

	var refs map[string]git.RepoConfig
	util.CheckErr(yaml.Unmarshal(fileData, &refs))

	for name, repoConfig := range Repos {
		repoConfig.HeadSha = refs[name].HeadSha
		Repos[name] = repoConfig
	}

	return nil
}
