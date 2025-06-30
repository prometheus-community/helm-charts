package util

func Must[T any](result T, err error) T {
	if err != nil {
		panic(err)
	}
	return result
}

func CheckErr(err error) {
	if err != nil {
		panic(err)
	}
}
