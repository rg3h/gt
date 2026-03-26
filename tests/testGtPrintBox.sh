#!/usr/bin/zsh
# @fileoverview testGtPrintBox tests gtPrintBox with various strings.
#                     _
#  _      _      __ _| |_
#  \\___()''o   / _` | __|
#  (     \_v   | (_| | |_    gt: tools to simplify git and github
#   \_)\_)_)    \__, |\__|
#               |___/
#

source ../gt/modules/gtCharCodes.sh
source ../gt/modules/gtPrintBox.sh

printBox "this is something normal"
print "An empty printBpx"
printBox

printBox "${ERROR_SYMBOL} " "hello" "this line has a unicode symbol"

printBox "this input has\nmultiple lines\nto see how that works"

printBox "this is a very long line so we can test trimming the line to the correct length"

printBox "${GREEN}This is a green line that is very long so we can see that it is correctly handled too${CLR_COLOR}\nThis line should be white"

printBox "AAAThis line exactly fits and should have no padding or truncation"
printBox "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAThis line is 1 character short"
printBox "AAAAAAAAAAAAAAAAAAThis line is 1 character longer than it should be"

local cmdOutput="this is why we cannot have nice things but this is a very long line to test things and then\nanother line shows up and it is also very long and a trouble maker so we shalle see"

GT_STATUS_COULD_NOT_MKDIR="Error: cannot create the local repo directory"
gtPrintErrorBox "${GT_STATUS_COULD_NOT_MKDIR}\n" ${cmdOutput}
