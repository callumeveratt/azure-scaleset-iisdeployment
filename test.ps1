New-WebAppPool -Name 'Expenses'
Reset-IISServerManager -Confirm:$false
Start-IISCommitDelay
$expensesSite = New-IISSite -Name 'Expenses' -PhysicalPath 'C:\Products\Expenses' -BindingInformation "*:8088:"
$expensesSite.Applications["/"].ApplicationPoolName = "Expenses"
Stop-IISCommitDelay
