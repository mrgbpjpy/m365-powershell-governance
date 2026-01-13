param([string]$CsvPath="users-sample.csv",[switch]$DryRun=$true)
$users = Import-Csv $CsvPath
$out=@()
foreach($u in $users){
  $action = if($DryRun){"DRY-RUN create $($u.Email)"}else{"Create $($u.Email)"}
  $out += [pscustomobject]@{User=$u.Email; Action=$action; Date="2026-01-13"}
}
$out | Export-Csv "output-sample.csv" -NoTypeInformation
Write-Host "Provisioning report generated."
