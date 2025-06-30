package config

import (
	"context"
	"path"
)

type AppContext struct {
	context.Context
	ChartRootDir string
	DebugMode    bool
}

func (c *AppContext) SetChartRootDir(chartRootDir string) {
	c.ChartRootDir = chartRootDir
}

var appCtx *AppContext

func GetContext() *AppContext {
	if appCtx == nil {
		appCtx = &AppContext{
			Context:   context.Background(),
			DebugMode: false,
		}
	}
	return appCtx
}

func (c *AppContext) GetScriptsDir() string {
	return path.Join(c.ChartRootDir, "hack")
}

func (c *AppContext) GetTmpDir() string {
	return path.Join(c.ChartRootDir, "hack", "tmp")
}
