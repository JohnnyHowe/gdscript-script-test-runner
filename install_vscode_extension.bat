@echo off
pushd "%~dp0"
npm --prefix vscode-extension run install:local
popd
