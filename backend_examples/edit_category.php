<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-control-allow-headers: Content-Type, Authorization");
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

if (!isset($data->category_id) || !isset($data->name) || !isset($data->icon) || empty(trim($data->name)) || empty(trim($data->icon))) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Input tidak lengkap atau nama/ikon kategori kosong."]);
    exit();
}

$category_id = intval($data->category_id);
$name = $conn->real_escape_string(trim($data->name));
$icon = $conn->real_escape_string(trim($data->icon));

$stmt = $conn->prepare("UPDATE categories SET name = ?, icon = ? WHERE category_id = ?");
if ($stmt === false) {
    http_response_code(500);
    die(json_encode(["status" => "error", "message" => "Gagal mempersiapkan statement: " . $conn->error]));
}

$stmt->bind_param("ssi", $name, $icon, $category_id);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        http_response_code(200);
        echo json_encode(["status" => "success", "message" => "Kategori berhasil diperbarui."]);
    } else {
        http_response_code(200);
        echo json_encode(["status" => "success", "message" => "Tidak ada perubahan yang dilakukan."]);
    }
} else {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Gagal memperbarui kategori: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
