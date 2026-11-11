$outDir = (Resolve-Path .\testOutput\unit\)
$unitTestsXml = "$outDir\unitTests.xml"
$env:NVDA_UNIT_TESTS_COVERAGE = "1"
.\rununittests.bat --output-file "$unitTestsXml" -v
$testExitCode = $LastExitCode
if ($testExitCode -ne 0) {
	Write-Output "FAIL: Unit tests. See test results for more information." >> $env:GITHUB_STEP_SUMMARY
	Write-Output "testFailExitCode=$testExitCode" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
}

# Coverage reports are informational: a failure to produce them must not fail the job.
uv run --group unit-tests -m coverage xml
uv run --group unit-tests -m coverage html
$coverageTotal = uv run --group unit-tests -m coverage report --format=total
if ($LastExitCode -eq 0) {
	# Also print to the job log, which is easier to reach than the job summary.
	uv run --group unit-tests -m coverage report
	Write-Output "Unit test coverage: $coverageTotal%"
	Write-Output "Unit test coverage: $coverageTotal%`n" >> $env:GITHUB_STEP_SUMMARY
	Write-Output "<details>`n<summary>Unit test coverage per file</summary>`n" >> $env:GITHUB_STEP_SUMMARY
	uv run --group unit-tests -m coverage report --format=markdown >> $env:GITHUB_STEP_SUMMARY
	Write-Output "`n</details>`n" >> $env:GITHUB_STEP_SUMMARY
} else {
	Write-Output "WARNING: Unit test coverage report could not be generated." >> $env:GITHUB_STEP_SUMMARY
}

exit $testExitCode
