:: @fileoverfiew gt.bat windows batch file that runs the linux zsh gt.sh
@ECHO OFF
SETLOCAL

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  windows WSL zsh
::  /mnt/z/someDir/someDir/gt.sh
::
:: %~dp0 is the path name including both the drive letter e.g. C:\Path\
::
:: SET "drive=%~d0"                          :: C: or Z:
:: SET "scriptPath=%~p0"                     :: \someDir\someSubDir\
:: SET "cmd=gt.sh"                           :: zsh command to run
:: SET "drive=/mnt/%drive::=%"               :: prepend /mnt/ and remove :
::                                           :: lowercase (C or Z) drive
:: FOR /F "usebackq delims=" %%A IN (`powershell.exe -NoLogo -NoProfile -Command "'%drive%'.ToLower()"`) DO (
::   SET "drive=%%A"
:: )
::
:: SET "scriptPath=%scriptPath:\=/%"         :: replace all \ with /
:: SET "scriptPath=%drive%%scriptPath%%cmd%" :: concat drive, path, and cmd
::
:: ECHO running: wsl zsh %scriptPath% %*
:: wsl zsh %scriptPath% %*

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  windows cygwin zsh
::  /cygdrive/Z/someDir/someDir/gt.sh
::
:: %~dp0 is the path name including both the drive letter e.g. C:\Path\

SET "drive=%~d0"                          :: C: or Z:
SET "drive=/cygdrive/%drive::=%"          :: prepend /cygdrive/ and remove :
SET "cmd=gt.sh"                           :: zsh command to run
SET "scriptPath=%~p0"                     :: \someDir\someSubDir\
SET "scriptPath=%scriptPath:\=/%"         :: replace all \ with /
SET "scriptPath=%drive%%scriptPath%%cmd%" :: concat the drive, path, and cmd

:: ECHO running: (cygwin's) zsh %scriptPath% %*
zsh %scriptPath% %*

ENDLOCAL
