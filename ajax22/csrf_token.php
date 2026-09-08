<?php
/**
 * ajax/csrf_token.php
 * ────────────────────────────────────────────────────────────
 * Endpoint untuk refresh/ambil CSRF token via AJAX.
 *
 * Digunakan saat token expired atau untuk SPA-style refresh.
 *
 * Cara panggil dari JS:
 *   fetch('ajax/csrf_token.php', { credentials: 'same-origin' })
 *     .then(r => r.json())
 *     .then(d => { window._csrf = d.token; });
 */

require_once '../includes/security.php';

Security::init();
Security::requireLogin();
Security::requireAjax();

header('Content-Type: application/json');
echo json_encode(['token' => Security::getCsrfToken()]);
