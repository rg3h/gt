:: runAllTests.bat runs the test suite for gt
@ECHO OFF
SETLOCAL
SET "scriptPath=Z:\projects\gitAndGitHub\gt\tests"
cd %scriptPath%
zsh runAllTests.sh
ENDLOCAL
