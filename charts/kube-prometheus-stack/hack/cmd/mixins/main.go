package main

import (
	"fmt"

	"os"
	"os/exec"
	"os/signal"
	"path"
	"syscall"
	"time"

	"main/internal/config"
	"main/internal/git"
	"main/internal/util"
)

var (
	scriptsRoot string
	hackRoot    string
)

// main replicates the old `update_mixins.sh` minus any steps un-needed in golang
func main() {
	configuredContext := config.GetContext()

	// Verify that jsonnet-bundler and other deps are there
	util.CheckErr(VerifySystemDependencies())

	// Skip: original scripts check for sed version

	// Prepare global dir info
	configuredContext.SetChartRootDir(util.ChartRoot())
	tmpDirRoot := configuredContext.GetTmpDir()

	// Set trap to clean up temp dir
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	// Goroutine to handle signals
	go func() {
		sig := <-sigChan
		fmt.Printf("\nReceived signal: %v. Initiating graceful shutdown...\n", sig)

		// Perform graceful shutdown tasks here
		// For example, save pending data, close network connections, etc.
		time.Sleep(1 * time.Second) // Simulate shutdown work
		util.CleanTmpDir(tmpDirRoot)
		fmt.Println("Graceful shutdown complete. Exiting.")
		os.Exit(0) // Exit cleanly after graceful shutdown
	}()

	// Remove old temp dir & make a new one
	util.CleanTmpDir(tmpDirRoot)
	util.CheckErr(util.CreateTmpDir(tmpDirRoot))

	// Clone dependant repos
	for _, repoConfig := range config.Repos {
		destDir := path.Join(tmpDirRoot, repoConfig.Name)
		util.CheckErr(git.ShallowClone(repoConfig, destDir))
	}

	// write current repo SHAs to a config file
	util.CheckErr(config.UpdateRepoRefsConfig(scriptsRoot))
}

func VerifySystemDependencies() error {
	cmd := exec.Command("jb", "--version")
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("'jb' command not found\nInstall jsonnet-bundler from https://github.com/jsonnet-bundler/jsonnet-bundler : %v", err)
	}

	return nil
}
