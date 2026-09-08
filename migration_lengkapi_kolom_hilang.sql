-- ============================================================
-- MIGRASI: Melengkapi KOLOM yang hilang di tabel yang SUDAH ADA
-- ============================================================
-- Beda dengan migration_lengkapi_tabel_hilang.sql (yang menambah
-- TABEL baru), file ini menambah KOLOM ke tabel yang sudah ada
-- di u110515328_mitra_galuh.sql tapi kolomnya kurang.
--
-- Ini ditemukan dengan membandingkan SETIAP pernyataan INSERT/UPDATE
-- di kode terhadap kolom yang benar-benar ada di dump SQL. Tanpa
-- kolom-kolom ini, query yang bersangkutan akan gagal dengan error
-- MySQL "Unknown column 'x' in field list".
--
-- Jalankan SATU KALI. Aman dijalankan berulang karena pakai
-- pengecekan IF NOT EXISTS lewat prosedur di bawah (MySQL tidak
-- punya ADD COLUMN IF NOT EXISTS native di versi lama, jadi
-- dibungkus prosedur sederhana).
-- ============================================================

DELIMITER $$
DROP PROCEDURE IF EXISTS _tambah_kolom_jika_belum_ada $$
CREATE PROCEDURE _tambah_kolom_jika_belum_ada(
    IN p_table VARCHAR(64),
    IN p_column VARCHAR(64),
    IN p_definition VARCHAR(255)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table
          AND COLUMN_NAME = p_column
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table, '` ADD COLUMN ', p_definition);
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END $$
DELIMITER ;

-- ── pasien.kepala_keluarga ──
-- dipakai pendaftaran.php saat tambah & edit data pasien (form KK/nama kepala keluarga)
CALL _tambah_kolom_jika_belum_ada('pasien', 'kepala_keluarga',
    '`kepala_keluarga` varchar(100) DEFAULT NULL AFTER `alamat`');

-- ── pendaftaran.pemeriksaan_fisik ──
-- dipakai pendaftaran.php saat mendaftarkan pasien (catatan pemeriksaan fisik awal)
CALL _tambah_kolom_jika_belum_ada('pendaftaran', 'pemeriksaan_fisik',
    '`pemeriksaan_fisik` text DEFAULT NULL AFTER `keluhan`');

-- ── detail_resep.hapus ──
-- kolom soft-delete ini SUDAH ADA di tabel-tabel terkait (resep, pemeriksaan,
-- detail_tindakan) tapi hilang di detail_resep, padahal medis.php insert dengan kolom ini
CALL _tambah_kolom_jika_belum_ada('detail_resep', 'hapus',
    '`hapus` tinyint(1) NOT NULL DEFAULT 0 AFTER `aturan_pakai`');

-- ── penjualan_grosir.diskon & total_setelah_diskon ──
-- tabel kembarnya (penjualan_langsung, pembayaran) sudah punya 2 kolom ini,
-- tapi penjualan_grosir belum, padahal kasir.php insert dengan kedua kolom ini
CALL _tambah_kolom_jika_belum_ada('penjualan_grosir', 'diskon',
    '`diskon` decimal(12,2) NOT NULL DEFAULT 0.00 AFTER `total_bayar`');
CALL _tambah_kolom_jika_belum_ada('penjualan_grosir', 'total_setelah_diskon',
    '`total_setelah_diskon` decimal(12,2) NOT NULL DEFAULT 0.00 AFTER `diskon`');

-- ── pembayaran.pemeriksaan_id ──
-- kasir.php insert ke pembayaran dengan resep_id DAN pemeriksaan_id sekaligus,
-- tapi tabel pembayaran cuma punya kolom resep_id
CALL _tambah_kolom_jika_belum_ada('pembayaran', 'pemeriksaan_id',
    '`pemeriksaan_id` int(11) DEFAULT NULL AFTER `resep_id`');

DROP PROCEDURE IF EXISTS _tambah_kolom_jika_belum_ada;
