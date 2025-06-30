package util

import (
	"k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/util/yaml"
)

func ParseConfigMapList(input string) v1.ConfigMapList {
	var configMapList v1.ConfigMapList
	err := yaml.Unmarshal([]byte(input), &configMapList)
	if err != nil {
		panic(err)
	}
	return configMapList
}
