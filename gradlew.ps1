$ErrorActionPreference = 'Stop'
$version = '8.9'
$gradleHome = Join-Path $env:USERPROFILE ".gradle\casovac\gradle-$version"
if (-not (Test-Path (Join-Path $gradleHome 'bin\gradle.bat'))) {
    $base = Join-Path $env:TEMP "casovac-gradle-$version"
    $zip = Join-Path $base 'gradle.zip'
    New-Item -ItemType Directory -Force -Path $base | Out-Null
    Write-Host "Stahuji Gradle $version..."
    Invoke-WebRequest "https://services.gradle.org/distributions/gradle-$version-bin.zip" -OutFile $zip
    Expand-Archive -Path $zip -DestinationPath $base -Force
    New-Item -ItemType Directory -Force -Path (Split-Path $gradleHome) | Out-Null
    if (Test-Path $gradleHome) { Remove-Item $gradleHome -Recurse -Force }
    Move-Item (Join-Path $base "gradle-$version") $gradleHome -Force
    Remove-Item $base -Recurse -Force
}
$project = $PSScriptRoot
& (Join-Path $gradleHome 'bin\gradle.bat') -p $project @args
exit $LASTEXITCODE
