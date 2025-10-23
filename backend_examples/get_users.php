<?php
// Example get_users.php
// Copy this file to your XAMPP htdocs/expenseapp/get_users.php
// Make sure to update database connection credentials below.

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *'); // for local testing only

$DB_HOST = '192.168.100.138';
$DB_USER = 'root';
$DB_PASS = '';
$DB_NAME = 'expenseapp';

$mysqli = new mysqli($DB_HOST, $DB_USER, $DB_PASS, $DB_NAME);
if ($mysqli->connect_errno) {
    http_response_code(500);
    echo json_encode(['error' => 'Failed to connect to database', 'details' => $mysqli->connect_error]);
    exit;
}

$query = "SELECT user_id, username, password, email, fullname, tanggal_dibuat FROM users";
if ($result = $mysqli->query($query)) {
    $users = [];
    while ($row = $result->fetch_assoc()) {
        $users[] = $row;
    }
    echo json_encode($users);
    $result->free();
} else {
    http_response_code(500);
    echo json_encode(['error' => 'Query failed', 'details' => $mysqli->error]);
}

$mysqli->close();
