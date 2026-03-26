#!/usr/bin/zsh
# @fileoverview gtDelRepos.sh deletes a repo. Supports --yes to force
#                     _
#  _      _      __ _| |_
#  \\___()''o   / _` | __|
#  (     \_v   | (_| | |_    gt: tools to simplify git and github
#   \_)\_)_)    \__, |\__|
#               |___/
#

printGtDelRepoHelp() {
  printBoxTop
  printBoxLine "${BOLD}gt {delRepo | dr} remoteRepoName [--yes]${CLR_COLOR}"
  printCrossBar
  printBoxLine "deletes the remote repo but does NOT delete the local repo dir"
  printBoxLine "  --help | -h | -? issues this help"
  printBoxLine "  --yes skips the confirmation check"
  printBoxLine " "
  printBoxLine "examples:"
  printBoxLine " gt delRepo myRepo  # deletes the remote repo named myRepo"
  printBoxLine " gt delRepo myRepo --yes # deletes remote repo w/o confirming"
  printBoxBottom
}


# called after parsing gtRempveRepo() args
debugPrintGtDelRepoArgList() {
  if [[ $(gtDebugIsOn) -eq 0 ]]; then return ; fi

  local resultStatus=$1
  local helpFlag=$2
  local noAskFlag=$3
  local remoteRepo=$4

  gtDebugPrint "gtDelRepo parsed arguments are..."
  gtDebugPrint "  resultStatus " ${resultStatus}
  gtDebugPrint "  helpFlag     " ${helpFlag}
  gtDebugPrint "  noAskFlag    " ${noAskFlag}
  gtDebugPrint "  remoteRepo   " ${remoteRepo} "\n"
}


# if helpFlag set, print help and exit
handleDelRepoHelpFlag() {
  local helpFlag=${1}
  if [[ ${helpFlag} -eq 1 ]]; then
    printGtDelRepoHelp
    exit
  fi
}


# if resultStatus not ok, print error and quit
handleDelRepoResultStatus() {
  local resultStatus=${1}
  if [[ ${resultStatus} != ${GT_STATUS_OK} ]]; then
    gtPrintErrorBox ${resultStatus}
    printGtDelRepoHelp
    exit
  fi
}


# process the argList into an array of parameters with cmd as first element
processGtDelRepoArgList() {
  local remoteRepoFound=0
  local helpFlag=0
  local noAskFlag=0
  local resultStatus=${GT_STATUS_OK}
  local remoteRepo="none"
  local arg=""

  for arg in "${@}";do
    local firstChar="${arg:0:1}"

    if [[ "${firstChar}" == "-" ]]; then
      arg="${arg:l}"  # lowercase the parameter

      case "${arg}" in
        "--help" | "-h" | "-?")
          helpFlag=1
          ;;

        "--yes" | "--noask")
          noAskFlag=1
          ;;

        *)
          resultStatus="${GT_STATUS_UNKNOWN_PARAMETER} ${arg}"
          ;;
      esac
    else
      if [[ "${remoteRepoFound}" -eq 0 ]]; then
        remoteRepo="${arg}"
        remoteRepoFound=1
      else
        # this is a bad argument -- pass an error status
        resultStatus="${GT_STATUS_UNKNOWN_PARAMETER} ${arg}"
      fi
    fi
  done

  # if requesting help, then the command errors dont matter
  if [[ "${helpFlag}" -eq 1 ]]; then
    resultStatus="${GT_STATUS_OK}"
  else
    # if we did not find a remoteRepo, set the status
    if [[ "${remoteRepoFound}" -eq 0 ]]; then
      resultStatus="${GT_STATUS_MISSING_REMOTE_REPO_NAME}"
    fi
  fi

  print -r -- ${(qq)resultStatus} ${helpFlag} ${noAskFlag} \
        ${remoteRepo} ${localRepo}
}


# if the remote repo does not exist, issue an error and exit
checkRemoteRepoExists() {
  local remoteRepo=${1}
  local cmdStatus=0

  $(gh repo view ${OWNER}/${remoteRepo} >/dev/null 2>&1)
  cmdStatus=$?

  # cmdStatus = 0 means the repo exists
  if [[ ${cmdStatus} -ne 0 ]]; then
    local msg="${GT_STATUS_REMOTE_REPO_DOES_NOT_EXIST}: ${OWNER}/${remoteRepo}"
    gtPrintErrorBox ${msg}
    exit
  fi
}


# deleteRemoteRepo "${remoteRepo}" "$noAskFlag}"
deleteRemoteRepo() {
  local remoteRepo=${1}
  local noAskFlag=${2}   # default is to verify, but --yes skips confirmation
  local cmd=""
  local cmdOutput=""
  local cmdStatus=0

  gtDebugPrint "in deleteRemoteRepo() remoteRepo: ${remoteRepo} " \
               "noAskFlag: ${noAskFlag}"

  # delete without asking for confirmation
  if [[ ${noAskFlag} -eq 1 ]]; then
    cmd=(gh repo delete "${remoteRepo}" --yes)
    cmdOutput=$("${cmd[@]}"  2>&1)
    cmdStatus=$?

    if [[ ${cmdStatus} -ne 0 ]]; then
      local errorMsg="${GT_STATUS_COULD_NOT_DEL_REMOTE_REPO}: ${remoteRepo}"
      gtPrintErrorBox ${errorMsg} ${cmdOutput}
      exit
    else
      print "deleted the remote repo" "${OWNER}"/"${remoteRepo}"
      print "you may need to delete the local .git repo for" "${remoteRepo}"
    fi
  else   # run interactively
    gh repo delete "${remoteRepo}"
    print "you may need to delete the local .git repo for" "${remoteRepo}"
  fi
}


# called by gt.sh -- effectively the main entry point for gtDelRepo
gtDelRepo() {
  # gtDebugOn

  local resultList=("${(@Q)${(z)$(processGtDelRepoArgList ${@})}}")
  local resultStatus=${resultList[1]}
  local helpFlag=${resultList[2]}
  local noAskFlag=${resultList[3]}
  local remoteRepo=${resultList[4]}

  debugPrintGtDelRepoArgList "${resultStatus}" "${helpFlag}" \
                             "${noAskFlag}" "${remoteRepo}"

  handleDelRepoHelpFlag ${helpFlag}          # if --help print and quit
  handleDelRepoResultStatus ${resultStatus}  # if error w/ args print and quit
  checkRemoteRepoExists ${remoteRepo}        # if not, issue an error and quit

  gtDebugPrint "Everything is good. Deleting the remote repo:" "${remoteRepo}"
  deleteRemoteRepo "${remoteRepo}" ${noAskFlag}
}
