$getKeyVaultAssignedIdentityToken = Invoke-RestMethod -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -Method GET -Headers @{Metadata="true"}
$keyVaultToken = $getKeyVaultAssignedIdentityToken.access_token
$getLocalAdminPassword = Invoke-RestMethod -Uri https://UKS-SPMT-KV-DEPLOY.vault.azure.net/secrets/serverLocalAdminPassword?api-version=2016-10-01 -Method GET -Headers @{Authorization="Bearer $keyVaultToken"}
$Password = $getLocalAdminPassword.value

$serverDeploymentScript = "C:\DeployTemp\deploy\deployServer.ps1"

# Set up server using tasks
$ConfigTaskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File $serverDeploymentScript"
$ConfigTaskTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(2); $ConfigTaskTrigger.EndBoundary = (Get-Date).AddSeconds(120).ToString('s')
$ConfigTaskSettings = New-ScheduledTaskSettingsSet -DeleteExpiredTaskAfter 00:00:30
Register-ScheduledTask -Force -User "SelAdmin" -Password $Password -TaskName "Configure Server" -Action $ConfigTaskAction -Trigger $ConfigTaskTrigger -Settings $ConfigTaskSettings
