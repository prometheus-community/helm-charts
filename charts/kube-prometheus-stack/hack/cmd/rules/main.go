package main

import (
	"main/internal/cmd/rules"
	"main/internal/config"
	"main/internal/util"
)

func main() {
	configuredContext := config.GetContext()
	configuredContext.SetChartRootDir(util.ChartRoot())

	// Call dashboards update
	rules.Execute(configuredContext)
}
