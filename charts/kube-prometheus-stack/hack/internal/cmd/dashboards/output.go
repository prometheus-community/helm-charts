package dashboards

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"slices"
	"strings"

	"main/internal/cmd/dashboards/consts"
	"main/internal/cmd/dashboards/patch"
	"main/internal/jsonnet"
	"main/internal/log"
	"main/internal/pythonish"
	"main/internal/types"
	"main/internal/util"

	"gopkg.in/yaml.v3"
)

func writeOutput[T types.DashboardSource](currentState chartState, chart T) error {
	dashboardType := chart.GetType()
	if dashboardType == types.DashboardKubernetesYaml {
		var yamlData map[string]interface{}
		err := yaml.Unmarshal([]byte(currentState.rawText), &yamlData)
		if err != nil {
			return err
		}

		kind, hasKind := yamlData["kind"]
		if !hasKind {
			log.Log.Warn("kind not found in yaml")
		}
		k8sKeys := []string{
			"apiVersion",
			"kind",
			"metadata",
			"items",
		}
		keyCount := 0
		for key, _ := range yamlData {
			if slices.Contains(k8sKeys, key) {
				keyCount++
			}
		}
		if keyCount < len(k8sKeys)-1 && !hasKind {
			return fmt.Errorf("no kind found in yaml and not enough expected keys: %v", k8sKeys)
		}

		// Now use `kind` var to somehow reparse the data into that specific kind
		switch kind {
		case "ConfigMapList":
			configMapList := util.ParseConfigMapList(currentState.rawText)
			for _, group := range configMapList.Items {
				for resource, content := range group.Data {
					resourceName := strings.TrimSuffix(resource, filepath.Ext(resource))

					err := writeGroupToFile(
						resourceName,
						content,
						currentState.url,
						chart.GetDestination(),
						chart.GetMinKubernetes(),
						chart.GetMaxKubernetes(),
						chart.GetMulticlusterKey(),
					)
					if err != nil {
						return err
					}
				}
			}
		}

	} else if dashboardType == types.DashboardYaml {
		log.Log.Warn("dashboard type for `yaml` not implemented")
	} else if dashboardType == types.DashboardJson {
		resourceName := filepath.Base(currentState.source)
		resourceName = strings.TrimSuffix(resourceName, filepath.Ext(resourceName))

		err := writeGroupToFile(
			resourceName,
			currentState.rawText,
			currentState.url,
			chart.GetDestination(),
			chart.GetMinKubernetes(),
			chart.GetMaxKubernetes(),
			chart.GetMulticlusterKey(),
		)
		if err != nil {
			return err
		}
	} else if dashboardType == types.DashboardJsonnetMixin {
		// In the python script, the CWD would be mixinDir; with prev CWD saved to `cwd` var
		vm := jsonnet.NewVm(currentState.mixinDir)
		renderedJson, err := vm.EvaluateAnonymousSnippet(
			currentState.source,
			currentState.rawText+".grafanaDashboards",
		)
		if err != nil {
			return err
		}
		var jsonDataMap map[string]map[string]interface{}
		jsonErr := json.Unmarshal([]byte(renderedJson), &jsonDataMap)
		if jsonErr != nil {
			return jsonErr
		}

		// After jsonnet is run we can go back to prev CWD context if
		_, ok := any(chart).(types.DashboardGitSource)
		if ok {
			// change dir maybe?
		}

		_, useFlatStructure := jsonDataMap["annotations"]
		if useFlatStructure {
			resourceName := filepath.Base(currentState.source)
			resourceName = strings.TrimSuffix(resourceName, filepath.Ext(resourceName))

			content, jsonErr := json.Marshal(jsonDataMap)
			if jsonErr != nil {
				return jsonErr
			}

			err := writeGroupToFile(
				resourceName,
				string(content),
				currentState.url,
				chart.GetDestination(),
				chart.GetMinKubernetes(),
				chart.GetMaxKubernetes(),
				chart.GetMulticlusterKey(),
			)
			if err != nil {
				return err
			}
		} else {
			for resource, content := range jsonDataMap {
				resourceName := strings.TrimSuffix(resource, filepath.Ext(resource))

				jsonData, jsonErr := json.Marshal(content)
				if jsonErr != nil {
					return jsonErr
				}

				err := writeGroupToFile(
					resourceName,
					string(jsonData),
					currentState.url,
					chart.GetDestination(),
					chart.GetMinKubernetes(),
					chart.GetMaxKubernetes(),
					chart.GetMulticlusterKey(),
				)
				if err != nil {
					return err
				}
			}
		}
	}

	return nil
}

func writeGroupToFile(
	resourceName string,
	content string,
	url string,
	destination string,
	minKubernetesVersion string,
	maxKubernetesVersion string,
	multiclusterKey string,
) error {
	condition, _ := consts.DashboardsConditionMap[resourceName]

	headerData := types.HeaderData{
		Name:           resourceName,
		URL:            url,
		Condition:      condition,
		MinKubeVersion: minKubernetesVersion,
		MaxKubeVersion: maxKubernetesVersion,
	}
	preparedContent := util.Must(consts.NewDashboardHeader(headerData))

	content = patch.DashboardJson(content, multiclusterKey)
	content = patch.DashboardJsonSetTimezoneAsVariable(content)
	content = patch.DashboardJsonSetEditableAsVariable(content)
	content = patch.DashboardJsonSetIntervalAsVariable(content)

	fileStruct := map[string]interface{}{
		resourceName + ".json": content,
	}
	yamlString, yamlStrErr := pythonish.YamlStrRepr(fileStruct, 2, false)
	if yamlStrErr != nil {
		return yamlStrErr
	}
	yamlString = util.Indent(yamlString, "  ")
	preparedContent += yamlString
	preparedContent += "{{- end }}"

	linesGrafanaOperator := util.Must(consts.NewGrafanaOperator(headerData))
	preparedContent += linesGrafanaOperator

	filename := resourceName + ".yaml"
	newFilename := fmt.Sprintf("%s/%s", destination, filename)

	// make sure directories to store the file exist
	dirErr := os.MkdirAll(destination, os.ModePerm)
	if dirErr != nil {
		return dirErr
	}

	// Recreate the file
	writeErr := os.WriteFile(newFilename, []byte(preparedContent), 0644)
	if writeErr != nil {
		return writeErr
	}

	log.Log.Infof("Generated %s", newFilename)

	return nil
}
