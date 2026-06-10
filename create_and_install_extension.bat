@echo off
pushd "%~dp0"

if not exist "vscode-extension\node_modules\.bin\tsc.cmd" (
	call npm --prefix vscode-extension ci
	if errorlevel 1 (
		set EXIT_CODE=%errorlevel%
		popd
		exit /b %EXIT_CODE%
	)
)

call npm --prefix vscode-extension run install:local
set EXIT_CODE=%errorlevel%

popd
exit /b %EXIT_CODE%
