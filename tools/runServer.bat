:: @fileoverview runServer.bat runs a local node web server
@echo off
clear
setlocal
start "simpleServer" cmd /t:1f /k "node ./server/simpleServer.js --webroot ../../public/"
endlocal
