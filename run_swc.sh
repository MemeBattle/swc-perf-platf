#!/bin/bash

# Script to run swc on the src directory with version and plugin option selection
# Usage: ./run_swc.sh [old|new] [with_plugin|without_plugin] [raw]

set -e

SWC_VERSION=$1
PLUGIN_OPTION=$2
RAW_OUTPUT=$3

if [[ "$SWC_VERSION" != "old" && "$SWC_VERSION" != "new" ]]; then
  echo "The first parameter must be 'old' or 'new'"
  exit 1
fi

if [[ "$PLUGIN_OPTION" != "with_plugin" && "$PLUGIN_OPTION" != "without_plugin" ]]; then
  echo "The second parameter must be 'with_plugin' or 'without_plugin'"
  exit 1
fi

# Determine the directory with the required swc version
if [[ "$SWC_VERSION" == "old" ]]; then
  SWC_DIR="swc-old"
else
  SWC_DIR="swc-new"
fi

# Check that the directory exists
if [[ ! -d "$SWC_DIR" ]]; then
  echo "Directory $SWC_DIR not found!"
  exit 1
fi

cd "$SWC_DIR"

run_build() {
  local suppress_output=$1
  if [[ "$PLUGIN_OPTION" == "with_plugin" ]]; then
    SWC_CMD="npx swc --config-file ./.swcrc_with_plugin -d dist ../src"
  else
    SWC_CMD="npx swc --config-file ./.swcrc_without_plugin -d dist ../src"
  fi
  # Use seconds for timing
  START_TIME=$(date +%s)
  if [[ "$suppress_output" == "true" ]]; then
    $SWC_CMD > /dev/null 2>&1
  else
    $SWC_CMD
  fi
  END_TIME=$(date +%s)
  ELAPSED=$((END_TIME - START_TIME))
  echo $ELAPSED
}

if [[ "$RAW_OUTPUT" == "raw" ]]; then
  run_build true
  exit 0
fi

# Output swc version
npx swc --version

echo "Running: npx swc --config-file ./.swcrc_${PLUGIN_OPTION} -d dist ../src"
ELAPSED=$(run_build false)
echo "Execution time: $ELAPSED s" 