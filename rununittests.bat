@echo off
set hereOrig=%~dp0
set here=%hereOrig%
if #%hereOrig:~-1%# == #\# set here=%hereOrig:~0,-1%
set unitTestsPath=%here%\tests\unit
set testOutput=%here%\testOutput\unit
md %testOutput%

rem Set NVDA_UNIT_TESTS_COVERAGE=1 to also measure code coverage.
set runner=xmlrunner
if "%NVDA_UNIT_TESTS_COVERAGE%"=="1" set runner=coverage run -m xmlrunner

call uv run --group unit-tests --directory "%here%" -m %runner% discover -b -s "%unitTestsPath%" -t "%here%" --output-file "%testOutput%\unitTests.xml" %*
