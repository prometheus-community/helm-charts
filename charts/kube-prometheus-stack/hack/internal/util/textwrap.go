package util

import "strings"

// Indent adds 'prefix' to the beginning of selected lines in 'text'.
//
// If 'predicate' is provided, 'prefix' will only be added to the lines
// where 'predicate(line)' returns true. If 'predicate' is nil, it will
// default to adding 'prefix' to all non-empty lines that do not
// consist solely of whitespace characters.
func Indent(text, prefix string, predicate ...func(string) bool) string {
	lines := strings.SplitAfter(text, "\n")
	var builder strings.Builder

	var predFunc func(string) bool
	if len(predicate) > 0 && predicate[0] != nil {
		predFunc = predicate[0]
	} else {
		predFunc = func(line string) bool {
			return strings.TrimSpace(line) != ""
		}
	}

	for _, line := range lines {
		if predFunc(line) {
			builder.WriteString(prefix)
		}
		builder.WriteString(line)
	}
	return builder.String()
}
