<?php
/**
 * ajax/search_pasien.php — versi aman
 * Pencarian pasien untuk Select2 / autocomplete.
 *
 * PERBAIKAN DARI VERSI LAMA:
 * - Tambah pengecekan session
 * - Pakai prepared statement (eliminasi SQL injection)
 * - Verifikasi CSRF via header X-CSRF-Token
 * - Batasi field yang dikembalikan
 */

require_once '../includes/security.php';
require_once '../config/database.php';

Security::init();
Security::requireLogin();
Security::requireAjax();

// Verifikasi CSRF token dari header (dikirim JS)
Security::verifyCsrf($_SERVER['HTTP_X_CSRF_TOKEN'] ?? null, true);

header('Content-Type: application/json');

$db   = new Database();
$conn = $db->getConnection();

$term         = Security::clean($_GET['q'] ?? '');
$term_no_dash = str_replace('-', '', $term);

if (strlen($term) < 2) {
    echo json_encode([]);
    exit;
}

$like         = '%' . $term . '%';
$like_no_dash = '%' . $term_no_dash . '%';

$stmt = mysqli_prepare($conn,
    "SELECT id, no_rm, nama_lengkap, jenis_pasien, no_bpjs, nama_asuransi,
            no_polis, nik, alamat, kepala_keluarga, tgl_lahir, jenis_kelamin, no_telepon
     FROM pasien
     WHERE no_rm LIKE ?
        OR REPLACE(no_rm, '-', '') LIKE ?
        OR nama_lengkap LIKE ?
        OR nik LIKE ?
        OR kepala_keluarga LIKE ?
     ORDER BY id ASC
     LIMIT 20"
);
mysqli_stmt_bind_param($stmt, 'sssss', $like, $like_no_dash, $like, $like, $like);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);

$data = [];
while ($row = mysqli_fetch_assoc($result)) {
    $data[] = $row;
}
mysqli_stmt_close($stmt);

echo json_encode($data);
