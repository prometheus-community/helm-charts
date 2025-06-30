package rules

import (
	"fmt"
	"github.com/sirupsen/logrus"
	"main/internal/cmd/rules/consts"
	"main/internal/cmd/rules/types"
	"main/internal/config"
	mainTypes "main/internal/types"
	"main/internal/util"
	"os"
)

// Execute will load the refs.yaml config and then process Prometheus Rules Sources
func Execute(ctx *config.AppContext) error {
	util.CheckErr(os.Chdir(ctx.GetScriptsDir()))
	// Load repo refs
	util.CheckErr(config.LoadRepoRefsConfig(ctx.GetScriptsDir()))

	chartsSources := consts.RulesSourceCharts()
	for _, chart := range chartsSources {
		currentState := types.ChartState{}
		switch c := chart.(type) {
		case *mainTypes.RulesGitSource:
			util.CheckErr(prepareGitRules(ctx, &currentState, c))
			mainTypes.SetDefaultMaxK8s(c)
			util.CheckErr(writeOutput(currentState, c))
		default:
			panic(fmt.Sprintf("the rules source %s is not valid", c))
		}
	}

	logrus.Info("Finished syncing prometheus rules & alerts")

	return nil
}
