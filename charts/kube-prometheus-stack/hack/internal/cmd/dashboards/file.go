package dashboards

import (
	"github.com/sirupsen/logrus"
	"main/internal/config"
	"main/internal/types"
	"main/internal/util"
	"os"
	"path"
	"path/filepath"
)

func prepareFileDashboard(ctx *config.AppContext, currentState *chartState, chart *types.DashboardFileSource) error {
	fileSourcePath, pathErr := filepath.Abs(path.Join(ctx.ChartRootDir, chart.Source))
	if pathErr != nil {
		return pathErr
	}
	file, readErr := os.ReadFile(fileSourcePath)
	if readErr != nil {
		return readErr
	}

	logrus.Infof("Generating dashboards from %s", fileSourcePath)

	currentState.rawText = string(file)
	currentState.source = chart.Source
	relPath, err := util.GetRelativePath(
		chart.GetDestination(),
		fileSourcePath,
	)
	if err != nil {
		return err
	}
	currentState.url = relPath
	return nil
}
