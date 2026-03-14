#!/usr/bin/zsh
# @fileoverview gt runs various gitTool sub-commands (e.g. gt addRepo...)
#                     _
#  _      _      __ _| |_
#  \\___()''o   / _` | __|
#  (     \_v   | (_| | |_    gt: tools to simplify git and github
#   \_)\_)_)    \__, |\__|
#               |___/
#

# global to all gt apps
GT_APP_NAME="gt"
GT_VERSION="1.0.0"
FULL_PATH_NAME="${${0:h}//\\//}"
OWNER=""

# support modules
source ${FULL_PATH_NAME}/modules/gtStatusCodes.sh
source ${FULL_PATH_NAME}/modules/gtCharCodes.sh
source ${FULL_PATH_NAME}/modules/gtDebug.sh
source ${FULL_PATH_NAME}/modules/gtPrintBox.sh
source ${FULL_PATH_NAME}/modules/gtUtil.sh
source ${FULL_PATH_NAME}/modules/gtGetOwner.sh

# command interface modules
source ${FULL_PATH_NAME}/gtAddRepo.sh
source ${FULL_PATH_NAME}/gtCheckInAll.sh
source ${FULL_PATH_NAME}/gtDelRepo.sh
source ${FULL_PATH_NAME}/gtListRepos.sh


# print gt help in a nice box
printGtHelp() {
  printBoxTop
  local appName="${GT_APP_NAME} (v$GT_VERSION):"
  local appDescription="an easy-to-use tool for git and github"
  local msg="${BOLD}$appName $appDescription${BOLD_OFF}"
  printBox "$msg" 81

  printBox "example: ${GT_APP_NAME} addRepo myNewRepo --private"
  printCrossBar
  printBox "help       | --help     | -h | -? .. show this help"
  printBox "addRepo    | makeRepo   | ar | mr... add a new repo"
  printBox "delRepo    | removeRepo | rr | dr... delete a repo from github"
  printBox "listRepos  | lr..................... list your gitHub repos"
  printBox "checkInAll | cia.................... git pull, add, commit, push"
  printBox "version    | --version  | -v |...... show the version (v$GT_VERSION)"
  printBoxBottom
}


# called after parsing gt args
debugPrintGtArgList() {
  if [[ $(gtDebugIsOn) -eq 0 ]]; then return ; fi

  local resultStatus=$1
  local cmd=$2
  local paramList=("${@:3}")

  gtDebugPrint "gt parsed arguments are..."
  gtDebugPrint "  resultStatus: " "${resultStatus}"
  gtDebugPrint "  cmd:          " ${helpFlag}
  gtDebugPrint "  paramList:   \""${paramList}"\"\n"
}


# process the main input argList into an array with resultStatus, cmd, params
processGtArgList() {
  local resultStatus="${GT_STATUS_OK}"
  local cmdFound=0
  local versionFlag=0
  local helpFlag=0
  local paramList=()
  local unknownParamList=()
  local cmd="none"
  local arg=""

  if [[ $# -eq 0 ]]; then   # they entered just "gt" so show help
    cmd="help"
  else
    for arg in "${@}";do
      local firstChar="${arg:0:1}"

      # if it is a parameter
      if [[ "${firstChar}" == "-" ]]; then
        arg="${arg:l}"  # lowercase the parameter
        paramList+=("${arg}")    # -parameter might belong to the command

        case "${arg}" in
          "--help" | "-h" | "-?")
            helpFlag=1  # dont change cmd=help; flag might be for specific cmd
            ;;

          "--version")  # version flag overrides passing on to other gt cmds
            versionFlag=1
            cmd="version"
            cmdFound=1
            ;;

          "-v")  # version flag for empty gt or a parameter for gt command
            versionFlag=1
            ;;

          *)
            # param is not for gt but might belong to the specific gt command
            unknownParamList+=("${arg}")
            ;;
        esac
      else
        # found the command. store it and flag it cmdFound
        if [[ "${cmdFound}" -eq 0 ]]; then
          cmd="${arg}"
          cmdFound=1
        else
          paramList+=("${arg}")
        fi  # if not cmdFound
      fi  # if arg is a -parameter
    done # for all args in argList
  fi  # if there are no args

  # if there is no command then
  #  if help was found, show help
  #  if version was found, show version
  #  if there are unknown params, issue an error
  if [[ ${cmdFound} -eq 0  ]]; then
    if [[ ${helpFlag} -eq 1 ]]; then
      cmd="help"
    elif [[ ${versionFlag} -eq 1 ]]; then
      cmd="version"
    elif [[ ${#unknownParamList} -gt 0 ]]; then
      resultStatus="${GT_STATUS_UNKNOWN_PARAMETER}: ${unknownParamList}"
    fi
  fi

  # print the results as a list with cmd at the front; qq '' each paramlist ele
  print -r -- ${(qq)resultStatus} ${cmd} ${(qq)paramList}
}


# first arg is the cmd, the rest are the parameters
runGtCmd() {
  local cmd=${1:l}              # ${one:el} cmd is first arg, lowercase it
  local paramList=("${@:2}")    # paramList is the rest of the args

  # based on the command, run the gtCmd or issue an error
  case ${cmd} in
    "addrepo" | "ar" | "makerepo" | "mr")
      gtAddRepo ${paramList}
      ;;

    "checkinall" | "cia")
      gtCheckInAll ${paramList}
      ;;

    "delrepo" | "dr" | "removerepo" | "rr")
      gtDelRepo ${paramList}
      ;;

    "help")
      printGtHelp
      ;;

    "listrepos" | "listrepo" | "lr")
      gtListRepos ${paramList}
      ;;

    "version")
      print "${GT_VERSION}"
      ;;

    *)
      gtPrintErrorBox "${GT_STATUS_INVALID_CMD}: \"${cmd}\""
      printGtHelp
      ;;
  esac
}


# main entry point for the app
main() {
  # gtDebugOn

  # globally available to all gt apps
  OWNER=$(gtGetOwner)

  local resultList=("${(@Q)${(z)$(processGtArgList ${@})}}")
  local resultStatus="${resultList[1]}"
  local cmd=${resultList[2]}
  local paramList=("${resultList[@]:2}")

  debugPrintGtArgList "${resultStatus}" "${cmd}" "${paramList}"

  if [[ "${resultStatus}" != "${GT_STATUS_OK}" ]]; then
    gtPrintErrorBox "${resultStatus}"
    printGtHelp
    exit
  fi

  runGtCmd ${cmd} ${paramList}
}

main $@
