# VBat Ponsel 📱

[![Flutter Version](https://img.shields.io/badge/Flutter-%5E3.11.5-blue.svg?style=flat-square&logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-%5E3.0-blue.svg?style=flat-square&logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-green.svg?style=flat-square)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![State Management](https://img.shields.io/badge/State%20Management-BLoC%20%2F%20Cubit-red.svg?style=flat-square)](https://pub.dev/packages/flutter_bloc)

**VBat Ponsel** adalah aplikasi mobile berbasis Flutter yang dirancang khusus untuk memfasilitasi kebutuhan edukasi perbaikan ponsel (belajar soldering, skema sirkuit, dll.), komunitas diskusi (forum), dan belanja suku cadang serta peralatan perbaikan handphone (shop).

---

## 📋 Fitur Utama

Aplikasi VBat Ponsel terbagi ke dalam beberapa modul utama yang mandiri:

1. **Onboarding & Authentication**
   * Splash Screen dan Slideshow Panduan Pengguna.
   * Autentikasi lengkap: Login, Register, OTP Verification, Lupa Password, dan Reset Password.
2. **Belajar (Edukasi)**
   * Dashboard progres belajar dan daftar materi pembelajaran.
   * Video Player materi dengan kontrol interaktif (Majukan/mundurkan 10 detik, kontrol rotasi otomatis fullscreen, pengaturan kecepatan putar, dan resolusi video).
   * Klaim dan unduh Sertifikat kelulusan kelas.
3. **Forum (Komunitas)**
   * Halaman beranda forum untuk berbagi diskusi seputar perbaikan HP.
   * Pencarian utas (*thread*) forum.
   * Pembuatan utas baru dan detail diskusi beserta komentar.
4. **Shop (E-Commerce)**
   * Katalog penjualan suku cadang dan perkakas HP dari merek-merek ternama.
   * Penyaringan (*filter*) produk tingkat lanjut menggunakan bottom sheet.
   * Halaman Wishlist produk pilihan dan detail toko/brand.
5. **Profile & Pengaturan**
   * Halaman profil pengguna (atau profil tamu jika belum masuk).
   * Pengaturan preferensi: Tema aplikasi (Gelap/Terang), bahasa, pusat bantuan, riwayat transaksi, riwayat pembelajaran, dan detail langganan member.

---

## 📂 Struktur Folder Proyek (Clean Architecture)

Proyek ini menerapkan konsep **Clean Architecture** yang dikombinasikan dengan pembagian struktur berbasis fitur (**Feature-First Structure**) untuk mempermudah skalabilitas dan pemeliharaan kode.

```directory
lib/
├── core/                         # Logika global dan utilitas bersama
│   ├── error/                    # Definisi kegagalan sistem (Failures)
│   ├── network/                  # Klien API jaringan (Dio)
│   ├── routes/                   # Navigasi dan rute aplikasi (GoRouter)
│   ├── utils/                    # Helper (Session, Camera, Wishlist, dll.)
│   └── widgets/                  # Widget global (VideoPreviewWidget, dll.)
│
├── features/                     # Kumpulan fitur/modul aplikasi
│   ├── auth/                     # Autentikasi (Data, Domain, Presentation)
│   ├── belajar/                  # Modul pembelajaran & video player
│   ├── core/                     # Halaman global inti
│   ├── forum/                    # Modul forum diskusi komunitas
│   ├── home/                     # Halaman beranda utama dan pencarian global
│   ├── main_navigation/          # Kerangka navigasi utama (MainScaffold)
│   ├── notifikasi/               # Manajemen notifikasi pengguna
│   ├── onboarding/               # Splash & halaman pengantar
│   ├── profile/                  # Pengaturan akun, transaksi, & preferensi
│   └── shop/                     # Toko e-commerce perkakas & suku cadang
│
└── main.dart                     # Titik masuk utama (App Entrypoint)
```

Setiap modul di dalam `features/` secara ideal dibagi menjadi 3 lapisan (Layers) Clean Architecture:
* **Data:** Berisi model, sumber data (remote/local), dan implementasi repositori.
* **Domain:** Berisi entitas bisnis (*entities*), antarmuka repositori (*repositories*), dan kasus penggunaan (*usecases*).
* **Presentation:** Berisi logika UI, widget, halaman (*pages*), dan manajemen status (*BLoC/Cubit*).

---

## 🛠️ Teknologi & Pustaka yang Digunakan (Tech Stack)

Aplikasi ini menggunakan teknologi modern dalam ekosistem Flutter:

| Pustaka / Teknologi | Kegunaan |
| :--- | :--- |
| **Flutter SDK (v3.11.5+)** | Framework utama pembuatan aplikasi cross-platform. |
| **Flutter BLoC & Cubit** | Manajemen status (*state management*) dan pemisahan logika bisnis dari UI. |
| **GoRouter** | Manajemen navigasi halaman dengan basis URL-routing yang deklaratif. |
| **Dio** | HTTP Client untuk integrasi API dengan dukungan interceptor dan pembatalan request. |
| **GetIt** | Pustaka *Service Locator* untuk Dependency Injection (DI) yang ringan. |
| **Dartz** | Pustaka pemrograman fungsional (untuk menangani *Either* type pada error handling). |
| **Video Player** | Pemutar video native dengan performa tinggi untuk kebutuhan belajar. |
| **Shared Preferences** | Penyimpanan lokal sederhana untuk sesi login dan pengaturan lokal. |
| **Flutter Launcher Icons** | Otomatisasi pembuatan ikon aplikasi untuk berbagai resolusi layar perangkat. |

---

## 🚀 Panduan Instalasi & Menjalankan Aplikasi

### Prasyarat Sebelum Mulai
1. Pastikan Anda telah menginstal **Flutter SDK** terbaru (Direkomendasikan versi 3.11.5 atau di atasnya).
2. Memiliki editor kode seperti **VS Code** atau **Android Studio** yang sudah terinstal ekstensi Flutter & Dart.
3. Menyiapkan Emulator Android/iOS atau perangkat fisik yang terhubung via USB Debugging.

### Langkah-Langkah Pemasangan
1. **Klon Repositori Proyek:**
   ```bash
   git clone https://github.com/mohamadsolkhannawawi/vbat-ponsel.git
   cd vbat-ponsel
   ```
2. **Dapatkan Semua Ketergantungan Paket (Dependencies):**
   ```bash
   flutter pub get
   ```
3. **Generate Launcher Icons (Opsional - Jika ingin memperbarui logo aplikasi):**
   ```bash
   flutter pub run flutter_launcher_icons
   ```
4. **Jalankan Aplikasi dalam Mode Debug:**
   ```bash
   flutter run
   ```
5. **Membangun Aplikasi APK Rilis (untuk Android):**
   ```bash
   flutter build apk --release --split-per-abi
   ```

---

## 🤝 Alur Kolaborasi & Git Workflow

Untuk menjaga kualitas kode, proyek ini menggunakan alur Git berikut:

1. **Gunakan Branch Fitur Baru:**
   Jangan pernah melakukan commit langsung ke branch `main`. Buat branch baru untuk setiap fitur atau perbaikan bug:
   ```bash
   git checkout -b feature/nama-fitur
   # atau
   git checkout -b bugfix/nama-perbaikan
   ```
2. **Gunakan Format Commit Konvensional:**
   Commit message wajib menggunakan bahasa Inggris dengan format `type(scope): message`.
   * **`feat`**: Fitur baru (misal: `feat(shop): add product filter bottom sheet`)
   * **`fix`**: Perbaikan bug (misal: `fix(player): resolve video aspect ratio overflow`)
   * **`chore`**: Perubahan rutin/tooling (misal: `chore(git): configure .gitignore`)
   * **`test`**: Menambah atau memperbaiki file test (misal: `test(app): add initial test files`)
3. **Lakukan Pull Request (PR):**
   Setelah selesai, unggah branch Anda dan ajukan *Pull Request* ke branch `main` untuk direview oleh tim pengembang lain.

---

## 🛡️ Standar Penulisan Kode (Code Standards)

* **Linting:** Proyek ini mengikuti aturan linting resmi Flutter yang dikonfigurasi melalui [analysis_options.yaml](file:///d:/project-nawa/vbat_ponsel/analysis_options.yaml). Pastikan tidak ada warning/error sebelum mengajukan PR.
* **Format:** Selalu gunakan format otomatis (`flutter format .`) sebelum melakukan commit kode baru.
* **Manajemen State:** Hindari memanggil logika bisnis langsung di dalam view/page. Gunakan `BlocProvider` dan `BlocBuilder` untuk menangani perubahan status layar.
