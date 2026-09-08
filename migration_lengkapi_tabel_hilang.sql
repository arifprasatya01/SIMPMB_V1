-- ============================================================
-- MIGRASI: Melengkapi tabel yang DIPAKAI OLEH KODE PHP
-- tapi TIDAK ADA di file u110515328_mitra_galuh.sql yang diupload
-- ============================================================
-- PENTING - BACA DULU SEBELUM DIJALANKAN:
-- File .sql yang diupload berasal dari akun "u110515328_..."
-- sedangkan .env aplikasi menunjuk ke database "u297738695_klinik_dummy".
-- Jadi ada kemungkinan besar tabel-tabel di bawah ini SUDAH ADA
-- di database asli/produksi kamu, dan hanya tidak ikut ter-export
-- ke dalam file dump yang diupload ke sini.
--
-- SEBELUM MENJALANKAN SCRIPT INI:
-- 1. Cek dulu ke database production/live kamu apakah tabel-tabel
--    berikut sudah ada: master_bhp, detail_bhp, pembelian_bhp,
--    detail_pembelian_bhp, jasa_bidan, log_aktivitas,
--    pengeluaran_manual, unit, antrian.
-- 2. Kalau SUDAH ada -> file ini TIDAK PERLU dijalankan.
-- 3. Kalau BELUM ada (mis. untuk setup database baru / testing)
--    -> jalankan file ini SATU KALI setelah import
--    u110515328_mitra_galuh.sql.
--
-- Struktur di bawah ini disusun dengan menelusuri SEMUA query
-- INSERT/SELECT/UPDATE ke tabel-tabel tsb di seluruh source code
-- (gudang.php, medis.php, kasir.php, finance.php, dashboard.php,
-- laporan_kunjungan.php, laporan_pengeluaran_obat.php,
-- includes/functions.php, ajax/search_bhp.php, folder antrian/),
-- jadi kolomnya sudah pasti dipakai kode. Tipe data disamakan
-- dengan gaya tabel sejenis yang sudah ada (obat, pembelian,
-- detail_pembelian) agar konsisten.
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ── master_bhp: dipakai gudang.php, medis.php, laporan_kunjungan.php,
--                laporan_pengeluaran_obat.php, ajax/search_bhp.php ──
CREATE TABLE IF NOT EXISTS `master_bhp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kode_bhp` varchar(20) NOT NULL,
  `nama_bhp` varchar(100) NOT NULL,
  `satuan` varchar(20) NOT NULL,
  `stok` int(11) DEFAULT 0,
  `harga` decimal(10,2) DEFAULT 0.00,
  `stok_minimum` int(11) DEFAULT 5,
  `aktif` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `kode_bhp` (`kode_bhp`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- ── detail_bhp: dipakai medis.php (input BHP per pemeriksaan) ──
CREATE TABLE IF NOT EXISTS `detail_bhp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pemeriksaan_id` int(11) NOT NULL,
  `bhp_id` int(11) NOT NULL,
  `jumlah` int(11) NOT NULL,
  `harga` decimal(10,2) NOT NULL DEFAULT 0.00,
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `keterangan` varchar(255) DEFAULT NULL,
  `hapus` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `pemeriksaan_id` (`pemeriksaan_id`),
  KEY `bhp_id` (`bhp_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- ── pembelian_bhp: dipakai gudang.php (penerimaan BHP dari supplier) ──
CREATE TABLE IF NOT EXISTS `pembelian_bhp` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `no_pembelian` varchar(20) NOT NULL,
  `supplier_id` int(10) UNSIGNED NOT NULL,
  `tgl_pembelian` date NOT NULL,
  `tgl_jatuh_tempo` date DEFAULT NULL,
  `jatuh_tempo_hari` int(11) DEFAULT 30,
  `no_faktur` varchar(100) DEFAULT NULL,
  `total_pembelian` decimal(12,2) NOT NULL DEFAULT 0.00,
  `ppn_persen` decimal(5,2) DEFAULT 0.00,
  `nilai_ppn` decimal(15,2) DEFAULT 0.00,
  `total_dengan_ppn` decimal(15,2) DEFAULT 0.00,
  `sisa_pembayaran` decimal(12,2) DEFAULT 0.00,
  `user_id` int(10) UNSIGNED NOT NULL,
  `keterangan` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `supplier_id` (`supplier_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- ── detail_pembelian_bhp: rincian item per pembelian_bhp ──
CREATE TABLE IF NOT EXISTS `detail_pembelian_bhp` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `pembelian_bhp_id` int(10) UNSIGNED NOT NULL,
  `bhp_id` int(11) NOT NULL,
  `jumlah` int(11) NOT NULL,
  `harga_beli` decimal(10,2) NOT NULL,
  `subtotal` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `pembelian_bhp_id` (`pembelian_bhp_id`),
  KEY `bhp_id` (`bhp_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- ── jasa_bidan: dipakai kasir.php & dashboard.php (jasa tindakan bidan per pembayaran) ──
CREATE TABLE IF NOT EXISTS `jasa_bidan` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pembayaran_id` int(11) NOT NULL,
  `jumlah` decimal(12,2) NOT NULL DEFAULT 0.00,
  `status_batal_bayar` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `pembayaran_id` (`pembayaran_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- ── log_aktivitas: dipakai includes/functions.php -> logAktivitas() ──
CREATE TABLE IF NOT EXISTS `log_aktivitas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `aktivitas` varchar(100) NOT NULL,
  `keterangan` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- ── pengeluaran_manual: dipakai finance.php (buku kas / pengeluaran non-obat) ──
CREATE TABLE IF NOT EXISTS `pengeluaran_manual` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tgl_transaksi` date NOT NULL,
  `keterangan` varchar(255) NOT NULL,
  `nominal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `kategori` varchar(50) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- ── unit: dipakai modul antrian/ (nama poli/loket untuk panel panggil) ──
CREATE TABLE IF NOT EXISTS `unit` (
  `kd_unit` int(11) NOT NULL AUTO_INCREMENT,
  `nama_unit` varchar(100) NOT NULL,
  `kd_prefix` varchar(5) NOT NULL COMMENT 'awalan nomor antrian, mis. U, K',
  `status_aktif` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`kd_unit`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Isi data unit dasar (sesuaikan dengan poli yang dipakai di pendaftaran.php: umum & kebidanan)
INSERT INTO `unit` (`kd_unit`, `nama_unit`, `kd_prefix`, `status_aktif`) VALUES
(1, 'Poli Umum', 'U', 1),
(2, 'Poli Kebidanan', 'K', 1)
ON DUPLICATE KEY UPDATE nama_unit = VALUES(nama_unit), kd_prefix = VALUES(kd_prefix);

-- ── antrian: dipakai modul antrian/ (get_antrian.php, ambil_antrian.php, display_antrian.php) ──
-- Struktur diambil dari dokumentasi di dalam antrian/get_antrian.php
CREATE TABLE IF NOT EXISTS `antrian` (
  `kd_antrian` varchar(20) NOT NULL,
  `kd_unit` int(11) NOT NULL,
  `nomor_antrian` int(11) NOT NULL,
  `nomor_lengkap` varchar(20) NOT NULL,
  `waktu_ambil` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '1=menunggu, 2=dipanggil, 3=selesai',
  `tanggal` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`kd_antrian`),
  KEY `kd_unit` (`kd_unit`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

SET FOREIGN_KEY_CHECKS = 1;
