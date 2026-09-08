-- ============================================================
-- MIGRATION: Tambah kolom poli ke tabel pendaftaran
-- Jalankan script ini SATU KALI di database Anda
-- ============================================================

-- 1. Tambah kolom poli di tabel pendaftaran
ALTER TABLE pendaftaran 
ADD COLUMN poli ENUM('umum', 'kebidanan') NOT NULL DEFAULT 'umum' 
AFTER keluhan;

-- 2. (Opsional) Update data lama agar terisi nilai 'umum'
UPDATE pendaftaran SET poli = 'umum' WHERE poli IS NULL OR poli = '';

-- 3. Verifikasi hasilnya
SELECT id, no_antrian, poli, tgl_daftar 
FROM pendaftaran 
ORDER BY id DESC 
LIMIT 10;
