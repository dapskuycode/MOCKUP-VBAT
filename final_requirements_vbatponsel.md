# Dokumen Spesifikasi Kebutuhan Revisi VbatPonsel (Final)

Dokumen ini merupakan panduan spesifikasi (*requirements*) final bagi tim *developer* untuk mengimplementasikan revisi pada aplikasi VbatPonsel. Semua ambiguitas telah diselesaikan.

## 1. Autentikasi & Profil Pengguna
- **Metode Login/Daftar**: Mendukung login menggunakan Sosial Media (Facebook/WhatsApp), Google, dan Apple ID.
- **Kelengkapan Data Diri**: Pengguna wajib melengkapi data diri via profil. Harus ada validasi dan catatan/peringatan di UI bahwa data yang dimasukkan harus benar karena akan digunakan untuk pencetakan sertifikat selamanya.
- **Sertifikat & KTA (Keanggotaan)**:
  - Setelah pengguna membeli kelas, otomatis menjadi anggota resmi.
  - Keanggotaan berbentuk Kartu Tanda Anggota (KTA) Digital.
  - KTA dan Sertifikat berlaku **selamanya** (tanpa kadaluwarsa).
  - **Sistem Sertifikat (Non-Blockchain)**: Tidak menggunakan *gas fee* atau jaringan kripto. Sistem diimplementasikan menggunakan tautan sertifikat digital yang bisa diverifikasi (*Verifiable Digital Badges*)—mirip dengan implementasi Skilvul/Parchment.
  - Terdapat template visual khusus untuk sertifikat.

## 2. Sistem Pembelajaran (LMS), Kelas, & Akses
- **Kategori & Harga Kelas**:
  - **Kelas Android**: Rp 800.000 (Materi Android + Hardware Solution Android).
  - **Kelas iPhone**: Rp 2.000.000 (Materi iPhone + Hardware Solution iPhone).
  - **Paket Bundling**: Rp 2.500.000 (Akses penuh semua kelas dan HS).
- **Hak Akses (Kelas Saya)**:
  - Hanya menampilkan materi berbayar milik *user*. Kelas Teknisi Android hanya mendapat materi Android. 
  - Preview materi video bagi pengguna gratis dibatasi 5-10 detik. Jika ingin lanjut, harus membayar.
  - Semua fitur pendukung aplikasi dimunculkan dalam halaman kelas.
- **Aturan Akses Alumni & Langganan (Masa Aktif)**:
  - Pada periode rilis awal, seluruh alumni diberikan kelonggaran **Free Premium Access** hingga **Awal Januari 2027**.
  - Setelah periode gratis habis, akses terhadap konten materi (termasuk *Hardware Solution*) akan dikunci.
  - Untuk membuka kembali akses konten, pengguna dikenakan tarif langganan **Rp 100.000 per tahun**.
  - Walaupun masa langganan habis, KTA dan Sertifikat di Profil tetap bisa diakses dan valid selamanya.
- **Aturan Fitur Hardware Solution (HS)**:
  - Fitur HS adalah panduan reparasi harian yang murni **Premium**.
  - HS **tidak akan langsung terbuka** saat pengguna membeli kelas/paket bundling. 
  - Akses HS hanya akan terbuka otomatis **setelah** pengguna menyelesaikan materi kelas terkait 100% (video dan kuis).
- **Pemutaran Video & Offline Mode**:
  - **Constraint Video**: Pengguna **DIWAJIBKAN menonton**, dan *developer* harus menghilangkan tombol percepat (*fast-forward*) atau *skip* pada *video player*.
  - **Mode Offline**: Materi bisa diunduh untuk ditonton tanpa internet di dalam aplikasi. File *download* dienkripsi sistem agar tidak bisa diekstrak/tersimpan bebas di penyimpanan perangkat *user*.
- **Kuis / Evaluasi**:
  - 3 jenis soal: Pilihan Ganda, Jawaban Singkat, dan Studi Kasus.
  - Evaluasi teks menggunakan mekanisme pencocokan kata kunci (*keyword matching*).

## 3. Fitur Sponsor, Iklan & E-Commerce
- **Hero Slider Banner (Beranda)**: 
  - Bisa digeser, diletakkan paling atas (di atas fitur promo). Maksimal 6 *slide*.
  - Jika ditekan, muncul *pop-up* keterangan sponsor dan tombol "Kunjungi Sponsor".
- **Best Deal (Pengganti Flash Sale)**:
  - Menampilkan produk Sponsor/*Sale*. Jika di-klik, akan melempar *user* keluar aplikasi menuju *link* toko Shopee/Tokopedia.
- **Banner Horizontal (Katalog)**: Disisipkan di tengah daftar produk setiap kelipatan 12 produk.
- **Tampilan Beranda**: Desain *card* untuk Video Materi dan Produk e-commerce dibedakan. Khusus *card* Kursus/Materi, **teks deskripsi diletakkan di atas** *thumbnail* video.
- **Manajemen Sponsor (Admin)**: 
  - Admin Vbat mengatur semua konten dan membuatkan akun untuk entitas sponsor.
  - Entitas sponsor bisa login panel untuk menambah kampanye (gambar/video/produk) dengan batasan (*constraint*) dan frekuensi tayang yang dikendalikan Admin Utama.

## 4. Keamanan & Proteksi
- **Super Secret Mode**: Wajib menerapkan proteksi OS (anti-screenshot dan anti-screen record) pada seluruh *screen* yang memuat materi eksklusif.

## 5. Gamifikasi, UI/UX & Fitur Lainnya
- **UI/UX Aesthetics**: Tampilan *Dark Mode* dikonsep **simpel dan elegan** menyesuaikan karakter aplikasi *tech-learning*.
- **Onboarding**: Tersedia *Tour App* bagi pengguna baru.
- **Gamifikasi**: Sistem *Badge/Achievement* dan pelacakan *Streak* harian beserta notifikasinya.
- **Bahan Ajar**: Modul berupa E-Book ditempatkan di halaman Belajar dan Profil.
- **Informasi (Pengganti Forum)**: 
  - "Forum" diganti menjadi menu "Informasi" (komunikasi satu arah dari admin memuat gambar & narasi dengan tombol gabung). 
  - Kategori: Ruang Konsultasi, Lowongan Pekerjaan, Magang, Upgrade Kelas Offline.
- **Dukungan Bantuan (Premium)**:
  - Pembuatan *Chatbot AI* ditunda (tidak dikerjakan).
  - Bantuan diarahkan melalui pesan *WhatsApp* langsung ke **Pak Tomi**.
  - **Krusial:** Tombol/Akses pesan ke Pak Tomi ini **HANYA** muncul dan bisa diakses oleh *user* yang statusnya sudah berlangganan/premium.
- **Tentang Kami**: Aplikasi memiliki halaman legal yang menyebutkan bahwa platform ini dikembangkan untuk Vbat dan dinaungi oleh Quantum Tele.
- **Arsitektur Aplikasi**: Dikembangkan sebagai *Mobile App* (Native/Flutter), bukan berbasis PWA (Progressive Web App).

---

## 6. Rekomendasi Skema Garansi & Maintenance Proyek (Quantum Tele)
Berdasarkan nilai proyek (Rp 46 Juta), berikut adalah ide struktur ideal untuk *maintenance*:

1. **Fase Garansi (Gratis)**:
   - Karena aplikasi memberikan kelonggaran Premium gratis untuk alumni hingga **Awal Januari 2027**, tim *developer* / Quantum Tele dapat memberikan **Garansi Pengembangan dan Server** secara penuh secara gratis (*Free Maintenance*) pada periode yang sama (hingga Awal Januari 2027).
   - Selama masa ini, seluruh isu krusial seperti perbaikan *bug*, stabilitas video, atau celah keamanan di-*cover*.
2. **Fase Kontrak Maintenance Lanjutan (Mulai Januari 2027)**:
   - Setelah masa gratis alumni habis (dan Vbat mulai mendapatkan *revenue stream* dari iuran Rp 100k/tahun per pengguna), biaya operasional pemeliharaan aplikasi (*Server, Database, Cloud Storage*, dan *Technical Support*) selanjutnya dibebankan kepada Quantum Telecom (atau dialokasikan dari pemasukan langganan Vbat).
   - Skemanya dapat berupa **SLA Bulanan** atau **Tahunan** dengan biaya *fix rate* untuk menjaga aplikasi tetap mengudara dan *up-to-date* dengan kebijakan Google Play/App Store terbaru.
