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

$servername = "192.168.100.138";
$username = "root";
$password = "";
$dbname = "db_expense_app";

// Buat koneksi
$conn = new mysqli($servername, $username, $password, $dbname);

// Cek koneksi
if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(["status" => "error", "message" => "Koneksi database gagal: " . $conn->connect_error]));
}

// Ambil data JSON dari body request
$data = json_decode(file_get_contents("php://input"));

// Validasi data input
if (
    !isset($data->user_id) ||
    !isset($data->category_id) ||
    !isset($data->judul) || // Ditambahkan
    !isset($data->amount) ||
    !isset($data->description) ||
    !isset($data->date)
) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Input tidak lengkap."]);
    exit();
}

$user_id = $conn->real_escape_string($data->user_id);
$category_id = $conn->real_escape_string($data->category_id);
$judul = $conn->real_escape_string($data->judul); // Ditambahkan
$amount = $conn->real_escape_string($data->amount);
$description = $conn->real_escape_string($data->description);
$date = $conn->real_escape_string($data->date);

// Query menggunakan prepared statement untuk keamanan
$stmt = $conn->prepare("INSERT INTO expenses (user_id, category_id, judul, amount, description, date) VALUES (?, ?, ?, ?, ?, ?)");
if ($stmt === false) {
    http_response_code(500);
    die(json_encode(["status" => "error", "message" => "Gagal mempersiapkan statement: " . $conn->error]));
}

$stmt->bind_param("iisdss", $user_id, $category_id, $judul, $amount, $description, $date);

if ($stmt->execute()) {
    http_response_code(201); // Created
    echo json_encode(["status" => "success", "message" => "Pengeluaran berhasil ditambahkan."]);
} else {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Gagal menambahkan pengeluaran: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
