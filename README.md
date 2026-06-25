# FamFinance Mobile

Aplikasi mobile Flutter untuk pencatatan keuangan keluarga dengan pola MVC sederhana dan koneksi langsung ke MySQL tanpa API.

Repository GitHub:

```text
https://github.com/zidanm120303/family-finance-mobile.git
```

## Fitur MVP

- Splash, login, register akun dan keluarga.
- Dashboard ringkas: total saldo, pemasukan bulan ini, pengeluaran bulan ini, 5 transaksi terbaru.
- Tambah transaksi pemasukan/pengeluaran dengan kategori, dompet, metode pembayaran, tanggal, dan catatan.
- Riwayat transaksi dengan search, filter bulan, tab semua/masuk/keluar, dan grouping per tanggal.
- Detail transaksi.
- Profil pengguna, informasi koneksi database, dan logout.

## Struktur

```text
lib/
+-- core/          # constants, database, helpers, session
+-- data/          # models dan repositories
+-- features/      # controller + page per fitur
+-- routes/        # route aplikasi
+-- widgets/       # reusable UI components
```

## Database

File SQL tersedia di folder `database/`:

- `family_finance_flyenv_dump.sql` untuk import database lengkap dari FlyEnv.
- `family_finance_mobile_mysql_schema.sql`
- `seed_minimal_mobile.sql`
- `direct_mysql_queries.sql`

Data login contoh setelah import dump:

```text
Email    : budi.pratama@email.com
Username : budi.pratama
Password : password
```

## Tutorial Instalasi Cepat

### 1. Clone repository

```bash
git clone https://github.com/zidanm120303/family-finance-mobile.git
cd family-finance-mobile
```

### 2. Install dependency Flutter

```bash
flutter pub get
```

### 3. Jalankan MySQL di FlyEnv

Pastikan service MySQL/FlyEnv aktif.

Default project memakai:

- Host lokal Windows: `127.0.0.1`
- Host emulator Android: `10.0.2.2`
- Port: `3306`
- Database: `family_finance`
- User/password FlyEnv: `root` / `root`

### 4. Import database dump

Dari root project, jalankan:

```powershell
.\scripts\import_database_flyenv.ps1
```

Jika password FlyEnv berbeda:

```powershell
.\scripts\import_database_flyenv.ps1 -User root -Password "password_anda"
```

### 5. Cek koneksi database

```bash
dart run tool/verify_flyenv_connection.dart
```

Jika berhasil, output akan menampilkan:

```text
FlyEnv MySQL connection OK
Database: family_finance
Transactions table: true
```

### 6. Jalankan aplikasi di emulator Android

```bash
flutter run -d emulator-5554
```

Atau jalankan dengan dart define manual:

```bash
flutter run \
  --dart-define=DB_HOST=10.0.2.2 \
  --dart-define=DB_PORT=3306 \
  --dart-define=DB_NAME=family_finance \
  --dart-define=DB_USER=root \
  --dart-define=DB_PASSWORD=root
```

Catatan: untuk emulator Android, `10.0.2.2` adalah alamat host Windows. Jangan pakai `localhost` dari emulator.

## Verifikasi

```bash
flutter analyze
flutter test
dart run tool/verify_flyenv_connection.dart
flutter test integration_test/db_connection_test.dart -d emulator-5554
flutter build apk --debug
```

APK debug dibuat di `build/app/outputs/flutter-apk/app-debug.apk`.

## Export Ulang Database

Jika data FlyEnv berubah dan ingin memperbarui dump:

```powershell
.\scripts\export_database_flyenv.ps1
```

## Menjalankan di HP Fisik

Jika menjalankan di HP fisik, FlyEnv/MySQL harus bind ke IP LAN dan firewall port 3306 harus terbuka.

Contoh:

```bash
flutter run \
  --dart-define=DB_HOST=192.168.1.10 \
  --dart-define=DB_PORT=3306 \
  --dart-define=DB_NAME=family_finance \
  --dart-define=DB_USER=root \
  --dart-define=DB_PASSWORD=root
```
