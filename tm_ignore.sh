#!/usr/bin/env bash

#
# @file
# Controller for Time Machine Ignore.
#

# Define the configuration file relative to this script.
CONFIG="tm_ignore.core.yml"

# Uncomment this line to enable file logging.
#LOGFILE="tm_ignore.core.log"

function on_pre_config() {
  [[ "$(get_command)" == "init" ]] && exit_with_init
}

# Exclude the given path from Time Machine backups.
#
# $1 - The path to the item to exclude from Time Machine.
function exclude_path() {
  local path="$1"

  if [[ ! -e $path ]]; then
    list_add_item "$(echo_warning "$path does not exist")"
    return
  fi
  path=$(realpath $path)
  if tmutil isexcluded "$path" | grep -q '\[Excluded\]'; then
    list_add_item "${path} is already excluded, skipping. $(echo_green "[OK]")"
    continue
  fi

  if tmutil addexclusion "$path"; then
    sizeondisk=$(du -hs "$path" | cut -f1)
    list_add_item "${path} has been excluded from Time Machine backups ($sizeondisk). $(echo_green "[OK]")"
  else
    fail_because "Could not add $path"
  fi
}

# Begin Cloudy Bootstrap
s="${BASH_SOURCE[0]}"
while [ -h "$s" ]; do
  dir="$(cd -P "$(dirname "$s")" && pwd)"
  s="$(readlink "$s")"
  [[ $s != /* ]] && s="$dir/$s"
done
r="$(cd -P "$(dirname "$s")" && pwd)"
source "$r/../../cloudy/cloudy/cloudy.sh"
[[ "$ROOT" != "$r" ]] && echo "$(tput setaf 7)$(tput setab 1)Bootstrap failure, cannot load cloudy.sh$(tput sgr0)" && exit 1
# End Cloudy Bootstrap

# Input validation.
validate_input || exit_with_failure "Input validation failed."

implement_cloudy_basic

# Handle other commands.
command=$(get_command)
case $command in

"list")
  mdfind "com_apple_backup_excludeItem = 'com.apple.backupd'" || exit_with_failure
  exit_with_success
  ;;

"reset")
  path=$(get_command_arg 0)
  path=$(path_relative_to_config_base "$path")
  if ! tmutil removeexclusion "$path"; then
    fail_because "Could not include $path in TM backups."
    exit_with_failure
  fi
  echo_green "$path is now being included"
  exit_with_init
  ;;

"apply")
  echo_title "Ignoring files based on your configuration"
  eval $(get_config_path_as -a ignores ignore)

  list_clear
  for path in "${ignores[@]}"; do
    exclude_path "$path"
  done

  has_failed && exit_with_failure

  echo_list
  exit_with_success
  ;;

esac

throw "Unhandled command \"$command\"."
