package jsonnet

import (
	"fmt"
	"main/internal/util"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/google/go-jsonnet"
	"github.com/sirupsen/logrus"
)

type fsCacheEntry struct {
	contents jsonnet.Contents
	abspath  string
	exists   bool
}

type MyImporter struct {
	fsCache  map[string]*fsCacheEntry
	MixinDir string
}

func (mi *MyImporter) tryPath(dir, importedPath string) (found bool, contents jsonnet.Contents, foundHere string, err error) {
	if mi.fsCache == nil {
		mi.fsCache = make(map[string]*fsCacheEntry)
	}
	var absPath string
	if filepath.IsAbs(importedPath) {
		absPath = importedPath
	} else {
		absPath = filepath.Join(dir, importedPath)
	}
	var entry *fsCacheEntry
	if cacheEntry, isCached := mi.fsCache[absPath]; isCached {
		entry = cacheEntry
	} else {
		contentBytes, err := os.ReadFile(absPath)
		if err != nil {
			if os.IsNotExist(err) {
				entry = &fsCacheEntry{
					exists: false,
				}
			} else {
				return false, jsonnet.Contents{}, "", err
			}
		} else {
			entry = &fsCacheEntry{
				exists:   true,
				contents: jsonnet.MakeContentsRaw(contentBytes),
			}
		}
		mi.fsCache[absPath] = entry
	}
	return entry.exists, entry.contents, absPath, nil
}

func (mi *MyImporter) Import(importedFrom, importedPath string) (contents jsonnet.Contents, foundAt string, err error) {
	if strings.Contains(importedPath, "github.com") {
		found, content, foundHere, err := mi.tryPath(mi.MixinDir+"/vendor/", importedPath)
		if err != nil {
			return jsonnet.Contents{}, "", err
		}

		if found {
			return content, foundHere, nil
		}
	}

	dir, _ := filepath.Split(importedFrom)
	found, content, foundHere, err := mi.tryPath(dir, importedPath)
	if err != nil {
		return jsonnet.Contents{}, "", err
	}

	if !found {
		found, content, foundHere, err = mi.tryPath(mi.MixinDir, importedPath)
		if err != nil {
			return jsonnet.Contents{}, "", err
		}
	}

	if found {
		return content, foundHere, nil
	}

	return jsonnet.Contents{}, "", fmt.Errorf("couldn't open import %#v: no match locally or in the Jsonnet library paths", importedPath)
}

func NewVm(mixinDir string) *jsonnet.VM {
	vm := jsonnet.MakeVM()
	abs, err := filepath.Abs(mixinDir)
	if err != nil {
		vm.Importer(&MyImporter{
			fsCache:  make(map[string]*fsCacheEntry),
			MixinDir: mixinDir,
		})
	}
	vm.Importer(&MyImporter{
		fsCache:  make(map[string]*fsCacheEntry),
		MixinDir: abs,
	})

	return vm
}

// InitJsonnetBuilder handles `jb install` calls
func InitJsonnetBuilder(dir string) error {
	if !strings.HasSuffix(dir, "/") {
		dir = dir + "/"
	}
	jsonnetFile := filepath.Join(dir, "jsonnetfile.json")
	if util.IsFile(jsonnetFile) {
		logrus.Info("Running jsonnet-bundler, because jsonnetfile.json exists")

		cmd := exec.Command("jb", "install")
		cmd.Dir = dir // Set the working directory
		err := cmd.Run()
		if err != nil {
			logrus.Error("Error running jsonnet-bundler: %v\n", err)
			return err
		}
	}

	return nil
}
