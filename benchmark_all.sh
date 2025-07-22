#!/bin/bash
set -e

# Configurations: [version] [plugin]
CONFIGS=(
  "old without_plugin"
  "old with_plugin"
  "new without_plugin"
  "new with_plugin"
)

# For storing results
RESULTS=()

# Print system info (cross-platform: macOS & Linux)
UNAME=$(uname)
if [[ "$UNAME" == "Darwin" ]]; then
  # macOS
  CPU_INFO=$(sysctl -n machdep.cpu.brand_string)
  PHYSICAL_CORES=$(sysctl -n hw.physicalcpu)
  LOGICAL_CORES=$(sysctl -n hw.logicalcpu)
  MEM_BYTES=$(sysctl -n hw.memsize)
  MEM_GB=$(echo "scale=2; $MEM_BYTES/1024/1024/1024" | bc)
  OS_INFO=$(sw_vers | grep ProductVersion | awk '{print $2}')
elif [[ "$UNAME" == "Linux" ]]; then
  # Linux
  CPU_INFO=$(lscpu | grep 'Model name' | awk -F: '{print $2}' | xargs)
  PHYSICAL_CORES=$(lscpu | grep 'Core(s) per socket' | awk -F: '{print $2}' | xargs)
  LOGICAL_CORES=$(nproc)
  MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  MEM_GB=$(echo "scale=2; $MEM_KB/1024/1024" | bc)
  OS_INFO=$(lsb_release -d 2>/dev/null | awk -F: '{print $2}' | xargs)
  if [[ -z "$OS_INFO" ]]; then
    OS_INFO=$(cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f2)
  fi
else
  CPU_INFO="Unknown"
  PHYSICAL_CORES="Unknown"
  LOGICAL_CORES="Unknown"
  MEM_GB="Unknown"
  OS_INFO="Unknown"
fi

echo "==== System Info ===="
echo "CPU: $CPU_INFO"
echo "Physical cores: $PHYSICAL_CORES"
echo "Logical cores: $LOGICAL_CORES"
echo "Memory: $MEM_GB GB"
echo "OS: $OS_INFO"
echo

for CONFIG in "${CONFIGS[@]}"; do
  VERSION=$(echo $CONFIG | awk '{print $1}')
  PLUGIN=$(echo $CONFIG | awk '{print $2}')
  TIMES=()
  echo "==== $VERSION $PLUGIN ===="
  for i in {1..3}; do
    TIME=$(./run_swc.sh $VERSION $PLUGIN raw)
    echo "Run $i: $TIME s"
    TIMES+=("$TIME")
  done
  # Calculate average (in s)
  SUM=0
  for T in "${TIMES[@]}"; do
    SUM=$((SUM+T))
  done
  AVG=$(echo "scale=2; $SUM/3" | bc)
  RESULTS+=("$VERSION $PLUGIN $AVG")
  echo "Average time for $VERSION $PLUGIN: $AVG s"
  echo
  # For convenience, also save individual values
  SAFE_VERSION=${VERSION//-/_}
  SAFE_PLUGIN=${PLUGIN//-/_}
  export BENCH_${SAFE_VERSION}_${SAFE_PLUGIN}_AVG=$AVG
  export BENCH_${SAFE_VERSION}_${SAFE_PLUGIN}_TIMES="${TIMES[*]}"
done

# Print summary table
printf "\n==== Summary (average time, s) ===="
printf "\n%-10s %-15s %-10s\n" "Version" "Plugin" "Average"
for RES in "${RESULTS[@]}"; do
  printf "%-10s %-15s %-10s\n" $RES
  # Also save for comparison
  if [[ $RES == "old without_plugin"* ]]; then OLD_WITHOUT_PLUGIN=$(echo $RES | awk '{print $3}'); fi
  if [[ $RES == "old with_plugin"* ]]; then OLD_WITH_PLUGIN=$(echo $RES | awk '{print $3}'); fi
  if [[ $RES == "new without_plugin"* ]]; then NEW_WITHOUT_PLUGIN=$(echo $RES | awk '{print $3}'); fi
  if [[ $RES == "new with_plugin"* ]]; then NEW_WITH_PLUGIN=$(echo $RES | awk '{print $3}'); fi
  done

# Print plugin slowdown
printf "\n==== Plugin slowdown ===="
if [[ -n "$OLD_WITHOUT_PLUGIN" && -n "$OLD_WITH_PLUGIN" ]]; then
  OLD_RATIO=$(echo "scale=2; $OLD_WITH_PLUGIN/$OLD_WITHOUT_PLUGIN" | bc)
  printf "\nOld version: x$OLD_RATIO (with_plugin is $OLD_RATIO times slower)"
fi
if [[ -n "$NEW_WITHOUT_PLUGIN" && -n "$NEW_WITH_PLUGIN" ]]; then
  NEW_RATIO=$(echo "scale=2; $NEW_WITH_PLUGIN/$NEW_WITHOUT_PLUGIN" | bc)
  printf "\nNew version: x$NEW_RATIO (with_plugin is $NEW_RATIO times slower)"
fi

# Print new vs old (without_plugin)
printf "\n==== New vs Old (without_plugin) ===="
if [[ -n "$OLD_WITHOUT_PLUGIN" && -n "$NEW_WITHOUT_PLUGIN" ]]; then
  SPEEDUP=$(echo "scale=2; $OLD_WITHOUT_PLUGIN/$NEW_WITHOUT_PLUGIN" | bc)
  if (( $(echo "$SPEEDUP > 1" | bc -l) )); then
    printf "\nNew version is $SPEEDUP times faster than old (without_plugin)"
  else
    SLOWDOWN=$(echo "scale=2; 1/$SPEEDUP" | bc)
    printf "\nNew version is $SLOWDOWN times slower than old (without_plugin)"
  fi
fi
printf "\n\n" 