#!/bin/sh

local executables=$(go run main.go)
# local chip=$(echo $system_hardware | grep "Chip:" | awk '{print($2$3$4)}')

for exec in "$executables" do
  echo "$exec"
