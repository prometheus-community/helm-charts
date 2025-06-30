package util

import (
	"regexp"
)

// FindIter returns an iterator-like channel that yields the start and end
// indices of each match of the regular expression in the input string.
// This is similar to Python's re.finditer.
func FindIter(pattern, s string) [][]int {
	re := regexp.MustCompile(pattern)
	return re.FindAllStringIndex(s, -1)
}
