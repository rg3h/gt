#!/usr/bin/zsh
# @fileoverview gtStatus.sh checks in all files in a repo
#  by doing a pull, add -A, commit -m, push
#                     _
#  _      _      __ _| |_
#  \\___()''o   / _` | __|
#  (     \_v   | (_| | |_    gt: tools to simplify git and github
#   \_)\_)_)    \__, |\__|
#               |___/
#

printGtStatusHelp() {
  local msg=""

  printBoxTop
  msg="gt [status | rs]"
  printBox "${BOLD}${msg}${RESET}"
  printCrossBar
  printBox "shows the status of the local and remote repo"
  printBox "  --help    | -h | -? issues this help"
  # printBox "  --verbose | -v      shows more details"
  # printBox "  --owner --other --org --history --details --log"
  printBoxBottom
}


# called after parsing gtStatus() args
debugPrintGtStatusArgList() {
  if [[ $(gtDebugIsOn) -eq 0 ]]; then return ; fi

  local resultStatus=$1
  local helpFlag=$2
  local verboseFlag=$3

  gtDebugPrint "gtStatus parsed arguments are..."
  gtDebugPrint "  resultStatus " ${resultStatus}
  gtDebugPrint "  helpFlag     " ${helpFlag}
  # gtDebugPrint "  verboseFlag  " ${verboseFlag}  # verbose not implemented yet
}


# process the argList into an array of GT parameters with cmd as first element
processGtStatusArgList() {
  local resultStatus=${GT_STATUS_OK}
  local helpFlag=0
  local verboseFlag=0
  local arg=""

  for arg in "${@}";do
    # if it is a parameter
    local firstChar="${arg:0:1}"
    if [[ "${firstChar}" == "-" ]]; then
      arg="${arg:l}"  # lowercase the parameter

      case "${arg}" in
        "--help" | "-h" | "-?")
          helpFlag=1
          ;;

#       "--verbose" | "-v")
#         verboseFlag=1
#         ;;

        *)
          resultStatus="${GT_STATUS_UNKNOWN_PARAMETER} ${arg}"
          break
          ;;
      esac
    else
      resultStatus="${GT_STATUS_UNKNOWN_PARAMETER} ${arg}"
      break
    fi   # if arg is a -parameter
  done # for all args in arglist

  print -r -- ${(qq)resultStatus} ${helpFlag} ${verboseFlag}
}


# if helpFlag set, print help and exit
handleStatusHelpFlag() {
  local helpFlag=${1}
  if [[ ${helpFlag} -eq 1 ]]; then
    printGtStatusHelp
    exit
  fi
}


# if resultStatus not ok, print error and quit
handleStatusResultStatus() {
  local resultStatus=${1}
  if [[ ${resultStatus} != ${GT_STATUS_OK} ]]; then
    gtPrintErrorBox ${resultStatus}
    printGtStatusHelp
    exit
  fi
}


# show the local and remote status
# gtShowStatus ${verboseFlag}
gtShowStatus() {
  local cmdOutput=""
  local cmdStatus=0
  local verboseFlag=${1}
  local localRepoUrl=""
  local localRepoChanges=""
  local remoteRepoUrl=""
  local remoteRepoChanges=""
  local errorMsg=""
  local msgList=()
  local lines=()
  local trackingParameter=""
  local filename=""

  # verbose not implemented yet
  if [[ ${verboseFlag} -eq 1 ]]; then
    print "gt status verbose not implemented yet"
  fi

  # get the local repo url
  if [[ ${cmdStatus} -eq 0 ]]; then
    cmdOutput=$(git rev-parse --absolute-git-dir)
    cmdStatus=$?
    if [[ ${cmdStatus} -eq 0 ]]; then
      localRepoUrl="${cmdOutput}"
    else
      errorMsg="${localRepoUrl}"
    fi
  fi

  # get the local repo status
  if [[ ${cmdStatus} -eq 0 ]]; then
    cmdOutput=$(git status -sb 2>&1)
    cmdStatus=$?
    if [[ ${cmdStatus} -eq 0 ]]; then
      cmdOutput=$(echo "$cmdOutput" | sed 1d) # remove 1st line
      cmdOutput="${cmdOutput//$'\t'/ }"       # remove tabs

      if [[ ${#cmdOutput} -eq 0 ]]; then
        msg="no changes"
      else
        msgList=()
        lines=(${(f)cmdOutput})
        for line in "${lines[@]}"; do
          trackingParameter="${line:0:2}"
          filename="${line:3}"

          case ${trackingParameter} in
            "??")
              msgList+=${BRIGHT_WHITE}"UNTRACKED: ${filename}"${RESET_COLOR}
              ;;

            "A " | " A")
              msgList+=${BRIGHT_GREEN}"ADDED:     ${filename}"${RESET_COLOR}
              ;;

            "M " | " M")
              msgList+=${BRIGHT_CYAN}"MODIFIED:  ${filename}"${RESET_COLOR}
              ;;

            "D " | " D")
              msgList+=${BRIGHT_RED}"DELETED:   ${filename}"${RESET_COLOR}
              ;;

            *)
              msgList+=${BRIGHT_MAGENTA}"UNKNOWN:   [${trackingParameter}] ${filename}"${RESET_COLOR}
              ;;
          esac
        done
      fi

      msgList=("${(o)msgList[@]}")                      # sort the list
      localRepoChanges=$(printf "%s\n" "${msgList[@]}") # turn into \n sep str
    else
      errorMsg="${cmdOutput}";
    fi
  fi

  ### get the remote url
  if [[ ${cmdStatus} -eq 0 ]]; then
    remoteRepoUrl=$(git config --get remote.origin.url 2>&1)
    cmdStatus=$?
    if [[ ${cmdStatus} -ne 0 ]]; then errorMsg="${localRepoUrl}"; fi
  fi

  ### get the remote repo status
  if [[ ${cmdStatus} -eq 0 ]]; then
    # first fetch the remote and stick it in the .git dir
    local fetchResults=$(git fetch --all 2>&1)
    cmdStatus=$?
    if [[ ${cmdStatus} -ne 0 ]]; then errorMsg="${fetchResults}"; fi

    # now get the differences
    if [[ ${cmdStatus} -eq 0 ]]; then
      remoteRepoChanges=$(git diff --name-status main origin/main 2>&1)
      cmdStatus=$?
      if [[ ${cmdStatus} -eq 0 ]]; then
        remoteRepoChanges="${remoteRepoChanges//$'\t'/ }"     # remove tabs
        remoteRepoChanges=$(echo "$remoteRepoChanges"| sed 's/?? /UNTRACKED: /')
        remoteRepoChanges=$(echo "$remoteRepoChanges" | sed 's/A /ADDED:     /')
        remoteRepoChanges=$(echo "$remoteRepoChanges" | sed 's/M /MODIFIED:  /')
        remoteRepoChanges=$(echo "$remoteRepoChanges" | sed 's/D /DELETED:   /')
        if [[ ${#remoteRepoChanges} -eq 0 ]]; then
          remoteRepoChanges="no changes"
        fi
      elif [[ ${cmdStatus} -eq 128 ]]; then
        remoteRepoChanges="empty remote repository"
        cmdStatus=0
      else
        errorMsg="${remoteRepoChanges}";
      fi
    fi
  fi


  ### print the status or the error
  if [[ ${cmdStatus} -eq 0 ]]; then
    printBoxTop
    printBox "LOCAL repo: ${localRepoUrl}"
    printCrossBar
    printBox "${localRepoChanges}"
    printBoxBottom
    print " "
    printBoxTop
    printBox "REMOTE repo: ${remoteRepoUrl}"
    printCrossBar
    printBox ${remoteRepoChanges}
    printBoxBottom
  else
    gtPrintErrorBox "gt status error: ${cmdStatus}" ${errorMsg}
  fi

}


# called by gt.sh -- the main entry point for gtStatus
gtStatus() {
  # gtDebugOn

   # process the input args and store the results in an array
  local resultList=("${(@Q)${(z)$(processGtStatusArgList ${@})}}")
  local resultStatus=${resultList[1]}
  local helpFlag=${resultList[2]}
  local verboseFlag=${resultList[3]}

  debugPrintGtStatusArgList "${resultStatus}" "${helpFlag}" "${verboseFlag}"

  handleStatusHelpFlag ${helpFlag}         # if --help print and quit
  handleStatusResultStatus ${resultStatus} # if error w/ args, print & quit

  gtShowStatus ${verboseFlag}
}
