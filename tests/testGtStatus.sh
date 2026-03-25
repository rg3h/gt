#!/usr/bin/zsh
# @fileoverview gtTestStatus tests gtPrintBox with various strings.
#                     _
#  _      _      __ _| |_
#  \\___()''o   / _` | __|
#  (     \_v   | (_| | |_    gt: tools to simplify git and github
#   \_)\_)_)    \__, |\__|
#               |___/
#
FULL_PATH_NAME="../gt"
source ${FULL_PATH_NAME}/modules/gtStatusCodes.sh
source ${FULL_PATH_NAME}/modules/gtCharCodes.sh
source ${FULL_PATH_NAME}/modules/gtDebug.sh
source ${FULL_PATH_NAME}/modules/gtPrintBox.sh
source ${FULL_PATH_NAME}/modules/gtUtils.sh
source ${FULL_PATH_NAME}/gtStatus.sh

local cmdOutput=""
testDir="testGtStatus"

# create the test directory
rm -rf "${testDir}"
mkdir "${testDir}"
cd testGtStatus
rm -rf .git

# create the test repo
gt="../../gt/gt.bat"
cmdOutput=$(${gt} dr testGtStatus --yes 2>&1)   # represses any errors
${gt} ar testGtStatus .

# create the initial set of test files for the repo
echo "tracked" > trackedFile
echo "moded" > modedFile
echo "deleted" > deletedFile
${gt} cia "initial check-in"

# create moded, deleted, untracked and added files
echo "moded" >> modedFile
rm -f deletedFile
echo "untracked" > untrackedFile
echo "added" > addedFile
git add addedFile

# show the status of all the files
${gt} status

# clean up
${gt} dr testGtStatus --yes
cd ..
rm -rf "${testDir}"
