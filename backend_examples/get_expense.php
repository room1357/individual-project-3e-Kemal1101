<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle preflight request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "db_expense_app";

// Buat koneksi
$conn = new mysqli($servername, $username, $password, $dbname);

// Cek koneksi
if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(["status" => "error", "message" => "Koneksi gagal: " . $conn->connect_error]));
}

// Ambil user_id dari query parameter
$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;

// Ambil parameter tahun dan bulan, jika tidak ada, gunakan tahun dan bulan saat ini
$year = isset($_GET['year']) ? intval($_GET['year']) : date('Y');
$month = isset($_GET['month']) ? intval($_GET['month']) : date('m');

if ($user_id <= 0) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "User ID tidak valid."]);
    $conn->close();
    exit();
}

// Cek apakah parameter 'all' ada
$fetchAll = isset($_GET['all']) && $_GET['all'] == 'true';

if ($fetchAll) {
    // Query untuk mengambil semua data pengeluaran tanpa filter bulan/tahun
    $sql = "SELECT 
                e.expense_id, e.user_id, e.category_id, e.judul, e.amount, 
                e.description, e.date, c.name AS category_name, c.icon AS category_icon
            FROM expenses e
            JOIN categories c ON e.category_id = c.category_id
            WHERE e.user_id = ?
            ORDER BY e.date DESC, e.expense_id DESC";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $user_id);
} else {
    // Query untuk mengambil data pengeluaran dengan filter bulan dan tahun
    $sql = "SELECT 
                e.expense_id, e.user_id, e.category_id, e.judul, e.amount, 
                e.description, e.date, c.name AS category_name, c.icon AS category_icon
            FROM expenses e
            JOIN categories c ON e.category_id = c.category_id
            WHERE e.user_id = ? AND YEAR(e.date) = ? AND MONTH(e.date) = ?
            ORDER BY e.date DESC, e.expense_id DESC";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("iii", $user_id, $year, $month);
}
$stmt->execute();
$result = $stmt->get_result();

$expenses = array();

if ($result->num_rows > 0) {
    // Ambil data dari setiap baris
    while($row = $result->fetch_assoc()) {
        // Konversi tipe data jika perlu
        $row['expense_id'] = intval($row['expense_id']);
        $row['user_id'] = intval($row['user_id']);
        $row['category_id'] = intval($row['category_id']);
        $row['amount'] = floatval($row['amount']);
        $expenses[] = $row;
    }
    http_response_code(200);
    echo json_encode($expenses);
} else {
    http_response_code(200);
    echo json_encode([]); // Kembalikan array kosong jika tidak ada data
}

$stmt->close();
$conn->close();
?>
