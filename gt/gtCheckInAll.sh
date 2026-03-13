#!/usr/bin/zsh
# @fileoverview gtCheckInAll.sh adds a gethub repo.
#  gtCheckInAll repoName [optional localRepoName ] --help --private
#
filesPushed=""

printGtCheckInAllHelp() {
  local msg=""

  printBoxTop
  msg="gt {checkInAll | cia} msg"
  printBox "${BOLD}${msg}${RESET}" 80
  printCrossBar
  printBox "does a git pull, add . commit, and push"
  printBox "  --help | -h | -? issues this help"
  printBox " "
  printBox "examples:"
  printBox " gt checkInAll \"updated README.md\""
  printBoxBottom
}


# called after parsing gtCheckInAll() args
debugPrintGtCheckInAllArgList() {
  if [[ $(gtDebugIsOn) -eq 0 ]]; then return ; fi

  local resultStatus=$1
  local helpFlag=$2
  local message=$3

  gtDebugPrint "gtCheckInAll parsed arguments are..."
  gtDebugPrint "  resultStatus " ${resultStatus}
  gtDebugPrint "  helpFlag     " ${helpFlag}
  gtDebugPrint "  message      " "${message}"
}


# process the argList into an array of GT parameters with cmd as first element
processGtCheckInAllArgList() {
  local resultStatus=${GT_STATUS_OK}
  local helpFlag=0
  local msgList=()
  local flagFound=0
  local arg=""

  for arg in "${@}";do
    # if it is a parameter
    local firstChar="${arg:0:1}"
    if [[ "${firstChar}" == "-" ]]; then
      flagFound=1
      arg="${arg:l}"  # lowercase the parameter

      case "${arg}" in
        "--help" | "-h" | "-?")
          helpFlag=1
          ;;

        *)
          resultStatus="${GT_STATUS_UNKNOWN_PARAMETER} ${arg}"
          ;;
      esac
    else
      # if we have not found any flags or if the msglist not set
      if [[ flagFound -eq 0 || ${#msgList} -lt 1 ]]; then
        msgList+="${arg}"
      fi
    fi   # if arg is a -parameter
  done # for all args in arglist

  # if requesting help, then the command errors dont matter
  if [[ "${helpFlag}" -eq 1 ]]; then
    resultStatus="${GT_STATUS_OK}"
  else
    # if we did not find a message, set the status
    if [[ "${resultStatus}" == "${GT_STATUS_OK}" && ${#msgList} -eq 0 ]]; then
      resultStatus="${GT_STATUS_MISSING_MESSAGE}"
    fi
  fi

  print -r -- ${(qq)resultStatus} ${helpFlag} ${(qq)msgList}
}


# if helpFlag set, print help and exit
handleCheckInAllHelpFlag() {
  local helpFlag=${1}
  if [[ ${helpFlag} -eq 1 ]]; then
    printGtCheckInAllHelp
    exit
  fi
}


# if resultStatus not ok, print error and quit
handleCheckInAllResultStatus() {
  local resultStatus=${1}
  if [[ ${resultStatus} != ${GT_STATUS_OK} ]]; then
    gtPrintErrorBox ${resultStatus}
    printGtCheckInAllHelp
    exit
  fi
}


# pull can fail (e.g. status=128 not a repo)
# pull can succeed (status=0)
# pull can fail, but not important (status=1 happens when nothing to pull)
gtCheckInAllPull() {
  local cmdOutput=""
  local cmdStatus=0

  print "gt pulling from remote repo..."
  cmdOutput=$(git pull 2>&1)
  cmdStatus=$?

  if [[ ${cmdStatus} -eq 0 ]]; then
    gtDebugPrint "pull    worked" ${cmdStatus} ${cmdOutput}
  else
    if [[ ${cmdStatus} -eq 1 ]]; then   # if error=1 then continue
      # print "minor git warning on pull. Will continue."
    else
      gtPrintErrorBox "Error pulling" ${cmdStatus} ${cmdOutput}
      exit
    fi
  fi
}


gtCheckInAddAll() {
  local cmdOutput=""
  local cmdStatus=0

  print "gt adding all..."
  cmdOutput=$(git add -A 2>&1)
  cmdStatus=$?

  if [[ ${cmdStatus} -eq 0 ]]; then
    gtDebugPrint "add all worked" ${cmdStatus} ${cmdOutput}
  else
    # TODO issue a warningBox
    gtPrintErrorBox "Error adding" ${cmdStatus} ${cmdOutput}
    if [[ ${cmdStatus} -ne 1 ]]; then   # if error=1 then continue
      exit
    fi
  fi
}


gtCheckInCommit() {
  local cmdOutput=""
  local cmdStatus=0
  local msg=${1}

  print "gt commiting -m \"${msg}\" locally..."
  cmdOutput=$(git commit -m "${msg}" 2>&1)
  cmdStatus=$?

  if [[ ${cmdStatus} -eq 0 ]]; then
    gtDebugPrint print "commit  worked" ${cmdStatus} ${cmdOutput}
  else
    # TODO issue a warningBox
    if [[ ${cmdStatus} -eq 1 ]]; then   # branch up to date
      printBoxTop
      printBox "Nothing done. Branch is already up to date"
      printBoxBottom
      exit
    elif [[ ${cmdStatus} -ne 0 ]]; then
      gtPrintErrorBox "Error committing" "${cmdStatus} ${cmdOutput}"
      exit
    fi
  fi
}


gtShowFilesToBePushed() {
  local cmdOutput=""
  local cmdStatus=0

  cmdOutput=$(git log -1 --pretty=format: --name-only 2>&1)
  cmdStatus=$?

  if [[ ${cmdStatus} -eq 0 ]]; then
    filesPushed="${cmdOutput}"    # filesPushed is a global variable
  else
    local msg="Error getting files to be pushed"
    gtPrintErrorBox  "${msg}" "${cmdStatus} ${cmdOutput}"
  fi
}


gtCheckInPush() {
  local cmdOutput=""
  local cmdStatus=0

  print "gt pushing to remote repo..."
  cmdOutput=$(git push 2>&1)
  cmdStatus=$?

  if [[ ${cmdStatus} -eq 0 ]]; then
    gtDebugPrint "push worked" ${cmdStatus} ${cmdOutput}
  else
    # TODO issue a warningBox
    gtPrintErrorBox "Error pushing" "${cmdStatus} ${cmdOutput}"
    if [[ ${cmdStatus} -ne 1 ]]; then   # if error=1 then continue
      exit
    fi
  fi
}


# called by gt.sh -- the main entry point for gtCheckInAll
gtCheckInAll() {
  # gtDebugOn

  # process the input args and store the results in an array
  local resultList=("${(@Q)${(z)$(processGtCheckInAllArgList ${@})}}")
  local resultStatus=${resultList[1]}
  local helpFlag=${resultList[2]}
  local message=${resultList[3,-1]}

  debugPrintGtCheckInAllArgList "${resultStatus}" "${helpFlag}" "${message}"

  handleCheckInAllHelpFlag ${helpFlag}          # if --help print and quit
  handleCheckInAllResultStatus ${resultStatus}  # if error w/ args, print & quit

  gtDebugPrint "Everything is good. pull,add,commit,push to the repo:" "${repo}"
  gtCheckInAllPull
  gtCheckInAddAll
  gtCheckInCommit ${message}
  gtShowFilesToBePushed
  gtCheckInPush

  # show the success
  printBoxTop
  printBox "gt checkInAll -m \"${message}\" was succssful"
  printCrossBar
  printBox "files pushed:"
  printBox "${filesPushed}"
  printBoxBottom
}
