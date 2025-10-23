<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$servername = "192.168.100.138";
$username = "root";
$password = "";
$dbname = "db_expense_app";

// Buat koneksi
$conn = new mysqli($servername, $username, $password, $dbname);

// Cek koneksi
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Koneksi gagal: " . $conn->connect_error]));
}

$sql = "SELECT category_id, name, icon FROM categories ORDER BY name";
$result = $conn->query($sql);

$categories = array();

if ($result->num_rows > 0) {
    // Ambil data dari setiap baris
    while($row = $result->fetch_assoc()) {
        $categories[] = $row;
    }
    echo json_encode($categories);
} else {
    echo json_encode([]);
}

$conn->close();
?>
