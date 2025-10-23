# Aplikasi Pencatat Pengeluaran (Expense Tracker)

![Flutter](https://img.shields.io/badge/Framework-Flutter-02569B?style=for-the-badge&logo=flutter)
![PHP](https://img.shields.io/badge/Backend-PHP-777BB4?style=for-the-badge&logo=php)
![MySQL](https://img.shields.io/badge/Database-MySQL-4479A1?style=for-the-badge&logo=mysql)

**Expense Tracker** adalah aplikasi mobile lintas platform yang dibangun menggunakan Flutter untuk membantu pengguna melacak dan mengelola pengeluaran harian mereka. Aplikasi ini dirancang dengan antarmuka yang bersih dan intuitif, serta dilengkapi dengan backend sederhana yang dibuat menggunakan PHP dan database MySQL untuk menyimpan dan mengelola data.

## Screenshots

| Login & Register | Daftar Pengeluaran | Statistik |
| :---: | :---: | :---: |
| ![Login Screen](https://user-images.githubusercontent.com/example/login.png) | ![Expense List](https://user-images.githubusercontent.com/example/list.png) | ![Statistics](https://user-images.githubusercontent.com/example/stats.png) |
| *Tampilan login dan registrasi pengguna.* | *Menampilkan semua riwayat pengeluaran dengan filter.* | *Visualisasi data pengeluaran dalam bentuk diagram lingkaran.* |

*(Catatan: Gambar di atas adalah placeholder. Anda dapat menggantinya dengan screenshot aplikasi Anda sendiri.)*

## 🚀 Fitur Utama

-   **Autentikasi Pengguna**: Sistem registrasi dan login yang aman untuk setiap pengguna.
-   **Manajemen Pengeluaran (CRUD)**: Tambah, lihat, ubah, dan hapus data pengeluaran dengan mudah.
-   **Manajemen Kategori**: Pengguna dapat mengelola kategori pengeluaran mereka sendiri.
-   **Pencatatan Riwayat**: Semua pengeluaran dicatat dan ditampilkan dalam daftar yang terorganisir.
-   **Pencarian & Filter**:
    -   Cari pengeluaran berdasarkan nama atau deskripsi.
    -   Filter pengeluaran berdasarkan kategori.
    -   Filter pengeluaran berdasarkan bulan dan tahun.
-   **Statistik Visual**:
    -   Diagram lingkaran (Pie Chart) untuk memvisualisasikan persentase pengeluaran per kategori.
    -   Ringkasan total pengeluaran.
    -   Filter data statistik berdasarkan bulan dan tahun.
-   **Desain Intuitif**: Antarmuka yang bersih dan mudah digunakan untuk pengalaman pengguna yang lebih baik.

## 🛠️ Tumpukan Teknologi

### Frontend (Mobile App)
-   **Framework**: Flutter
-   **Bahasa**: Dart
-   **Manajemen State**: `setState` (StatefulWidget)
-   **HTTP Client**: `http` package untuk komunikasi dengan API.
-   **Grafik/Chart**: `fl_chart` untuk membuat diagram statistik.
-   **Format**: `intl` untuk format mata uang dan tanggal.

### Backend (Server-side)
-   **Bahasa**: PHP
-   **Database**: MySQL / MariaDB
-   **Web Server**: Apache (biasanya menggunakan XAMPP/MAMP/LAMP).

---

## ⚙️ Panduan Instalasi dan Konfigurasi

Untuk menjalankan proyek ini di lingkungan lokal Anda, ikuti langkah-langkah berikut:

### 1. Backend (PHP & MySQL)

1.  **Instal Web Server**: Pastikan Anda memiliki web server seperti **XAMPP** atau sejenisnya yang sudah terinstal dan berjalan.
2.  **Pindahkan File Backend**: Salin semua file dari direktori `backend_examples` ke dalam folder `htdocs` di dalam direktori instalasi XAMPP Anda (misalnya: `C:\xampp\htdocs\expenseapp`).
3.  **Buat Database**:
    -   Buka **phpMyAdmin** (`http://localhost/phpmyadmin`).
    -   Buat database baru dengan nama `db_expense_app`.
4.  **Buat Tabel**: Jalankan query SQL berikut di database `db_expense_app` untuk membuat tabel yang diperlukan.

    ```sql
    CREATE TABLE `users` (
      `user_id` int(11) NOT NULL AUTO_INCREMENT,
      `full_name` varchar(100) NOT NULL,
      `username` varchar(50) NOT NULL,
      `email` varchar(100) NOT NULL,
      `password` varchar(255) NOT NULL,
      PRIMARY KEY (`user_id`),
      UNIQUE KEY `username` (`username`),
      UNIQUE KEY `email` (`email`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    CREATE TABLE `categories` (
      `category_id` int(11) NOT NULL AUTO_INCREMENT,
      `user_id` int(11) NOT NULL,
      `name` varchar(50) NOT NULL,
      `icon` varchar(10) DEFAULT NULL,
      PRIMARY KEY (`category_id`),
      KEY `user_id` (`user_id`),
      CONSTRAINT `categories_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    CREATE TABLE `expenses` (
      `expense_id` int(11) NOT NULL AUTO_INCREMENT,
      `user_id` int(11) NOT NULL,
      `category_id` int(11) NOT NULL,
      `amount` decimal(15,2) NOT NULL,
      `judul` varchar(100) NOT NULL,
      `description` text DEFAULT NULL,
      `date` date NOT NULL,
      PRIMARY KEY (`expense_id`),
      KEY `user_id` (`user_id`),
      KEY `category_id` (`category_id`),
      CONSTRAINT `expenses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
      CONSTRAINT `expenses_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON DELETE RESTRICT
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ```

5.  **Konfigurasi Koneksi**: Sesuaikan detail koneksi database (seperti `$servername`, `$username`, `$password`) di setiap file PHP jika berbeda dari pengaturan default XAMPP.

### 2. Frontend (Flutter App)

1.  **Clone Repositori**:
    ```bash
    git clone https://github.com/room1357/individual-project-3e-Kemal1101.git
    cd individual-project-3e-Kemal1101
    ```
2.  **Konfigurasi Alamat IP**:
    -   Buka file `lib/logic/auth_logic.dart`.
    -   Ubah nilai `baseUrl` agar sesuai dengan alamat IP lokal mesin tempat server PHP Anda berjalan. Contoh:
        ```dart
        final String baseUrl = 'http://192.168.1.5/expenseapp';
        ```
    -   *Tips: Untuk menemukan IP Anda di Windows, buka Command Prompt dan ketik `ipconfig`.*
3.  **Instal Dependensi**:
    ```bash
    flutter pub get
    ```
4.  **Jalankan Aplikasi**:
    -   Pastikan emulator Anda berjalan atau perangkat fisik terhubung.
    -   Jalankan aplikasi dengan perintah:
        ```bash
        flutter run
        ```

## 📁 Struktur Proyek

Berikut adalah gambaran singkat tentang struktur direktori utama:
