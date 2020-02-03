$password = $env:ASDK_PASSWORD | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $env:ASDK_USERNAME, $password
Enter-PSSession -ComputerName $env:ASDK_HOST -Authentication Negotiate -Credential $credential    