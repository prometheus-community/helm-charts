package types

type DashboardReplacementRule struct {
	Match       string
	Replacement string
}

type RuleReplacementRule struct {
	Match       string
	Replacement string
	LimitGroup  []string
	Init        string
}

type HeaderData struct {
	Name           string
	URL            string
	Condition      string
	InitLine       string
	MinKubeVersion string
	MaxKubeVersion string
	ByLine         string
}
