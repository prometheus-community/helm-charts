package dashboards

import (
	"fmt"
	"main/internal/cmd/dashboards/consts"
	"os"

	"main/internal/config"
	"main/internal/log"
	"main/internal/types"
	"main/internal/util"
)

func Execute(ctx *config.AppContext) error {
	util.CheckErr(os.Chdir(ctx.GetScriptsDir()))
	// Load repo refs
	util.CheckErr(config.LoadRepoRefsConfig(ctx.GetScriptsDir()))

	// python script's init_yaml_styles not needed as LiteralStr handles that
	// read the rules, create a new template file per group
	dashboardChartSources := consts.DashboardsSourceCharts()
	for _, chart := range dashboardChartSources {
		currentState := chartState{}
		switch c := chart.(type) {
		case *types.DashboardGitSource:
			util.CheckErr(prepareGitDashboard(ctx, &currentState, c))
			types.SetDefaultMaxK8s(c)
			writeErr := writeOutput(currentState, c)
			if writeErr != nil {
				return writeErr
			}
		case *types.DashboardURLSource:
			util.CheckErr(prepareUrlDashboard(ctx, &currentState, c))
			types.SetDefaultMaxK8s(c)
			writeErr := writeOutput(currentState, c)
			if writeErr != nil {
				return writeErr
			}
		case *types.DashboardFileSource:
			// Needs to be essentially: https://github.com/prometheus-community/helm-charts/blob/0b60795bb66a21cd368b657f0665d67de3e49da9/charts/kube-prometheus-stack/hack/sync_grafana_dashboards.py#L320
			util.CheckErr(prepareFileDashboard(ctx, &currentState, c))
			types.SetDefaultMaxK8s(c)
			writeErr := writeOutput(currentState, c)
			if writeErr != nil {
				return writeErr
			}
		default:
			return fmt.Errorf("unknown chart type: %T", c)
		}
	}

	log.Log.Info("Finished building dashboards")
	return nil
}
