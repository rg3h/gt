:: runTest.bat %1 runs one gt test
@ECHO OFF
SETLOCAL
SET "scriptPath=Z:\projects\gitAndGitHub\gt\tests"
cd %scriptPath%
zsh %1
ENDLOCAL
