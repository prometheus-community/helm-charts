package types

import (
	"main/internal/config"
	"main/internal/git"
	"path/filepath"
)

type RulesGitSource struct {
	Repository    git.RepoConfig `json:"repository"`
	Source        string         `json:"source,omitempty"`
	Cwd           string         `json:"cwd,omitempty"`
	Destination   string         `json:"destination,omitempty"`
	MinKubernetes string         `json:"min_kubernetes,omitempty"`
	MaxKubernetes string         `json:"max_kubernetes,omitempty"`
	Mixin         string         `json:"mixin,omitempty"`
}

var _ KubernetesVersions = &RulesGitSource{}

func (r *RulesGitSource) GetMinKubernetes() string {
	return r.MinKubernetes
}

func (r *RulesGitSource) GetMaxKubernetes() string {
	return r.MaxKubernetes
}

func (r *RulesGitSource) SetMaxKubernetes(s string) {
	r.MaxKubernetes = s
}

type RulesSource interface {
	GetDestination() string
	GetMinKubernetes() string
	GetMaxKubernetes() string
	SetMaxKubernetes(string)
}

var _ RulesSource = &RulesGitSource{}

func (r *RulesGitSource) GetDestination() string {
	chartBaseDir := config.GetContext().ChartRootDir
	return filepath.Join(chartBaseDir, r.Destination)
}

type RulesConfigs []RulesSource
