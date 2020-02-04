# get mccli
Invoke-WebRequest https://dl.min.io/client/mc/release/windows-amd64/mc.exe -OutFile mc.exe

$env:MC_HOST_TARGET="http://$($env:access_key_id):$($env:secret_access_key)@$($env:endpoint)"
# export MC_HOST_myalias=https://Q3AM3UQ867SPQQA43P2F:zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG@play.min.io
./mc.exe ls TARGET


Get-ChildItem -Directory -Recurse
