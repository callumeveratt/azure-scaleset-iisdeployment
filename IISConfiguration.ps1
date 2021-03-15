function InstallIISWindowsFeature() {
    # Add IIS as a Windows Feature
    Write-Host "IIS Windows Feature installation starting"
    Add-WindowsFeature -Name Web-Server -IncludeAllSubFeature

    # Remove X-Powered-By header from IIS (top level)
    Remove-WebConfigurationProperty -PSPath MACHINE/WEBROOT/APPHOST -Filter system.webServer/httpProtocol/customHeaders -Name . -AtElement @{name='X-Powered-By'}

    Write-Host "IIS Windows Feature installation complete"
}

function InstallIISModReWrite([string] $downloadFolder) {
    # Download https://www.iis.net/downloads/microsoft/url-rewrite and install
    $rewriteDownloadUrl = "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi"
    $rewriteDownloadPath = "$downloadFolder\rewrite_amd64_en-US.msi"
    DownloadFile -url $rewriteDownloadUrl -localPath $rewriteDownloadPath -sha256Hash "37342FF2F585F263F34F48E9DE59EB1051D61015A8E967DBDE4075716230A32A"
    InstallMsi -msiPath $rewriteDownloadPath    
}

$downloadFolder = "C:\Init\Downloads"

# Install IIS
InstallIISWindowsFeature -downloadFolder $downloadFolder

# Install url rewrite iis module
InstallIISModReWrite -downloadFolder $downloadFolder