Import-Module WebAdministration
New-Item IIS:\AppPools\Expenses
Reset-IISServerManager -Confirm:$false
Start-IISCommitDelay
$expensesSite = New-IISSite -Name 'Expenses' -PhysicalPath 'C:\Products\Expenses' -BindingInformation "*:8088:"
$expensesSite.ApplicationPoolName = "Expenses"
Stop-IISCommitDelay
