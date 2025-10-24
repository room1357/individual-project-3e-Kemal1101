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
-   **Ekspor ke PDF**: Membuat laporan pengeluaran dalam format PDF berdasarkan data yang telah difilter, yang bisa disimpan atau dibagikan.
-   **Desain Intuitif**: Antarmuka yang bersih dan mudah digunakan untuk pengalaman pengguna yang lebih baik.

## 🛠️ Tumpukan Teknologi

### Frontend (Mobile App)
-   **Framework**: Flutter
-   **Bahasa**: Dart
-   **Manajemen State**: `setState` (StatefulWidget)
-   **HTTP Client**: `http` package untuk komunikasi dengan API.
-   **Grafik/Chart**: `fl_chart` untuk membuat diagram statistik.
-   **Format**: `intl` untuk format mata uang dan tanggal.
-   **Pembuatan PDF**: `pdf` dan `printing` untuk membuat dan menampilkan laporan PDF.
-   **Akses File**: `path_provider` dan `open_file` untuk menyimpan dan membuka file di perangkat.

### Backend (Server-side)
-   **Bahasa**: PHP
-   **Database**: MySQL / MariaDB
-   **Web Server**: Apache (biasanya menggunakan XAMPP/MAMP/LAMP).

---