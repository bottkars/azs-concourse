$password = $env:ASDK_PASSWORD | ConvertTo-SecureString -AsPlainText -Force

$result=get-item env:ASDK*
Write-Host ( $result | Out-String )

$result=Get-Item WSMan:\localhost\Client\TrustedHosts
Write-Host ( $result | Out-String )

$result=set-item WSman:\localhost\Client\TrustedHosts -value $env:ASDK_HOST -Force
Write-Host ( $result | Out-String )

$result=Get-Item WSMan:\localhost\Client\TrustedHosts
Write-Host ( $result | Out-String )

$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "Azurestack\Azurestackadmin", $password
$Session = New-PSSession -ComputerName $env:ASDK_HOST -Authentication Negotiate -Credential $credential
Write-Host ( $Session | Out-String )

$parameters = @{
    ScriptBlock = { 
    set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 00000000 
    set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 00000000 
    Remove-Item $args[0] -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $args[0] -Force }  
    ArgumentList = "$env:ASDK_FILE_DESTINATION"
    Session = $Session   
}

Write-Host ( $parameters | Out-String )
$result = Invoke-Command @parameters
Write-Host ( $result | Out-String )

# $BitsTarget = $env:ASDK_FILE_DESTINATION -replace ":\","$"
write-host "Now copying ASDK"
# Start-BitsTransfer -Source /cloudbuilder/* -Destination "\\$($env:ASDK_HOST)\$BITS_TARGET" -TransferType      -Credential $credCopy-Item ./cloudbuilder/* -Recurse -Destination $env:ASDK_FILE_DESTINATION -ToSession $Session
$result = Copy-Item ./cloudbuilder/* -Recurse -Destination $env:ASDK_FILE_DESTINATION -ToSession $Session

Write-Host ( $result | Out-String )
Write-Host "Now dehydrating Cloudbuilder"