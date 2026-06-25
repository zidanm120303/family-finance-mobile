param(
  [string]$MysqlDumpBin = "C:\Program Files\FlyEnv-Data\app\mysql-9.7.1\mysql-9.7.1-winx64\bin\mysqldump.exe",
  [string]$HostName = "127.0.0.1",
  [int]$Port = 3306,
  [string]$User = "root",
  [string]$Password = "root",
  [string]$Database = "family_finance",
  [string]$OutputPath = ".\database\family_finance_flyenv_dump.sql"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $MysqlDumpBin)) {
  throw "mysqldump.exe tidak ditemukan: $MysqlDumpBin"
}

Write-Host "Export database $Database dari MySQL $HostName`:$Port..."
$env:MYSQL_PWD = $Password
try {
  & $MysqlDumpBin `
    --host=$HostName `
    --port=$Port `
    --user=$User `
    --databases $Database `
    --single-transaction `
    --routines `
    --events `
    --triggers `
    --add-drop-table `
    --default-character-set=utf8mb4 `
    --set-gtid-purged=OFF `
    --result-file=$OutputPath

  if ($LASTEXITCODE -ne 0) {
    throw "Export database gagal. Exit code: $LASTEXITCODE"
  }
} finally {
  Remove-Item Env:\MYSQL_PWD -ErrorAction SilentlyContinue
}

Write-Host "Export selesai: $OutputPath"
