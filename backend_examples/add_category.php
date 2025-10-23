<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$servername = "172.16.1.125";
$username = "root";
$password = "";
$dbname = "db_expense_app";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(["status" => "error", "message" => "Koneksi database gagal: " . $conn->connect_error]));
}

$data = json_decode(file_get_contents("php://input"));

if (!isset($data->name) || !isset($data->icon) || empty(trim($data->name)) || empty(trim($data->icon))) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Nama dan ikon kategori tidak boleh kosong."]);
    exit();
}

$name = $conn->real_escape_string(trim($data->name));
$icon = $conn->real_escape_string(trim($data->icon));

$stmt = $conn->prepare("INSERT INTO categories (name, icon) VALUES (?, ?)");
if ($stmt === false) {
    http_response_code(500);
    die(json_encode(["status" => "error", "message" => "Gagal mempersiapkan statement: " . $conn->error]));
}

$stmt->bind_param("ss", $name, $icon);

if ($stmt->execute()) {
    http_response_code(201);
    echo json_encode(["status" => "success", "message" => "Kategori berhasil ditambahkan."]);
} else {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Gagal menambahkan kategori: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
