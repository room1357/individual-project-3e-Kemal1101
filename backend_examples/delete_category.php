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

if (!isset($data->category_id)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "ID kategori tidak ditemukan."]);
    exit();
}

$category_id = $conn->real_escape_string($data->category_id);

// Periksa apakah kategori masih digunakan di tabel expenses
$check_stmt = $conn->prepare("SELECT COUNT(*) as count FROM expenses WHERE category_id = ?");
$check_stmt->bind_param("i", $category_id);
$check_stmt->execute();
$result = $check_stmt->get_result();
$row = $result->fetch_assoc();
$check_stmt->close();

if ($row['count'] > 0) {
    http_response_code(409); // Conflict
    echo json_encode(["status" => "error", "message" => "Kategori tidak dapat dihapus karena masih digunakan dalam data pengeluaran."]);
    exit();
}

// Jika tidak digunakan, lanjutkan penghapusan
$delete_stmt = $conn->prepare("DELETE FROM categories WHERE category_id = ?");
if ($delete_stmt === false) {
    http_response_code(500);
    die(json_encode(["status" => "error", "message" => "Gagal mempersiapkan statement hapus: " . $conn->error]));
}

$delete_stmt->bind_param("i", $category_id);

if ($delete_stmt->execute()) {
    if ($delete_stmt->affected_rows > 0) {
        http_response_code(200);
        echo json_encode(["status" => "success", "message" => "Kategori berhasil dihapus."]);
    } else {
        http_response_code(404);
        echo json_encode(["status" => "error", "message" => "Kategori tidak ditemukan."]);
    }
} else {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Gagal menghapus kategori: " . $delete_stmt->error]);
}

$delete_stmt->close();
$conn->close();
?>
