# get mccli
Invoke-WebRequest https://dl.min.io/client/mc/release/windows-amd64/mc.exe -OutFile mc.exe


$protocol = Split-Path -Qualifier $env:endpoint


$target = $env:endpoint.Replace('//','').split(':')[1]
$env:MC_HOST_TARGET = "$($protocol)//$($env:access_key_id):$($env:secret_access_key)@$($target):9000"
# export MC_HOST_myalias=https://Q3AM3UQ867SPQQA43P2F:zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG@play.min.io
./mc.exe ls TARGET

./mc.exe cp --recursive "TARGET/$($env:bucket)/1910-58/" ./cloudbuilder

Get-ChildItem -path cloudbuilder -Recurse
