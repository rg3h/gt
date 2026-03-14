#!/usr/bin/zsh
# @fileoverview gtListRepos.sh lists the repos
#  gtListRepos --help --sort {date, name, private, public}
#                     _
#  _      _      __ _| |_
#  \\___()''o   / _` | __|
#  (     \_v   | (_| | |_    gt: tools to simplify git and github
#   \_)\_)_)    \__, |\__|
#               |___/
#

printGtListReposHelp() {
  printBoxTop
  local msg="gt [listRepos | lr] [--sort [date|name|private|public]]"
  printBox "${BOLD}${msg}${RESET}" 80
  printCrossBar
  printBox "lists up to 100 of your remote repos in a table"
  printBox "  --help | -h | -?  issues this help"
  printBox "  --sort | -s [date|name|private] sorts by one of these fields"
  printBox " "
  printBox "examples:"
  printBox " gt listRepos         # lists your repos sorted by date"
  printBox " gt lr --sort name    # lists your repos sorted by name"
  printBox " gt lr --sort private # lists your repos with private ones first"
  printBox " gt lr --sort public  # lists your repos with public ones first"
  printBoxBottom
}


# called after parsing gtRempveRepo() args
debugPrintGtListReposArgList() {
  if [[ $(gtDebugIsOn) -eq 0 ]]; then return ; fi

  local resultStatus=$1
  local helpFlag=$2
  local sortField=$3

  gtDebugPrint "gtListRepos parsed arguments are..."
  gtDebugPrint "  resultStatus " ${resultStatus}
  gtDebugPrint "  helpFlag     " ${helpFlag}
  gtDebugPrint "  sortField    " ${sortField} "\n"
}


# process the argList into an array of GT parameters with cmd as first element
processGtListReposArgList() {
  local resultStatus=${GT_STATUS_OK}
  local helpFlag=0
  local sortField="date"
  local arg=""

  # we use a while loop so we can use shift
  # for arg in "${@}";do
  while (($#)); do
    arg="${1}"
    local firstChar="${arg:0:1}"

    # if it is a parameter
    if [[ "${firstChar}" == "-" ]]; then
      arg="${arg:l}"  # lowercase the parameter

      case "${arg}" in
        "--help" | "-h" | "-?")
          helpFlag=1
          ;;

        "--sort" | "--sortby" | "-s")
          if [[ $# -gt 1 ]]; then
            shift   # moves $@ to the next argument
            arg="${1:l}"  # lowercase the parameter
            case "${arg}" in
              "date" | "name" | "private" | "public")
                sortField="${arg}"
                ;;
              *)
                resultStatus="${GT_STATUS_UNKNOWN_SORT_PARAMETER} ${arg}"
                ;;
            esac
          else
            resultStatus="${GT_STATUS_MISSING_SORT_PARAMETER}"
          fi
          ;;

        *)
          resultStatus="${GT_STATUS_UNKNOWN_PARAMETER} ${arg}"
          ;;
      esac
    fi
    shift   # move $@ to the next argument
  done

  # if requesting help, then the command errors dont matter
  if [[ "${helpFlag}" -eq 1 ]]; then
    resultStatus="${GT_STATUS_OK}"
  fi

  print -r -- ${(qq)resultStatus} ${helpFlag} "${sortField}"
}


# if helpFlag set, print help and exit
handleListReposHelpFlag() {
  local helpFlag=${1}
  if [[ ${helpFlag} -eq 1 ]]; then
    printGtListReposHelp
    exit
  fi
}


# if resultStatus not ok, print error and quit
handleListReposResultStatus() {
  local resultStatus=${1}
  if [[ ${resultStatus} != ${GT_STATUS_OK} ]]; then
    gtPrintErrorBox ${resultStatus}
    printGtListReposHelp
    exit
  fi
}


# called by gt.sh -- effectively the main entry point for gtListRepos
gtListRepos() {
  # gtDebugOn

  local limit=100
  local fields="name,updatedAt,visibility"
  local timeField="(timefmt \"Jan 01 2006 03:04pm\" .updatedAt)"
  local tableRow="{{tablerow .name ${timeField} .visibility }}"
  local template="{{range .}} ${tableRow} {{end}}"
  local cmdOutput=""
  local cmdStatus=0

  # process the input args and store the results in an array
  local resultList=("${(@Q)${(z)$(processGtListReposArgList ${@})}}")
  local resultStatus=${resultList[1]}
  local helpFlag=${resultList[2]}
  local sortField=${resultList[3]}

  debugPrintGtListReposArgList "${resultStatus}" "${helpFlag}" "${sortField}"

  handleListReposHelpFlag ${helpFlag}          # if --help print and quit
  handleListReposResultStatus ${resultStatus}  # if error w/ args, print & quit

  local sortMsg="sorted by ${sortField}"
  local header="remote repos for ${OWNER} (${sortMsg}; date is UTC)"
  case "${sortField}" in
    "date")
      cmdOutput=$(gh repo list --limit ${limit} --json ${fields} \
                     --template "${template}")
      cmdStatus=$?
      cmdOutput=$(sed "s/^[[:space:]]*//" <<<"$cmdOutput")
      gtPrintBoxWithHeader "${header}" "${cmdOutput}"
    ;;

    "name")
      cmdOutput=$(gh repo list --limit ${limit} --json ${fields} \
                     --template "${template}")
      cmdStatus=$?
      cmdOutput=$(sed "s/^[[:space:]]*//" <<<"$cmdOutput")
      cmdOutput=$(sort -k1 <<< "$cmdOutput")
      gtPrintBoxWithHeader "${header}" "${cmdOutput}"
      ;;

    "private")
      cmdOutput=$(gh repo list --limit ${limit} --json ${fields} \
                     --template "${template}")
      cmdStatus=$?
      cmdOutput=$(sed "s/^[[:space:]]*//" <<<"$cmdOutput")
      cmdOutput=$(sort -k6 <<< "$cmdOutput")
      gtPrintBoxWithHeader "${header}" "${cmdOutput}"
      ;;

    "public")
      cmdOutput=$(gh repo list --limit ${limit} --json ${fields} \
                     --template "${template}")
      cmdStatus=$?
      cmdOutput=$(sed "s/^[[:space:]]*//" <<<"$cmdOutput")
      cmdOutput=$(sort --reverse -k6 <<< "$cmdOutput")
      gtPrintBoxWithHeader "${header}" "${cmdOutput}"
      ;;

    *)
      gtPrintErrorBox "${GT_STATUS_UNKNOWN_SORT_PARAMETER} ${sortField}"
      ;;
  esac
}
