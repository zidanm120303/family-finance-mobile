# Database Dump

Folder ini berisi file SQL untuk menjalankan FamFinance Mobile dengan MySQL/FlyEnv.

## File Utama

- `family_finance_flyenv_dump.sql`

Dump lengkap database `family_finance` dari FlyEnv, termasuk schema dan data contoh.

## Data Login Contoh

```text
Email    : budi.pratama@email.com
Username : budi.pratama
Password : password
```

## Import Cepat

Dari root project:

```powershell
.\scripts\import_database_flyenv.ps1
```

Default script memakai konfigurasi FlyEnv lokal:

- Host: `127.0.0.1`
- Port: `3306`
- User: `root`
- Password: `root`
- Database: `family_finance`

Jika konfigurasi FlyEnv berbeda:

```powershell
.\scripts\import_database_flyenv.ps1 -HostName 127.0.0.1 -Port 3306 -User root -Password "password_anda"
```
