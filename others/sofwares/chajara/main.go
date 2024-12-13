package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func printTree(n *node, prefix string, isLast bool) {
	connector := "├── "
	if isLast && (*n).name != "." {
		connector = "└── "
	}
	if (*n).name == "." {
		connector = ""
	}

	fmt.Printf("%s%s%s\n", prefix, connector, (*n).name)
	i := 0
	for _, child := range (*n).children {
		newPrefix := prefix
		if (*n).name == "." {
			newPrefix = ""
		} else if isLast {
			newPrefix += "    "
		} else {
			newPrefix += "│   "
		}
		printTree(&child, newPrefix, i == len((*n).children)-1)
		i++
	}
}

type node struct {
	name     string
	children map[string]node
	T        bool
}

var root node = node{name: ".", T: true}

func grow(line *string) {
	elements := strings.Split(*line, "/")
	ln := len(elements) - 1
	current := &root

	for i, elem := range elements {
		if elem == "." || elem == "" {
			continue
		}
		if current.children == nil {
			current.children = make(map[string]node)
		}

		directory := i < ln
		if _, exists := current.children[elem]; !exists {
			current.children[elem] = node{name: elem, children: make(map[string]node), T: directory}
		}
		temp_node := current.children[elem]
		current = &temp_node
	}
}

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	var lines []string
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintln(os.Stderr, "Error reading input:", err)
		return
	}

	for i := 0; i < len(lines); i++ {
		line := lines[i]
		grow(&line)
	}

	printTree(&root, "", true)
}
