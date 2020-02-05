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
$expression="$($env:ASDK_FILE_DESTINATION)\AzureStackDevelopmentKit.exe /VERYSILENT /SUPPRESSMESGBOXES /DIR=`"$($env:ASDK_FILE_DESTINATION)`""
Write-Host "Now dehydrating Cloudbuilder using $expression"
$parameters = @{
    ScriptBlock  = { 
        write-host $args[0]
        invoke-expression -command $args[0]
    }  
    ArgumentList = "$expression"
    Session = $Session   
}

Write-Host ( $parameters | Out-String )
$result = Invoke-Command @parameters
Write-Host ( $result | Out-String )

