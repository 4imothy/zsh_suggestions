package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
	// Get the user's PATH environment variable
	path := os.Getenv("PATH")
	paths := strings.Split(path, ":")

	for _, p := range paths {
		files, err := os.ReadDir(p)
		if err != nil {
			continue
		}

		for _, f := range files {
			// Check if the file is executable
			fileInfo, err := f.Info()
			if err != nil {
				continue
			}
			if !fileInfo.Mode().IsRegular() || fileInfo.Mode().Perm()&0111 == 0 {
				continue
			}
			fmt.Println(f.Name())
		}
	}
}
