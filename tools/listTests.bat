:: listTests.bat lists all tests
@ECHO OFF
SETLOCAL
SET "scriptPath=Z:\projects\gitAndGitHub\gt\tests"
cd %scriptPath%
find . -type f -name "*.sh" | sed "s/^\.\///"
ENDLOCAL
