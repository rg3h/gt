#!/usr/bin/zsh
# @fileoverview gtConnectTo.sh clones remote repo and connects the local to it
#                     _
#  _      _      __ _| |_
#  \\___()''o   / _` | __|
#  (     \_v   | (_| | |_    gt: tools to simplify git and github
#   \_)\_)_)    \__, |\__|
#               |___/
#

printGtConnectToHelp() {
  local msg=""

  printBoxTop
  msg="gt connectTo remoteRepoName [localRepoName | .]"
  printBoxLine "${BOLD}${msg}${CLR_COLOR}"
  printCrossBar
  printBoxLine "clones a github remote repo and connects the local repo to it"
  printBoxLine "  --help | -h | -?   issues this help"
  printBoxLine "  --allBranches | -a gets all branches as well"
  printBoxLine " "
  printBoxLine "examples:"
  printBoxLine " gt connectTo myRepo   # connect to remote repo named myRepo"
  printBoxLine " gt c2 myRepo abc      # connect to remote, name the local abc"
  printBoxLine " gt c2 myRepo -a       # connect to remote getting all branches"
  printBoxBottom
}


# called after parsing gtConnectTo() args
debugPrintGtConnectToArgList() {
  if [[ $(gtDebugIsOn) -eq 0 ]]; then return ; fi

  local resultStatus=$1
  local helpFlag=$2
  local allBranchesFlag=$3
  local remoteRepo=$4
  local localRepo=$5

  gtDebugPrint "gtConnectTo parsed arguments are..."
  gtDebugPrint "  resultStatus    " ${resultStatus}
  gtDebugPrint "  helpFlag        " ${helpFlag}
  gtDebugPrint "  allBranchesFlag " ${allBranchesFlag}
  gtDebugPrint "  remoteRepo      " ${remoteRepo}
  gtDebugPrint "  localRepo       " ${localRepo}
}


# process the argList into an array of GT parameters with cmd as first element
processGtConnectToArgList() {
  local resultStatus=${GT_STATUS_OK}
  local remoteRepoFound=0
  local localRepoFound=0
  local helpFlag=0
  local allBranchesFlag=0
  local remoteRepo="none"
  local localRepo="none"
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

        "--allbranches" | "-a")
          allBranchesFlag=1
          ;;

        *)
          resultStatus="${GT_STATUS_UNKNOWN_PARAMETER} ${arg}"
          ;;
      esac
    else
      if [[ "${remoteRepoFound}" -eq 0 ]]; then
        remoteRepo="${arg}"
        remoteRepoFound=1
      elif [[ "${localRepoFound}" -eq 0 ]]; then
        localRepo="${arg}"
        localRepoFound=1
      else
        # this is a bad argument -- pass an error status
        resultStatus="${GT_STATUS_UNKNOWN_PARAMETER} ${arg}"
      fi   # if remoteRepo not found
    fi   # if arg is a -parameter
  done # for all args in arglist

  # if requesting help, then the command errors dont matter
  if [[ "${helpFlag}" -eq 1 ]]; then
    resultStatus="${GT_STATUS_OK}"
  else
    # if we did not find a remoteRepo, set the status
    if [[ "${remoteRepoFound}" -eq 0 ]]; then
      resultStatus="${GT_STATUS_NO_REMOTE_REPO_NAME}"
    fi
  fi

  print -r -- ${(qq)resultStatus} ${helpFlag} ${allBranchesFlag} \
        ${remoteRepo} ${localRepo}
}


# if helpFlag set, print help and exit
handleConnectToHelpFlag() {
  local helpFlag=${1}
  if [[ ${helpFlag} -eq 1 ]]; then
    printGtConnectToHelp
    exit
  fi
}


# if resultStatus not ok, print error and quit
handleConnectToResultStatus() {
  local resultStatus=${1}
  if [[ ${resultStatus} != ${GT_STATUS_OK} ]]; then
    gtPrintErrorBox ${resultStatus}
    printGtConnectToHelp
    exit
  fi
}


# if the remote repo already exists, issue an error and exit
checkRemoteRepoDoesNotExist() {
  local remoteRepo=${1}
  local cmdStatus=0

  $(gh repo view ${OWNER}/${remoteRepo} >/dev/null 2>&1)
  cmdStatus=$?

  # cmdStatus = 0 means the repo exists
  if [[ ${cmdStatus} -eq 0 ]]; then
    gtPrintErrorBox "${GT_STATUS_REMOTE_REPO_EXISTS}: ${OWNER}/${remoteRepo}"
    exit
  fi
}


# if the local repo is a "." and there is a .git then fail
# if the local repo is another directory, if it already esists, then fail
checkLocalRepoDoesNotExist () {
  local localRepo=${1}

  # if localRepo named "." and there is a .git repo then error and exit
  if [[ ${localRepo} == "." ]]; then
    if [[ -e ".git" ]]; then
      gtPrintErrorBox "${GT_STATUS_CURRENT_DIR_ALREADY_GIT}"
      exit
    fi
  else  # if not "." then see if localRepo exists and exit if it does
    if [[ -e ${localRepo} ]]; then
      gtPrintErrorBox "${GT_STATUS_DIR_ALREADY_EXISTS}: ${localRepo}"
      exit
    fi
  fi
}


# if the dir name is not "." create a local directory as a local git repo
makeLocalRepo() {
  local localRepo=${1}
  local cmdStatus=0
  local cmdOutput=""

  # if not "." then make the directory
  if [[ "${localRepo}" != "." ]]; then
    cmdOutput=$(mkdir -v "${localRepo}" 2>&1)
    cmdStatus=$?
    if [[ ${cmdStatus} -ne 0 ]]; then
      gtPrintErrorBox ${GT_STATUS_COULD_NOT_MKDIR} ${cmdOutput}
      exit
    fi
  fi

  # now git init the local directory ("." or the named one)
  cmdOutput=$(git -C ${localRepo} init 2>&1)
  cmdStatus=$?

  if [[ ${cmdStatus} -ne 0 ]]; then
    gtPrintErrorBox "${GT_STATUS_COULD_NOT_GIT_INIT} ${localRepo}" ${cmdOutput}
    print "You may need to remove the local directory or .git"
    exit
  fi

  print "created the local repository in: ${localRepo}"
}


# check that the local repo name and remote repo name are valid names
# usage: checkBothRepoNamesAreValid ${remoteRepo} ${localRepo}
checkBothRepoNamesAreValid() {
  local remoteRepo="${1}"
  local localRepo="${2}"
  local errorMsg=""

  # first check remote repo name
  if [[ $(isValidRepoName ${remoteRepo}) == "false" ]]; then
    gtPrintErrorBox "${GT_STATUS_INVALID_REMOTE_REPO_NAME}: ${remoteRepo}"
    exit
  fi

  # second check local repo name
  if [[ $(isValidRepoName ${localRepo}) == "false" ]]; then
    gtPrintErrorBox "${GT_STATUS_INVALID_LOCAL_REPO_NAME}: ${localRepo}"
    exit
  fi
}


# cloneRemoteRepo "${remoteRepo}" "${localRepo}" "${allBranchesFlag}"
cloneRemoteRepo() {
  local remoteRepo="${1}"
  local localRepo="${2}"
  local allBranchesFlag="${3}"
  local cmd=""
  local cmdStatus=0
  local cmdOutput=""
  local branchArg=""
  local msg1=""
  local msg2=""

  if [[ ${allBranchesFlag} -eq 1 ]]; then branchArg="--no-single-branch"; fi

  cmd=(gh repo clone "${remoteRepo}" "${localRepo}" -- --depth=1 ${branchArg})

  gtDebugPrint "clone repo cmd: ${cmd}"

  cmdOutput=$("${cmd[@]}" 2>&1)
  cmdStatus=$?

  if [[ ${cmdStatus} -ne 0 ]]; then
    gtDebugPrint "did not clone the remote repo:" ${remoteRepo}
    gtDebugPrint "return status" "${cmdStatus}"
    gtDebugPrint "return cmdOutput" "${cmdOutput}"

    local errorMsg="${GT_STATUS_COULD_NOT_CLONE_REMOTE_REPO}: ${remoteRepo}"
    gtPrintErrorBox ${errorMsg} ${cmdOutput}
    exit
  fi

  msg1="Success! Cloned remote repo ${BRIGHT_CYAN}${remoteRepo}${CLR_COLOR}"
  msg2="into local directory ${BRIGHT_CYAN}${localRepo}${CLR_COLOR}"
  print ${msg1} ${msg2}
}


# called by gt.sh -- effectively the main entry point for gtConnectTo
gtConnectTo() {
  # gtDebugOn

  # process the input args and store the results in an array
  local resultList=("${(@Q)${(z)$(processGtConnectToArgList ${@})}}")
  local resultStatus=${resultList[1]}
  local helpFlag=${resultList[2]}
  local allBranchesFlag=${resultList[3]}
  local remoteRepo=${resultList[4]}
  local localRepo=${resultList[5]}

  debugPrintGtConnectToArgList "${resultStatus}"    \
                               "${helpFlag}"        \
                               "${allBranchesFlag}" \
                               "${remoteRepo}"      \
                               "${localRepo}"

  handleConnectToHelpFlag ${helpFlag}          # if --help print and quit
  handleConnectToResultStatus ${resultStatus}  # if args error, print and quit

  # if no localRepo name then copy remoteRepo name
  if [[ ${localRepo} == "none" ]]; then localRepo="${remoteRepo}"; fi

  checkBothRepoNamesAreValid ${remoteRepo} ${localRepo}
  checkLocalRepoDoesNotExist ${localRepo}

  # attempting to clone might reveal this
  # checkRemoteRepoExists ${remoteRepo}

  # everything is good, clone the remote and connect the local to it
  local msg="Everything is good. cloning the remote repo:"
  gtDebugPrint "${msg}" "${remoteRepo}" "into local directory" "${localRepo}"

  cloneRemoteRepo "${remoteRepo}" "${localRepo}" "${allBranchesFlag}"

  # connectLocalRepo ${localRepo}
}
