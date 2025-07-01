package dashboards

import (
	"io"
	"main/internal/config"
	"main/internal/types"
	"net/http"

	"github.com/sirupsen/logrus"
)

func prepareUrlDashboard(ctx *config.AppContext, currentState *chartState, chart *types.DashboardURLSource) error {
	logrus.Infof("Generating dashboard from %s", chart.Source)

	resp, err := http.Get(chart.Source)
	if err != nil {
		return err
	}
	defer resp.Body.Close() // Ensure the connection is closed

	// Read the response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	currentState.rawText = string(body)
	currentState.source = chart.Source
	currentState.url = chart.Source

	return nil
}
