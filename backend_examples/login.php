<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle preflight request (OPTIONS)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// --- Koneksi ke Database ---
$host = 'localhost';
$db_name = 'db_expense_app';
$username = 'root';
$password = '';
$conn = null;

try {
    $conn = new PDO("mysql:host=" . $host . ";dbname=" . $db_name, $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Koneksi Gagal: ' . $e->getMessage()]);
    exit();
}

// --- Logika Login ---

// 1. Ambil data JSON dari body request
$data = json_decode(file_get_contents("php://input"));

// 2. Validasi data input
if (!$data || empty($data->username) || empty($data->password)) {
    http_response_code(400); // Bad Request
    echo json_encode(['status' => 'error', 'message' => 'Username dan password tidak boleh kosong.']);
    exit();
}

$username_input = $data->username;
$password_input = $data->password;

try {
    // 3. Cari user berdasarkan username
    $query = "SELECT user_id, fullname, username, email, password FROM users WHERE username = :username";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':username', $username_input);
    $stmt->execute();

    // 4. Cek apakah user ditemukan
    if ($stmt->rowCount() > 0) {
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        // 5. Verifikasi password
        // PENTING: Ini adalah perbandingan password teks biasa.
        // Untuk produksi, gunakan password_hash() saat registrasi dan password_verify() di sini.
        if ($password_input === $user['password']) {
            // Password cocok, login berhasil
            
            // Hapus password dari array sebelum dikirim kembali
            unset($user['password']);

            http_response_code(200);
            echo json_encode([
                'status' => 'success',
                'message' => 'Login berhasil.',
                'user' => $user // Kirim data user
            ]);
        } else {
            // Password salah
            http_response_code(401); // Unauthorized
            echo json_encode(['status' => 'error', 'message' => 'Username atau password salah.']);
        }
    } else {
        // User tidak ditemukan
        http_response_code(401); // Unauthorized
        echo json_encode(['status' => 'error', 'message' => 'Username atau password salah.']);
    }

} catch (PDOException $e) {
    http_response_code(500); // Internal Server Error
    echo json_encode(['status' => 'error', 'message' => 'Terjadi kesalahan pada server: ' . $e->getMessage()]);
}

$conn = null; // Tutup koneksi
?>
