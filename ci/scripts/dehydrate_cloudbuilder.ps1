$password = $env:ASDK_PASSWORD | ConvertTo-SecureString -AsPlainText -Force

$result = get-item  env:ASDK*
Write-Host ( $result | Out-String )

$result = Get-Item WSMan:\localhost\Client\TrustedHosts
Write-Host ( $result | Out-String )

$result = set-item WSman:\localhost\Client\TrustedHosts -value $env:ASDK_HOST -Force
Write-Host ( $result | Out-String )

$result = Get-Item WSMan:\localhost\Client\TrustedHosts
Write-Host ( $result | Out-String )

$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "Azurestack\Azurestackadmin", $password
$Session = New-PSSession -ComputerName $env:ASDK_HOST -Authentication Negotiate -Credential $credential
Write-Host ( $Session | Out-String )
Write-Host "Now dehydrating Cloudbuilder"
$parameters = @{
    ComputerName = $env:ASDK_HOST
    ScriptBlock  = { 
        $($args[0])\AzureStackDevelopmentKit.exe /VERYSILENT /SUPPRESSMESGBOXES /DIR="$($args[0])" 
    }  
    ArgumentList = "$env:ASDK_FILE_DESTINATION" 
    Session = $Session   
}

Write-Host ( $parameters | Out-String )
#$result = Invoke-Command @parameters
# Write-Host ( $result | Out-String )

