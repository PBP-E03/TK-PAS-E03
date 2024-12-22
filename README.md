# steve_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Tahap I (20%)

# Steve Mobile

## **Deskripsi Proyek**

**Steve Mobile** adalah sebuah aplikasi yang dirancang untuk membantu pengguna menemukan dan memilih steakhouse terbaik di Jakarta. Melalui aplikasi ini, Pengguna dapat mencari steakhouse berdasarkan nama restoran serta mengakses informasi penting seperti menu spesial, jam operasional, lokasi, dan harga menu. Selain itu, Steve Mobile memungkinkan pengguna untuk membaca dan menulis ulasan, berdiskusi dengan komunitas pecinta steak di forum, serta melakukan reservasi langsung ke steakhouse pilihan mereka dengan mudah. Dengan antarmuka yang ramah pengguna dan fitur yang lengkap, **Steve Mobile** menjadi pendamping terbaik bagi para penggemar steak di Jakarta.

---

## **Anggota Kelompok**

- Danniel - 2306152090
- Joshua Elisha Shalom Soedarmintarto - 2306275001
- Anita Khoirun Nisa - 2306152273
- Athallah Wibowo - 2306275576
- Nafisa Arrasyida - 2306226391

---

## **Modul yang Diimplementasikan**

### 1. **Modul Reservasi** - **[Anita Khoirun Nisa]**

- Pengguna dapat melakukan reservasi meja secara online.
- Formulir reservasi mencakup input nama, tanggal, waktu, jumlah tamu, dan kontak.
- Pengguna dapat melakukan booking menu unik atau request tambahan.
- Sistem akan mengkonfirmasi ketersediaan dan memberikan notifikasi kepada pengguna.

### 2. **Modul Ulasan dan Rating** - **[Joshua Elisha Shalom Soedarmintarto]**

- Pengguna yang telah login dapat menulis ulasan dan memberikan rating pada steakhouse yang pernah dikunjungi.
- Ulasan dan rating akan ditampilkan pada halaman detail steakhouse.
- Memungkinkan pengguna untuk melihat ulasan terbaru dan terpopuler.

### 3. **Modul Forum Diskusi** - **[Athallah Wibowo]**

- Pengguna dapat berdiskusi dengan admin dan sesama anggota lain mengenai topik seputar steakhouse dan menu.
- Fitur meliputi pembuatan komentar, dan pemperbarui komentar.
- Memfasilitasi interaksi dan pertukaran informasi antar pengguna dan admin.

### 4. **Modul Wishlist** - **[Nafisa Arrasyida]**

-Pengguna dapat menambahkan steakhouse, menu, atau produk tertentu ke dalam daftar wishlist sesuai kategori yang pengguna buat, mereka untuk disimpan dan diakses di lain waktu.

- Sistem memungkinkan pengguna melihat wishlist yang tersimpan, menghapus item dari wishlist jika tidak lagi diinginkan, dan mengubah lokasi kategori item.
- Modul ini membantu pengguna menyimpan pilihan favorit mereka untuk direncanakan atau dipertimbangkan di masa mendatang.

### 5. **Modul Daftar** - **[Danniel]**

- Pengguna dapat mencari steakhouse dan menu yang diinginkan.
- Modul ini akan menampilkan gambar menu, review, rating, dan lokasi.
- Modul ini juga dapat mengedit deskripsi steakhouse.

### 6. **Modul Autentikasi** - **[Danniel]**

- Pengguna dapat melakukan registrasi, login dan juga logout.
- Pengguna harus terautentikasi untuk masuk ke landing page aplikasi.
- Menyediakan endpoint login dan register untuk pengguna.
- Endpoint login memungkinkan pengguna mengautentikasi dengan username dan password.
- Endpoint register digunakan untuk mendaftarkan akun baru dengan validasi password dan ketersediaan username.
- Mendukung middleware dan pengaturan cross-origin agar aplikasi dapat diakses dari emulator Flutter.
- Sistem akan memvalidasi data dan memberikan respons JSON sesuai dengan hasil autentikasi atau pendaftaran.

---

## **Peran Pengguna Aplikasi**

### **Pengguna Login:**

- Memiliki semua akses yang dimiliki pengguna tidak login.
- Dapat menulis ulasan dan memberikan rating pada steakhouse.
- Dapat berpartisipasi dalam forum diskusi (membuat topik baru dan berkomentar).
- Dapat melakukan reservasi tempat secara online.
- Dapat melihat daftar reservasi yang telah dibuat atau masih berlangsung.
- Dapat melihat wishlist yang telat dibuat.
- Dapat mengubah wishlist yang telah dibuat.
- Dapat mencari daftar steakhouse.

### **Pengguna Admin:**

- Memiliki semua akses yang dimiliki pengguna login.
- Dapat menambahkan, mengedit dan menghapus restoran

---

## **Alur pengintegrasian dengan web service untuk terhubung dengan aplikasi web yang sudah dibuat saat Proyek Tengah Semester**

### **Tahapan Integrasi**

1. **Membuat Fungsi Web Service**  
   Membuat fungsi baru untuk menerima request dan mengirimkan respon ke aplikasi mobile.

2. **Menghubungkan ke Aplikasi Mobile**  
   Pada flutter aplikasi mobile, menambahkan request ke url fungsi tersebut dan mengolah data yang didapatkan dari hasil request.

3. **Debugging dan Pengujian**  
   Melakukan debugging dan memperbaiki apabila ada error atau hal lainnya sampai aplikasi berjalan dengan baik dan memenuhi ketentuan yang diinginkan.

---

## **Repositori Terkait**

- **GitHub Kelompok:**  
  [GitHub E03](https://github.com/PBP-E03)

- **Pembuatan Codebase Kelompok:**
  - Proyek Akhir Semester (PAS): [GitHub PAS](https://github.com/PBP-E03/TK-PAS-E03)
  - Proyek Tengah Semester (PTS): [GitHub PTS](https://github.com/PBP-E03/TK1-PBP)

---

## **Tautan Deploy**

[Instalasi Aplikasi](https://appcenter.ms/download?url=%2Fv0.1%2Fapps%2FPBP-E03%2FSteve-Mobile%2Fbuilds%2F3%2Fdownloads%2Fbuild)
[Instalasi Aplikasi Terbaru](https://appcenter.ms/download?url=%2Fv0.1%2Fapps%2FPBP-E03%2FSteve-Mobile%2Fbuilds%2F8%2Fdownloads%2Fbuild)
