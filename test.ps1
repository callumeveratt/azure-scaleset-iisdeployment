Import-Module WebAdministration
New-Item IIS:\AppPools\Expenses
Reset-IISServerManager -Confirm:$false
Start-IISCommitDelay
New-IISSite -Name 'Expenses' -PhysicalPath 'C:\Products\Expenses' -BindingInformation "*:8088:"
Stop-IISCommitDelay

Set-ItemProperty 'IIS:\Sites\Expenses' applicationPool Expenses
