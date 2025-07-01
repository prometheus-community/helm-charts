package main

import (
	"main/internal/cmd/dashboards"
	"main/internal/config"
	"main/internal/util"
)

func main() {
	configuredContext := config.GetContext()
	configuredContext.SetChartRootDir(util.ChartRoot())

	// Call dashboards update
	dashboards.Execute(configuredContext)
}
