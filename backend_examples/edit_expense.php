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

if (
    !isset($data->expense_id) ||
    !isset($data->category_id) ||
    !isset($data->judul) ||
    !isset($data->amount) ||
    !isset($data->description) ||
    !isset($data->date)
) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Input tidak lengkap."]);
    exit();
}

$expense_id = $conn->real_escape_string($data->expense_id);
$category_id = $conn->real_escape_string($data->category_id);
$judul = $conn->real_escape_string($data->judul);
$amount = $conn->real_escape_string($data->amount);
$description = $conn->real_escape_string($data->description);
$date = $conn->real_escape_string($data->date);

$stmt = $conn->prepare("UPDATE expenses SET category_id = ?, judul = ?, amount = ?, description = ?, date = ? WHERE expense_id = ?");
if ($stmt === false) {
    http_response_code(500);
    die(json_encode(["status" => "error", "message" => "Gagal mempersiapkan statement: " . $conn->error]));
}

$stmt->bind_param("isdssi", $category_id, $judul, $amount, $description, $date, $expense_id);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        http_response_code(200);
        echo json_encode(["status" => "success", "message" => "Pengeluaran berhasil diperbarui."]);
    } else {
        http_response_code(200);
        echo json_encode(["status" => "success", "message" => "Tidak ada perubahan yang dilakukan."]);
    }
} else {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Gagal memperbarui pengeluaran: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
