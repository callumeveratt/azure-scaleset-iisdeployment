$getKeyVaultAssignedIdentityToken = Invoke-RestMethod -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -Method GET -Headers @{Metadata="true"}
$keyVaultToken = $getKeyVaultAssignedIdentityToken.access_token
$getdomainPassword = Invoke-RestMethod -Uri https://UKS-SPMT-KV-DEPLOY.vault.azure.net/secrets/applicationPoolPassword?api-version=2016-10-01 -Method GET -Headers @{Authorization="Bearer $keyVaultToken"}
$domainPassword = $getdomainPassword.value

$domain = "selenityazure.com"
$username =  "selenityazure\apppool-testing"
$password = $domainPassword | ConvertTo-SecureString -asPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $password)
Add-Computer -DomainName $domain -Credential $credential -Force

$expensesDeploymentScript = "C:\DeployTemp\deploy\expenses.ps1"

# Restart to complete domain join
$ConfigTaskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-file $expensesDeploymentScript"
$ConfigTaskTrigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay 00:00:30
Register-ScheduledTask -Force -User $username -Password $domainPassword -TaskName "Configure IIS Sites" -Action $ConfigTaskAction -Trigger $ConfigTaskTrigger


# Restart to complete domain join
$RestartTaskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-command &{Restart-Computer -Force}"
$RestartTaskTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(3); $RestartTaskTrigger.EndBoundary = (Get-Date).AddSeconds(60).ToString('s')
$RestartTaskSettings = New-ScheduledTaskSettingsSet -DeleteExpiredTaskAfter 00:00:30
Register-ScheduledTask -Force -User SYSTEM -TaskName "Restart to Join Domain" -Action $RestartTaskAction -Trigger $RestartTaskTrigger -Settings $RestartTaskSettings
