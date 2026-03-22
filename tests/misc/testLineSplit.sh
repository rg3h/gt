#!/usr/bin/zsh
# @fileoverview testLineSplit.sh tests splitting a line on \n
#                     _
#  _      _      __ _| |_
#  \\___()''o   / _` | __|
#  (     \_v   | (_| | |_    gt: tools to simplify git and github
#   \_)\_)_)    \__, |\__|
#               |___/
#
local str=""
local strList=()
local i=0
EXP_LINE_CT=3

check() {
  str=$1

  if [[ ${#strList} -ne $EXP_LINE_CT ]]; then
    print "FAIL: should be" $EXP_LINE_CT "but got" ${#strList}
  else
    print "SUCCESS! expected" $EXP_LINE_CT "and got" ${#strList}
  fi
  for ((i=1; i<=${#strList[@]}; i++)); do print "$i: ${strList[$i]}"; done
  print ""
}

# This works for ' but not "
print "this works for single quoted string but not double quoted strings"
str='a SINGLE quoted multiline\nhello there\nthis is the third line'
strList=("${(f)str}")
check ${str} ${strList}

str="a DOUBLE quoted multiline\nhello there\nthis is the third line"
strList=("${(f)str}")
check ${str} ${strList}

print ""

# This works for both ' and "
print "this works for BOTH single quoted string AND double quoted strings"

str='a SINBLE quoted multiline\nhello there\nthis is the third line'
strList=("${(@s:\n:)str}")
check ${str} ${strList}

str="a DOUBLE quoted multiline\nhello there\nthis is the third line"
strList=("${(@s:\n:)str}")
check ${str} ${strList}
