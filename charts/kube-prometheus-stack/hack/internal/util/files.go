package util

import (
	"fmt"
	"os"
	"path"
	"path/filepath"
	"runtime"
)

func ChartRoot() string {
	_, filename, _, ok := runtime.Caller(0)
	if !ok {
		panic("could not get caller info to identify scripts root")
	}

	hackDir := filename
	for i := 0; i < 4; i++ {
		hackDir = path.Dir(hackDir)
	}

	return hackDir
}

func CleanTmpDir(tmpDir string) {
	_, err := os.Stat(tmpDir)
	if err == nil {
		_ = os.RemoveAll(tmpDir)
	} else if os.IsNotExist(err) {
		// this is fine
	} else {
		// maybe do something about this err
	}
}

func CreateTmpDir(tmpDir string) error {
	return os.Mkdir(tmpDir, os.ModePerm)
}

func IsFile(path string) bool {
	info, err := os.Stat(path)
	if err != nil {
		return false // e.g., file doesn't exist
	}
	return info.Mode().IsRegular()
}

func GetRelativePath(rootPath string, targetPath string) (string, error) {
	cleanRoot := filepath.Clean(rootPath)
	cleanTargetPath := filepath.Clean(targetPath)

	relPath, err := filepath.Rel(cleanRoot, cleanTargetPath)
	if err != nil {
		return "", fmt.Errorf("could not determine relative path for %s: %w", targetPath, err)
	}

	return relPath, nil
}
