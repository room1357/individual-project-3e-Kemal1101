<?php
// Example register_user.php
// Copy this file to your XAMPP htdocs/expenseapp/register_user.php
// Make sure to update database connection credentials below.

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *'); // for local testing only
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

$DB_HOST = '172.16.1.125';
$DB_USER = 'root';
$DB_PASS = '';
$DB_NAME = 'expenseapp';

$mysqli = new mysqli($DB_HOST, $DB_USER, $DB_PASS, $DB_NAME);
if ($mysqli->connect_errno) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Failed to connect to database']);
    exit;
}

// Read POST data
$fullname = isset($_POST['fullname']) ? trim($_POST['fullname']) : '';
$username = isset($_POST['username']) ? trim($_POST['username']) : '';
$email = isset($_POST['email']) ? trim($_POST['email']) : '';
$password = isset($_POST['password']) ? trim($_POST['password']) : '';

if ($fullname === '' || $username === '' || $email === '' || $password === '') {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Missing required fields']);
    exit;
}

// Check if username already exists
if ($stmt = $mysqli->prepare('SELECT user_id FROM users WHERE username = ? LIMIT 1')) {
    $stmt->bind_param('s', $username);
    $stmt->execute();
    $stmt->store_result();
    if ($stmt->num_rows > 0) {
        echo json_encode(['success' => false, 'error' => 'Username already exists']);
        $stmt->close();
        $mysqli->close();
        exit;
    }
    $stmt->close();
} else {
    echo json_encode(['success' => false, 'error' => 'Database error']);
    $mysqli->close();
    exit;
}

// Insert new user (note: password stored in plain text here for simplicity; consider hashing)
if ($stmt = $mysqli->prepare('INSERT INTO users (username, password, email, fullname, tanggal_dibuat) VALUES (?, ?, ?, ?, NOW())')) {
    $stmt->bind_param('ssss', $username, $password, $email, $fullname);
    if ($stmt->execute()) {
        echo json_encode(['success' => true]);
    } else {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => 'Insert failed']);
    }
    $stmt->close();
} else {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Prepare failed']);
}

$mysqli->close();
