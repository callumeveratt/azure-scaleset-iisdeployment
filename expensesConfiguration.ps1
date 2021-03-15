$websiteName = "Expenses Application"
$websiteBasePath = "C:\Products\expenses"
$websiteLogsBasePath = "C:\Logs"
$vdBasePath = "C:\Products"
$applicationPoolName = $websiteName
$domainUser = "selenityazure\apppool-testing"

$getKeyVaultAssignedIdentityToken = Invoke-RestMethod -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -Method GET -Headers @{Metadata="true"}
$keyVaultToken = $getKeyVaultAssignedIdentityToken.access_token
$getapplicationPoolPassword = Invoke-RestMethod -Uri https://UKS-SPMT-KV-DEPLOY.vault.azure.net/secrets/applicationPoolPassword?api-version=2016-10-01 -Method GET -Headers @{Authorization="Bearer $keyVaultToken"}
$applicationPoolPassword = $getapplicationPoolPassword.value

$domainPassword = $applicationPoolPassword

$bindings = @(
    [Binding]::new("*", 80, "expenses.localhost")
    [Binding]::new("*", 80, "www.sel-expenses"),
    [Binding]::new("*", 80, "ont.sel-expenses"),
    [Binding]::new("*", 80, "rcvs.sel-expenses"),
    [Binding]::new("*", 80, "scor.sel-expenses"),
    [Binding]::new("*", 80, "api.sel-expenses"),
    [Binding]::new("*", 80, "localhost"),
    [Binding]::new("*", 80, "greenlight365"),
    [Binding]::new("*", 80, "nhsengland.sel-expenses"),
    [Binding]::new("*", 80, "tstmusa.sel-expenses"),
    [Binding]::new("*", 80, "acnmw.sel-expenses"),
    [Binding]::new("*", 80, "dfs.sel-expenses"),
    [Binding]::new("*", 80, "www.greenlight365"),
    [Binding]::new("*", 80, "gwh.sel-expenses"),
    [Binding]::new("*", 80, "fullers.sel-expenses"),
    [Binding]::new("*", 80, "arcadia.sel-expenses"),
    [Binding]::new("*", 80, "rcieurope.sel-expenses"),
    [Binding]::new("*", 80, "nice.sel-expenses"),
    [Binding]::new("*", 80, "sel-expenses"),
    [Binding]::new("*", 80, "live.sel-expenses"),
    [Binding]::new("*", 80, "riotgames.sel-expenses"),
    [Binding]::new("*", 80, "mab.sel-expenses"),
    [Binding]::new("*", 80, "heenon.sel-expenses"),
    [Binding]::new("*", 80, "www1.sel-expenses"),
    [Binding]::new("*", 80, "www2.sel-expenses"),
    [Binding]::new("*", 80, "www3.sel-expenses"),
    [Binding]::new("*", 80, "nice1.sel-expenses"),
    [Binding]::new("*", 80, "tenpin.sel-expenses"),
    [Binding]::new("*", 80, "create.sel-expenses"),
    [Binding]::new("*", 80, "saga.sel-expenses"),
    [Binding]::new("*", 80, "selenity-greenlight"),
    [Binding]::new("*", 80, "selenity-expenses"),
    [Binding]::new("*", 80, "www.selenity-expenses"),
    [Binding]::new("*", 80, "www.selenity-greenlight"),
    [Binding]::new("*", 80, "cnwl.sel-expenses"),
    [Binding]::new("*", 80, "chcp.sel-expenses"),
    [Binding]::new("*", 80, "ctb.sel-expenses"),
    [Binding]::new("*", 80, "cpccg.sel-expenses"),
    [Binding]::new("*", 80, "expenses-scaleset.sel-expenses.com")
)

$virtualDirectories = @(
    [VirtualDirectory]::new("/card_templates", $vdBasePath + "expenses\card_templates", $domainUser, $domainPassword),
    [VirtualDirectory]::new("/contracts", $vdBasePath + "Spend Management\contracts"),
    [VirtualDirectory]::new("/entityimages", $vdBasePath + "Spend Management\shared\tempCustomEntityImages", $domainUser, $domainPassword)
    [VirtualDirectory]::new("/expenses", $vdBasePath + "Spend Management\expenses"),
    #[VirtualDirectory]::new("/ig_common", "s:\products\Infragistics"),
    #[VirtualDirectory]::new("/logos", "\\spmtstoreexpense01.file.core.windows.net\content\Main\logos", $domainUser, $domainPassword),
    [VirtualDirectory]::new("/masters", $vdBasePath + "Spend Management\masters"),
    #[VirtualDirectory]::new("/policies", "\\spmtstoreexpense01.file.core.windows.net\content\Main\policies", $domainUser, $domainPassword),
    [VirtualDirectory]::new("/publicPages", $vdBasePath + "Spend Management\publicPages"),
    #[VirtualDirectory]::new("/receipts", "\\spmtstoreexpense01.file.core.windows.net\content\Main\Receipts", $domainUser, $domainPassword),
    #[VirtualDirectory]::new("/reportfiles", "\\10.0.6.132\product shared folders\Main\Reportfiles", $domainUser, $domainPassword),
    [VirtualDirectory]::new("/shared", $vdBasePath + "Spend Management\shared"),
    [VirtualDirectory]::new("/static", "C:\Init\Extracted\a\Static Content\StaticContent", $domainUser, $domainPassword),
    [VirtualDirectory]::new("/XmlImportMappings", $vdBasePath + "Spend Management\XMLImportMappings", $domainUser, $domainPassword)  
)

Write-Host("Creating Log Options class")
$logOptions = [LogOptions]::new("W3c", $websiteLogsBasePath, $true, "Daily")

Write-Host("Creating App Pool class")
$appPool = [ApplicationPool]::new($applicationPoolName, $domainUser, $domainPassword)

Write-Host("Reset IIS Server Manager")
Reset-IISServerManager -Confirm:$false

Start-IISCommitDelay

Write-Host("Get IIS Server Manager")
$iis = Get-IISServerManager

$createAppPoolResult = $appPool.Create($iis)

if ($createAppPoolResult -eq $true) {
    $website = [Website]::new($websiteName, 80, $websiteBasePath, $appPool, $virtualDirectories, $bindings, $logOptions)
    $createWebsiteResult = $website.Create($iis)

    if ($createWebsiteResult -eq $true) {
        $iis.CommitChanges()        
    }
}