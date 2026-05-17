# 📋 Pembagian Tugas Tim - Klinik Jalan Sehat

Aplikasi Klinik "Jalan Sehat" saat ini sudah memiliki fondasi yang kuat (Sistem Login, Dashboard, Pasien, Dokter, dan Antrian sudah berjalan dengan Firestore). 

Untuk menyempurnakan aplikasi ini menjadi 100% siap rilis, berikut adalah pembagian tugas yang adil dan merata untuk anggota tim: **Yuga, Hanif, Alya, dan Frega**.

---

## 👨‍💻 1. Yuga - Modul Apotek & Manajemen Obat (Pharmacy)
**Fokus Area:** `lib/presentation/pharmacy/` & `medicines` collection.

**Detail Tugas:**
- **CRUD Data Obat**: Membuat halaman agar admin/apoteker bisa menambahkan, mengedit, dan menghapus daftar obat.
- **Manajemen Stok**: Membangun logika pengurangan stok obat secara otomatis jika kasir memproses pembayaran resep.
- **Peringatan Stok Menipis**: Membuat indikator (warna merah/kuning) di tabel obat jika sisa stok berada di bawah batas minimum (misal < 10 pcs).
- **Kategori & Pencarian**: Menambahkan fitur filter obat berdasarkan jenis (Sirup, Tablet, Salep, dll) agar mudah dicari apoteker.

---

## 👨‍💻 2. Hanif - Modul Keuangan & Kasir (Finance)
**Fokus Area:** `lib/presentation/finance/` & `transactions` collection.

**Detail Tugas:**
- **Halaman Kasir Terpadu**: Membuat form pembayaran yang otomatis menjumlahkan biaya: `Biaya Konsultasi Dokter + Total Harga Resep Obat`.
- **Status Pembayaran**: Menambahkan opsi metode pembayaran (Tunai, Transfer, BPJS) dan mengubah status antrian menjadi "Selesai Sepenuhnya" jika sudah lunas.
- **Cetak Struk/Kuitansi**: Membuat fitur *Export to PDF* agar struk pembayaran bisa dicetak atau disimpan.
- **Ringkasan Pendapatan**: Membuat *chart* atau kartu ringkasan di halaman Finance untuk melihat total pemasukan klinik hari ini dan bulan ini.

---

## 👩‍💻 3. Alya - Modul Rekam Medis & Laporan Kunjungan
**Fokus Area:** `lib/presentation/medical_records/` & `reports/`

**Detail Tugas:**
- **Form Diagnosis Dokter**: Membangun UI khusus untuk dokter saat klik "Mulai Periksa" di halaman antrian, di mana dokter bisa mengetik diagnosis, keluhan, dan meresepkan obat.
- **Histori Rekam Medis**: Membuat halaman profil riwayat penyakit tiap pasien (bisa melihat riwayat kunjungan sebelumnya).
- **Laporan Klinik (Reports)**: Membuat halaman tabel laporan rekapitulasi data harian/bulanan (jumlah pasien periksa, dokter paling aktif, dsb).
- **Export Data**: Menambahkan tombol "Download Excel/PDF" untuk laporan bulanan agar bisa diserahkan ke kepala klinik.

---

## 👨‍💻 4. Frega - Modul Konsultasi Online & Integrasi AI Chatbot
**Fokus Area:** `lib/presentation/consultation/` & `chatbot/`

**Detail Tugas:**
- **Chat Real-time Dokter-Pasien**: Melanjutkan pembuatan UI chat (`consultation_page.dart`) dan menghubungkannya dengan Firestore Streams agar pesan bisa masuk secara *real-time* seperti WhatsApp.
- **Integrasi Gemini AI**: Menyempurnakan widget `chatbot_widget.dart` dengan memasang API Key Google Gemini (Generative AI).
- **Prompt Engineering AI**: Mengatur AI agar hanya menjawab pertanyaan seputar kesehatan umum dan merekomendasikan pengguna untuk datang ke klinik (sebagai asisten *Customer Service*).
- **Status Online Dokter**: Menambahkan indikator hijau jika dokter sedang aktif membalas pesan konsultasi online.

---

## 💡 Panduan Kolaborasi (Aturan Main Tim):
1. **Pengerjaan Paralel**: Karena setiap orang memegang modul/halaman (`presentation`) yang berbeda, kalian tidak akan banyak bentrok (*merge conflict*) di Git.
2. **Gunakan Provider**: Ingat selalu pakai `Riverpod` (jangan `setState` kalau datanya besar) agar aplikasi tetap ringan.
3. **Commit Teratur**: Lakukan `git commit` minimal sehari sekali dengan pesan yang jelas (Contoh: `git commit -m "Yuga: Selesai fitur tambah obat"`).

Selamat bekerja! Mari selesaikan sistem "Jalan Sehat" ini bersama-sama! 🚀
