# 🏥 Klinik Jalan Sehat - Desktop App

Aplikasi **Klinik Jalan Sehat** adalah sistem informasi manajemen klinik berbasis desktop (Windows/Web) yang dibangun menggunakan **Flutter** dan **Firebase**. Aplikasi ini dirancang layaknya *software* kelas atas (SaaS) dengan antarmuka yang elegan, responsif, dan bekerja secara *real-time*.

---

## 🛠️ Apa Saja yang Baru Saja Dikerjakan? (Log Pembaruan Terakhir)

1. **Penyempurnaan Tampilan (UI/UX) Premium**
   * **Efek Hover Navigasi**: Menu sidebar kini memiliki efek transisi yang sangat profesional. Saat disorot, latar belakang berubah menjadi biru elegan, ikon sedikit membesar (zoom), teks bergeser mulus, dan muncul efek bayangan.
   * **Keterbacaan Profil**: Warna latar bagian bawah sidebar (area profil login admin/dokter) diubah agar kontras teks tetap terbaca dengan jelas.
   * **Sapaan Personal**: Menghapus sapaan bawaan ber-emoji dan menggantinya dengan sapaan profesional yang memanggil nama asli pengguna langsung dari database.

2. **Integrasi Firebase Authentication**
   * Mengubah sistem login "pura-pura" menjadi login sungguhan menggunakan Google Sign-In & Firebase Auth.
   * Menambahkan notifikasi interaktif (*SnackBar*) merah jika proses login gagal (misalnya karena password salah atau jaringan bermasalah).

3. **Sinkronisasi Database Firestore & Perbaikan Indeks**
   * Aplikasi kini sepenuhnya terhubung dengan Firestore Database.
   * Menyelesaikan masalah Error *Composite Index* pada halaman **Antrian** dan **Pasien** dengan mendaftarkan kombinasi kueri (seperti pencarian berdasarkan tanggal & nomor urut) secara manual ke Firebase Console.

---

## 🧠 Bagaimana Sistem Aplikasi Ini Bekerja? (Bahasa Santai)

Bayangkan sistem aplikasi ini seperti **Restoran Modern**:

1. **Firebase = Dapur & Satpam**
   * **Firebase Auth (Satpam)**: Memastikan hanya dokter atau admin resmi yang bisa masuk.
   * **Firestore Database (Dapur & Lemari Arsip)**: Tempat menyimpan semua rekam medis, antrian, dan data pasien. Kerennya, ini bersifat **Real-Time**. Kalau Admin mendaftarkan pasien di komputer depan, layar komputer Dokter di dalam ruangan langsung *update* tanpa perlu klik tombol "Refresh".

2. **Riverpod = Pelayan Restoran**
   * Di dalam kode aplikasi, ada yang namanya `Riverpod` (State Management). Tugasnya mondar-mandir mengambil data dari Dapur (Firebase) dan menyajikannya ke layar (UI). 

3. **Flutter = Ruang Makan & Desain Interior**
   * Ini adalah semua halaman visual yang Anda lihat. Disusun dari *Widget* yang kita desain sedemikian rupa agar terlihat modern.

---

## 🔄 Alur Kerja Aplikasi (Cara Pakainya)

Berikut adalah alur keseharian penggunaan aplikasi Klinik Jalan Sehat ini:

### 1. Alur Masuk (Login)
* Staf klinik (Admin atau Dokter) membuka aplikasi.
* Masukkan kredensial (via Google Login atau Email/Password).
* Sistem Auth mengecek. Jika benar, aplikasi mengarahkan ke halaman **Dashboard**.

### 2. Alur Pendaftaran Pasien (Resepsionis / Admin)
* Pasien baru datang ke klinik.
* Admin masuk ke menu **Pasien**, klik **Pasien Baru**.
* Mengisi form lengkap (Nama, Golongan Darah, Tanggal Lahir).
* *Klik Simpan* ➔ Data langsung masuk ke Firestore dan pasien resmi terdaftar dengan Nomor Rekam Medis unik.

### 3. Alur Antrian (Resepsionis)
* Pasien yang sudah terdaftar ingin berobat hari ini.
* Admin buka menu **Antrian**, klik **Tambah Antrian**.
* Pilih nama pasien dan dokter yang dituju.
* *Klik Tambah* ➔ Nomor antrian muncul secara berurutan. Pasien tersebut masuk ke status **Menunggu** (*Waiting*).

### 4. Alur Pemeriksaan (Dokter)
* Dokter di ruangannya melihat layar Dashboard/Antrian miliknya.
* Saat giliran tiba, admin/dokter klik **Panggil Pertama**. (Status berubah jadi *Called*).
* Pasien masuk ke ruang periksa, dokter klik **Mulai Periksa**. (Status berubah jadi *Examining*).
* Dokter membuka menu **Rekam Medis** pasien tersebut, melihat riwayat alergi, lalu mencatat keluhan dan resep hari ini.
* Setelah selesai, dokter klik **Selesai** pada antrian. (Status berubah jadi *Done*).

### 5. Selesai
* Data antrian pasien hilang dari antrian aktif dan berpindah ke riwayat.
* Layar besar antrian langsung menunjukkan nomor pasien berikutnya secara otomatis.

---
*Dokumentasi ini akan terus di-update seiring dengan bertambahnya fitur baru.*
