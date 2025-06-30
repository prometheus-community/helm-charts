package types

type ChartState struct {
	Cwd      string
	MixinDir string
	RawText  string
	Alerts   Alerts
	Source   string
	Url      string
}

type Alerts struct {
	Groups []AlertGroup `json:"groups"`
}

type AlertGroup struct {
	Interval string    `json:"interval,omitempty" yaml:"interval,omitempty"`
	Name     string    `json:"name" yaml:"name"`
	Rules    PromRules `json:"rules" yaml:"rules"`
}

type PromRules []PromRule

type PromRule struct {
	Alert       string            `json:"alert,omitempty" yaml:"alert,omitempty"`
	Annotations map[string]string `json:"annotations,omitempty" yaml:"annotations,omitempty"`
	Expr        string            `json:"expr" yaml:"expr"`
	For         string            `json:"for,omitempty" yaml:"for,omitempty"`
	Labels      map[string]string `json:"labels,omitempty" yaml:"labels,omitempty"`
	Record      string            `json:"record,omitempty" yaml:"record,omitempty"`
}
