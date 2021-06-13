#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck source=helpers.sh
source "$CURRENT_DIR/helpers.sh"

print_nvme_temp() {
  local temp
  local units=$1

  # try if this is Raspberry Pi
  if command_exists "nvme"; then
    local units=$1
    local temp
    local temp_pkg
    local temp_string
    # retrieve temperature of all CPU packages
    temp_pkg=($(nvme smart-log /dev/nvme0 | grep -P -o "temperature[[:blank:]]*:[[:blank:]]*\K[[:digit:]]{2,3}"))
    for k in $(seq 0 $((${#temp_pkg[@]} - 1))); do
      temp=${temp_pkg[k]}
      if [ "$units" = "F" ]; then
        temp=$(celsius_to_fahrenheit "$temp")
      fi
      # Build a string that has all temperatures
      temp_string="$temp_string $(printf "%3.0fº%s" "$temp" "$units")"
    done
    # remove leading and trailing whitespace
    echo "$temp_string" | awk 'BEGIN{OFS=" "}$1=$1{print $0}'
  else
    echo "no sensors found"
  fi

  if [ "$units" = "F" ]; then
    temp=$(celsius_to_fahrenheit "$temp")
  fi
  printf "%3.0fº%s" "$temp" "$units"
}

main() {
  local units
  units=$(get_tmux_option "@temp_units" "C")
  print_nvme_temp "$units"
}
main
