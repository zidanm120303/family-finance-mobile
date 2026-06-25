param(
  [string]$MysqlBin = "C:\Program Files\FlyEnv-Data\app\mysql-9.7.1\mysql-9.7.1-winx64\bin\mysql.exe",
  [string]$HostName = "127.0.0.1",
  [int]$Port = 3306,
  [string]$User = "root",
  [string]$Password = "root",
  [string]$DumpPath = ".\database\family_finance_flyenv_dump.sql"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $MysqlBin)) {
  throw "mysql.exe tidak ditemukan: $MysqlBin"
}

if (-not (Test-Path -LiteralPath $DumpPath)) {
  throw "File dump tidak ditemukan: $DumpPath"
}

Write-Host "Import database dari $DumpPath ke MySQL $HostName`:$Port sebagai user $User..."
$env:MYSQL_PWD = $Password
try {
  Get-Content -LiteralPath $DumpPath -Raw |
    & $MysqlBin --host=$HostName --port=$Port --user=$User --default-character-set=utf8mb4
  if ($LASTEXITCODE -ne 0) {
    throw "Import database gagal. Exit code: $LASTEXITCODE"
  }
} finally {
  Remove-Item Env:\MYSQL_PWD -ErrorAction SilentlyContinue
}

Write-Host "Import selesai. Database family_finance siap dipakai."
