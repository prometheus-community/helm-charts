package log

import (
	"github.com/sirupsen/logrus"
	"os"
	"strings"
)

var Log *logrus.Logger

func init() {
	Log = logrus.New()

	Log.SetOutput(os.Stdout)

	Log.SetFormatter(&logrus.TextFormatter{})

	// Default to Info level
	levelStr := strings.ToLower(os.Getenv("LOG_LEVEL"))
	level, err := logrus.ParseLevel(levelStr)
	if err != nil {
		level = logrus.InfoLevel
	}

	Log.SetLevel(level)
}
