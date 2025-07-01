package types

import (
	"encoding/json"
	"errors"
	"main/internal/config"
	"main/internal/git"
	"path/filepath"
)

type DashboardType int

const (
	DashboardJson DashboardType = iota
	DashboardYaml
	DashboardKubernetesYaml
	DashboardJsonnetMixin
)

var dashboardTypeName = map[DashboardType]string{
	DashboardJson:           "dashboard_json",
	DashboardKubernetesYaml: "yaml",
	DashboardYaml:           "yaml",
	DashboardJsonnetMixin:   "jsonnet_mixin",
}

func MaybeDashboardType(maybeDashboard string) (*DashboardType, error) {
	for typeName, typeString := range dashboardTypeName {
		if maybeDashboard == typeString {
			return &typeName, nil
		}
	}
	return nil, errors.New("unknown dashboard type")
}

func (dt *DashboardType) String() string {
	return dashboardTypeName[*dt]
}

func (dt *DashboardType) UnmarshalJSON(b []byte) error {
	var s string
	if err := json.Unmarshal(b, &s); err != nil {
		return err
	}
	maybeDash, err := MaybeDashboardType(s)
	if err != nil {
		return err
	}
	*dt = *maybeDash

	return nil
}

func (dt *DashboardType) MarshalJSON() ([]byte, error) {
	s := dt.String()
	return json.Marshal(s)
}

type KubernetesVersions interface {
	GetMinKubernetes() string
	GetMaxKubernetes() string
	SetMaxKubernetes(string)
}

func SetDefaultMaxK8s(kv KubernetesVersions) KubernetesVersions {
	if kv.GetMaxKubernetes() == "" {
		// Equal to: https://github.com/prometheus-community/helm-charts/blob/0b60795bb66a21cd368b657f0665d67de3e49da9/charts/kube-prometheus-stack/hack/sync_grafana_dashboards.py#L326
		kv.SetMaxKubernetes("9.9.9-9")
	}

	return kv
}

type DashboardSource interface {
	GetDestination() string
	GetMinKubernetes() string
	GetMaxKubernetes() string
	SetMaxKubernetes(string)
	GetMulticlusterKey() string
	GetType() DashboardType
}

type DashboardSourceBase struct {
	Destination     string        `json:"destination"`
	Type            DashboardType `json:"type"`
	MinKubernetes   string        `json:"min_kubernetes"`
	MaxKubernetes   string        `json:"max_kubernetes,omitempty"`
	MulticlusterKey string        `json:"multicluster_key"`
}

func (ds *DashboardSourceBase) GetDestination() string {
	chartBaseDir := config.GetContext().ChartRootDir
	return filepath.Join(chartBaseDir, ds.Destination)
}

// DashboardFileSource represents a dashboard sourced from a local file.
// In Original, this was the final else condition that simply loads source as a file
type DashboardFileSource struct {
	Source string `json:"source"`
	DashboardSourceBase
}

func (dfs *DashboardFileSource) GetDestination() string {
	return dfs.DashboardSourceBase.GetDestination()
}

func (dfs *DashboardFileSource) GetMinKubernetes() string {
	return dfs.DashboardSourceBase.MinKubernetes
}

func (dfs *DashboardFileSource) GetMaxKubernetes() string {
	return dfs.DashboardSourceBase.MaxKubernetes
}

func (dfs *DashboardFileSource) SetMaxKubernetes(s string) {
	dfs.DashboardSourceBase.MaxKubernetes = s
}

func (dfs *DashboardFileSource) GetMulticlusterKey() string {
	return dfs.DashboardSourceBase.MulticlusterKey
}

func (dfs *DashboardFileSource) GetType() DashboardType {
	return dfs.DashboardSourceBase.Type
}

var _ DashboardSource = &DashboardFileSource{}

// DashboardURLSource represents a dashboard sourced from a remote URL.
// In Original, this is for when source filed starts with http
type DashboardURLSource struct {
	Source string `json:"source"`
	DashboardSourceBase
}

func (dus *DashboardURLSource) GetDestination() string {
	return dus.DashboardSourceBase.GetDestination()
}

func (dus *DashboardURLSource) GetMinKubernetes() string {
	return dus.DashboardSourceBase.MinKubernetes
}

func (dus *DashboardURLSource) GetMaxKubernetes() string {
	return dus.DashboardSourceBase.MaxKubernetes
}

func (dus *DashboardURLSource) SetMaxKubernetes(s string) {
	dus.DashboardSourceBase.MaxKubernetes = s
}

func (dus *DashboardURLSource) GetMulticlusterKey() string {
	return dus.DashboardSourceBase.MulticlusterKey
}

func (dus *DashboardURLSource) GetType() DashboardType {
	return dus.DashboardSourceBase.Type
}

var _ DashboardSource = &DashboardURLSource{}

// DashboardGitSource represents a dashboard source pulling from git
// In Original, these are when chart has `git` field
type DashboardGitSource struct {
	Repository git.RepoConfig `json:"repository,omitempty"`
	Content    string         `json:"content,omitempty"`
	Cwd        string         `json:"cwd,omitempty"`
	Source     string         `json:"source,omitempty"` // For specific file in the repo
	DashboardSourceBase
	MixinVars map[string]interface{} `json:"mixin_vars,omitempty"` // For Jsonnet mixin variables
}

func (dgs *DashboardGitSource) GetDestination() string {
	return dgs.DashboardSourceBase.GetDestination()
}

func (dgs *DashboardGitSource) GetMinKubernetes() string {
	return dgs.DashboardSourceBase.MinKubernetes
}

func (dgs *DashboardGitSource) GetMaxKubernetes() string {
	return dgs.DashboardSourceBase.MaxKubernetes
}

func (dgs *DashboardGitSource) SetMaxKubernetes(s string) {
	dgs.DashboardSourceBase.MaxKubernetes = s
}

func (dgs *DashboardGitSource) GetMulticlusterKey() string {
	return dgs.DashboardSourceBase.MulticlusterKey
}

func (dgs *DashboardGitSource) GetType() DashboardType {
	return dgs.DashboardSourceBase.Type
}

var _ DashboardSource = &DashboardGitSource{}

// DashboardsConfig is a slice that can hold any of the specific dashboard source types.
type DashboardsConfig []interface{}
