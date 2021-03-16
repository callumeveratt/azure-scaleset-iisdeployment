$getKeyVaultAssignedIdentityToken = Invoke-RestMethod -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -Method GET -Headers @{Metadata="true"}
$keyVaultToken = $getKeyVaultAssignedIdentityToken.access_token
$getapplicationPoolPassword = Invoke-RestMethod -Uri https://UKS-SPMT-KV-DEPLOY.vault.azure.net/secrets/applicationPoolPassword?api-version=2016-10-01 -Method GET -Headers @{Authorization="Bearer $keyVaultToken"}
$applicationPoolPassword = $getapplicationPoolPassword.value

$password =  ConvertTo-SecureString $applicationPoolPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential("selenityazure\apppool-testing", $password)
$command = "powershell -ExecutionPolicy Unrestricted -File C:\DeployTemp\deploy\expenses.ps1"
Enable-PSRemoting –force
Invoke-Command -FilePath $command -Credential $credential -ComputerName $env:COMPUTERNAME
Disable-PSRemoting -Force
