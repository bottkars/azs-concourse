# get mccli
Write-Host "Retrieving mc cli"
$result=Invoke-WebRequest https://dl.min.io/client/mc/release/windows-amd64/mc.exe -OutFile mc.exe
Write-Host ( $result | Out-String )

Write-Host "Generating Endpoints"
$protocol = Split-Path -Qualifier $env:endpoint
$target = $env:endpoint.Replace('//', '').split(':')[1]
$env:MC_HOST_TARGET = "$($protocol)//$($env:access_key_id):$($env:secret_access_key)@$($target):9000"
Write-Host "Using S3 Host $($env:MC_HOST_TARGET)"
write-host "Evaluating Required Build and Release"

$content = Get-Content ./asdk-release/asdk-*.yml
$RELEASE = ($content | Where-Object { $_ -match "RELEASE:" }).Split(":")[1]
$BUILD = ($content | Where-Object { $_ -match "BUILD:" }).Split(":")[1]
If ($BUILD -eq "NONE") {
    $VERSION = $RELEASE
}
else {
    $VERSION = "$($RELEASE)-$($BUILD)"
}
Write-Host "Using ASDK $VERSION"

Write-Host "Copying files from TARGET/$($env:bucket)/$($VERSION)/"

./mc.exe cp --recursive "TARGET/$($env:bucket)/$($VERSION)/" ./cloudbuilder

$Files = Get-ChildItem -path cloudbuilder -Recurse
Write-Host ( $files | Out-String )
