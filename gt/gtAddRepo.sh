#!/usr/bin/zsh
# @fileoverview gtAddRepo.sh adds a gethub repo locally and remotely
#  gtAddRepo repoName [optional localRepoName ] --help --private
#                     _
#  _      _      __ _| |_
#  \\___()''o   / _` | __|
#  (     \_v   | (_| | |_    gt: tools to simplify git and github
#   \_)\_)_)    \__, |\__|
#               |___/
#

printGtAddRepoHelp() {
  local msg=""

  printBoxTop
  msg="gt {addRepo | ar} remoteRepoName [localRepoName] [--private]"
  printBoxLine "${BOLD}${msg}${CLR_COLOR}"
  printCrossBar
  printBoxLine "adds a github remote repo and a local repo directory"
  printBoxLine "  --help | -h | -? issues this help"
  printBoxLine "  --private adds a private repo (default is public)"
  printBoxLine " "
  printBoxLine "examples:"
  printBoxLine " gt addRepo myRepo   # add local and remote repo named myRepo"
  printBoxLine " gt addRepo myRepo . # add remote w/ local repo in current dir"
  printBoxLine " gt addRepo myRepo --private"
  printBoxLine " gt addRepo myRepo myLocalRepoName"
  printBoxLine " gt ar myRepo myLocalRepoName --private"
  printBoxBottom
}


# called after parsing gtAddRepo() args
debugPrintGtAddRepoArgList() {
  if [[ $(gtDebugIsOn) -eq 0 ]]; then return ; fi

  local resultStatus=$1
  local helpFlag=$2
  local privateFlag=$3
  local remoteRepo=$4
  local localRepo=$5

  gtDebugPrint "gtAddRepo parsed arguments are..."
  gtDebugPrint "  resultStatus  " ${resultStatus}
  gtDebugPrint "  helpFlag      " ${helpFlag}
  gtDebugPrint "  privateFlag   " ${privateFlag}
  gtDebugPrint "  remoteRepo    " ${remoteRepo}
  gtDebugPrint "  localRepo     " ${localRepo}
}


# process the argList into an array of GT parameters with cmd as first element
processGtAddRepoArgList() {
  local resultStatus=${GT_STATUS_OK}
  local remoteRepoFound=0
  local localRepoFound=0
  local privateFlag=0
  local helpFlag=0
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

        "--private")
          privateFlag=1
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
      resultStatus="${GT_STATUS_MISSING_REMOTE_REPO_NAME}"
    fi
  fi

  print -r -- ${(qq)resultStatus} ${helpFlag} ${privateFlag} \
              ${remoteRepo} ${localRepo}
}


# if helpFlag set, print help and exit
handleAddRepoHelpFlag() {
  local helpFlag=${1}
  if [[ ${helpFlag} -eq 1 ]]; then
    printGtAddRepoHelp
    exit
  fi
}


# if resultStatus not ok, print error and quit
handleAddRepoResultStatus() {
  local resultStatus=${1}
  if [[ ${resultStatus} != ${GT_STATUS_OK} ]]; then
    gtPrintErrorBox ${resultStatus}
    printGtAddRepoHelp
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


# makeRemoteRepo "${remoteRepo}" "${localRepo}" ${privateFlag}
makeRemoteRepo() {
  local remoteRepo="${1}"
  local localRepo="${2}"
  local privateFlag=${3}
  local cmd=""
  local cmdStatus=0
  local cmdOutput=""
  local pubPrivFlag="public"

  if [[ ${privateFlag} -eq 1 ]]; then pubPrivFlag="private"; fi

  cmd=(gh repo create "${remoteRepo}" --source="${localRepo}" --${pubPrivFlag})
  gtDebugPrint "create repo cmd: ${cmd}"

  cmdOutput=$("${cmd[@]}" 2>&1)
  cmdStatus=$?

  if [[ ${cmdStatus} -ne 0 ]]; then
    gtDebugPrint "did not create the remote repo:" ${remoteRepo}
    gtDebugPrint "return status" "${cmdStatus}"
    gtDebugPrint "return cmdOutput" "${cmdOutput}"

    local errorMsg="${GT_STATUS_COULD_NOT_ADD_REMOTE_REPO}: ${remoteRepo}"
    gtPrintErrorBox ${errorMsg} ${cmdOutput}
    exit
  fi

  print "created the remote ${pubPrivFlag} repo: ${cmdOutput}"
}


# called by gt.sh -- effectively the main entry point for gtAddRepo
gtAddRepo() {
  # gtDebugOn

  # process the input args and store the results in an array
  local resultList=("${(@Q)${(z)$(processGtAddRepoArgList ${@})}}")
  local resultStatus=${resultList[1]}
  local helpFlag=${resultList[2]}
  local privateFlag=${resultList[3]}
  local remoteRepo=${resultList[4]}
  local localRepo=${resultList[5]}

  debugPrintGtAddRepoArgList "${resultStatus}"  \
                             "${helpFlag}"      \
                             "${privateFlag}"   \
                             "${remoteRepo}"    \
                             "${localRepo}"

  handleAddRepoHelpFlag ${helpFlag}          # if --help print and quit
  handleAddRepoResultStatus ${resultStatus}  # if error w/ args, print and quit

  # if no localRepo name then copy remoteRepo name
  if [[ ${localRepo} == "none" ]]; then localRepo="${remoteRepo}"; fi

  checkBothRepoNamesAreValid ${remoteRepo} ${localRepo}
  checkRemoteRepoDoesNotExist ${remoteRepo}
  checkLocalRepoDoesNotExist ${localRepo}

  # everything is good, make the remote and local repo
  gtDebugPrint "Everything is good. Making the local repo:" "${localRepo}"
  makeLocalRepo ${localRepo}

  gtDebugPrint "Everything is good. Making the remote repo:" "${remoteRepo}"
  makeRemoteRepo "${remoteRepo}" "${localRepo}" ${privateFlag}
}
