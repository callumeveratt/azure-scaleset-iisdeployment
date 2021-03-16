Start-IISCommitDelay
New-WebAppPool -Name 'Expenses'
$expensesSite = New-IISSite -Name 'Expenses' -PhysicalPath 'C:\Products\Expenses' -BindingInformation "*:8088:"
$expensesSite.Applications["/"].ApplicationPoolName = "Expenses"
Stop-IISCommitDelay
