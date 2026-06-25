-- seed_minimal_mobile.sql
USE family_finance;

INSERT IGNORE INTO roles (role_name, description, created_at, updated_at)
VALUES
('Kepala Keluarga', 'Pengguna utama keluarga / Ayah', NOW(), NOW()),
('Ibu', 'Pengguna ibu rumah tangga', NOW(), NOW());

-- Kategori dan wallet default dibuat setelah register karena membutuhkan family_id.
-- Password user dummy sebaiknya dibuat oleh aplikasi sesuai hash yang dipakai.
