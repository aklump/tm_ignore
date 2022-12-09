#!/usr/bin/env bash

#
# @file
# Controller for Time Machine Ignore.
#

# Define the configuration file relative to this script.
CONFIG="tm_ignore.core.yml"

COMPOSER_VENDOR=""

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
    list_add_item "$(echo_green $(path_unresolve "$APP_ROOT" "$path")) is excluded $(path_filesize $path)"
    continue
  fi

  if tmutil addexclusion "$path"; then
    sizeondisk=$(du -hs "$path" | cut -f1)
    list_add_item "$(echo_green_highlight $(path_unresolve "$APP_ROOT" "$path")) has just been excluded from Time Machine backups $(path_filesize $path)"
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

eval $(get_config_path_as -a ignored_by_config ignore)

command=$(get_command)
case $command in

"list")
  echo_title "Project Paths Excluded From TM"
  sublist=()
  list_clear
  while IFS= read -r path; do
    [[ "$path" =~ "$APP_ROOT" ]] && list_add_item "$(path_unresolve "$APP_ROOT" "$path") $(path_filesize "$path")"
  done < <(mdfind "com_apple_backup_excludeItem = 'com.apple.backupd'")
  echo_list
  exit_with_success "Done"
  ;;

"reset")
  path="$(get_command_arg 0)"
  echo_title "Reset: $path"
  path="$(path_relative_to_config_base "$path")"
  if ! tmutil removeexclusion "$path"; then
    fail_because "Could not include $path in TM backups."
    exit_with_failure
  fi
  output_path="$(path_unresolve "$APP_ROOT" "$path")"
  succeed_because "The exclusion of $output_path has been reset.  This path will be included in future Time Machine backups."

  array_has_value__array=("${ignored_by_config[@]}")
  if array_has_value "$path"; then
    echo_warning "\"$output_path\" still appears in your ignore list, in your configuration.  To permanentely allow \"$output_path\" to be backed up, you must remove it from your configuration.  If not, the apply command will cause \"$output_path\" to be excluded again."
  fi
  exit_with_success
  ;;

"apply")
  echo_title "Applying Exclusions Per Configuration"
  list_clear
  for path in "${ignored_by_config[@]}"; do
    exclude_path "$path"
  done

  has_failed && exit_with_failure

  echo_list
  exit_with_success
  ;;

esac

throw "Unhandled command \"$command\"."
