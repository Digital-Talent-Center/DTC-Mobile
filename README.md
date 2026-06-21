# PRODIGI Mobile — DTC Mobile

Aplikasi mobile (Flutter) untuk platform **Digital Talent Center (DTC)**, versi pendamping dari web app **PRODIGI**. Aplikasi ini ditujukan untuk **mahasiswa** dan terhubung ke REST API backend yang sama (Laravel + PostgreSQL) dengan autentikasi token **Sanctum**.

---

## Tentang Aplikasi

DTC Mobile adalah klien Android (Flutter) yang mengonsumsi API dari proyek web **DTC-Platform**. Seluruh alur fitur dibuat selaras dengan web, namun disesuaikan untuk perangkat mobile. Aplikasi ini **khusus untuk role mahasiswa** — panel admin tetap hanya di web.

Data nyata diambil dari server melalui REST API; tidak ada lagi data dummy. Sesi login disimpan sebagai token Sanctum di perangkat.

---

## Fitur Utama

- **Autentikasi** — Login & Register (token Sanctum), auto-login bila sesi tersimpan masih valid, logout.
- **Dashboard** — Menu fitur + seksi **Premium Highlights** (post premium yang sudah dibayar).
- **Activities** — Kelola *Event* & *Task* (buat, ubah status: Start → Complete, Cancel; status *overdue* dihitung otomatis dari tanggal/deadline).
- **My Achievements** — Tiga tab: *Achievement Collection* (approved), *Need Approval* (pending), *Rejected*.
- **Submit Achievement** — Form pengajuan prestasi + upload bukti (multipart) + simpan draf lokal.
- **Co-Library** — Repositori dokumen, filter kategori, buka berkas di browser.
- **Co-Guide** — Panduan/tutorial, filter level, View + Download berkas.
- **Timeline** — Feed post antar mahasiswa: buat post, **like**, **komentar**, **upload media (foto/video)**, **laporkan post**, hapus post sendiri.
- **Notifications** — Daftar notifikasi, tandai dibaca per item / semua, hapus semua.
- **Profile & Edit Profile** — Profil lengkap (data asli + prestasi approved), edit data profil.
- **Premium Post** — Pembayaran via **Midtrans Snap** (sandbox) yang dibuka di browser, lalu verifikasi status.
- **Push Notification** — Firebase Cloud Messaging (FCM) + notifikasi lokal saat foreground.

---

## Tech Stack

| Teknologi | Versi | Keterangan |
|-----------|-------|-----------|
| Flutter / Dart | SDK Dart `^3.11.5` | Framework UI |
| http | ^1.2.2 | HTTP client ke REST API |
| shared_preferences | ^2.3.2 | Simpan token Sanctum & sesi |
| intl | ^0.20.2 | Format tanggal locale `id_ID` |
| url_launcher | ^6.3.1 | Buka berkas (PDF) & halaman pembayaran Snap |
| video_player | ^2.9.2 | Pemutar video di Timeline |
| file_picker | ^8.1.4 | Pilih berkas (bukti prestasi, lampiran, media) |
| firebase_core | ^3.13.0 | Inisialisasi Firebase |
| firebase_messaging | ^15.2.7 | Push notification (FCM) |
| flutter_local_notifications | ^19.2.1 | Notifikasi lokal (foreground) |

---

## Arsitektur

Pola berlapis sederhana: **Screen → Service → Model**, dengan satu HTTP client terpusat.

```
Screen (UI, state) ──▶ Service (per-resource) ──▶ ApiClient (HTTP + token) ──▶ REST API
                              │
                              ▼
                          Model (fromJson)
```

- **`lib/config/api_config.dart`** — base URL server + helper URL (`apiUrl`, `fileUrl`, `snapRedirectUrl`).
- **`lib/services/api_client.dart`** — wrapper `http`: menyisipkan header `Authorization: Bearer <token>`, mem-parse format respons Laravel `{ data, message, pagination }`, melempar `ApiException` untuk status non-2xx (termasuk error validasi).
- **`lib/services/session.dart`** — simpan/muat token + user via `shared_preferences`.
- **`lib/services/*_service.dart`** — satu service per sumber daya (auth, achievement, activity, library, notification, post, premium, profile, midtrans, fcm).
- **`lib/models/*.dart`** — model data dengan `fromJson` (mendukung camelCase & snake_case).
- **`lib/screens/*.dart`** — UI per fitur; tiap layar punya state *loading / error / empty* + *pull-to-refresh*.
- **`lib/widgets/*.dart`** — komponen reusable (header auth, bottom navbar, text field, tombol).

---

## Struktur Folder

```
DTC-Mobile/
├── lib/
│   ├── main.dart                 # Entry point + AuthGate + init Firebase/locale
│   ├── config/
│   │   └── api_config.dart       # Base URL & helper URL
│   ├── models/                   # Model data (user, post, activity, achievement, dll)
│   ├── services/                 # ApiClient, Session, dan service per-resource
│   ├── screens/                  # Halaman: login, dashboard, timeline, profile, dll
│   └── widgets/                  # Komponen UI reusable
├── android/
│   └── app/google-services.json  # Konfigurasi Firebase (Android)
├── Assets/images/                # Logo & gambar
├── pubspec.yaml
└── README.md
```

---

## Prasyarat

- **Flutter SDK** (channel stable; diuji dengan Flutter 3.41 / Dart 3.x).
- **JDK 17** (mis. Temurin 17). Set `JAVA_HOME` ke folder JDK, atau atur *Gradle JDK* di Android Studio.
- **Android Emulator** atau perangkat fisik.
- **Backend DTC-Platform berjalan** (lihat README web). Mobile butuh server API aktif untuk login & data.
  - **Jika pakai Docker:** jalankan `docker compose up -d` di folder `DTC-Platform`. Server berjalan di port **80**.
  - **Jika manual:** jalankan `php artisan serve`. Server berjalan di port **8000**.

> Catatan: jangan men-commit `org.gradle.java.home` di `android/gradle.properties` — path JDK bersifat per-perangkat. Biarkan Gradle memakai `JAVA_HOME` masing-masing.

---

## Instalasi & Setup

**1. Ambil dependensi**
```bash
flutter pub get
```

**2. Konfigurasi Firebase (sudah disertakan)**
File `android/app/google-services.json` sudah ada di repo. Jika membuat project Firebase sendiri, ganti file ini dengan milik Anda.

**3. Pastikan backend berjalan**
Lihat README `DTC-Platform`. Ada dua cara:

```bash
# Opsi A — Docker (direkomendasikan, port 80)
cd ../DTC-Platform
docker compose up -d

# Opsi B — Manual (tanpa Docker, port 8000)
cd ../DTC-Platform
php artisan migrate --seed      # termasuk tabel personal_access_tokens
php artisan serve               # default http://127.0.0.1:8000
```

---

## Konfigurasi

### Base URL API
Default base URL ada di `lib/config/api_config.dart` = `http://10.0.2.2:8000` (alamat host laptop dari Android Emulator, mode manual). Bisa dioverride saat run **tanpa mengubah kode**:

```bash
# Contoh: HP fisik, backend Docker (port 80)
flutter run --dart-define=API_BASE_URL=http://192.168.1.10
```

| Target | Backend Docker (port 80) | Backend Manual (port 8000) |
|--------|--------------------------|----------------------------|
| Android Emulator | `http://10.0.2.2` | `http://10.0.2.2:8000` (default) |
| HP fisik (USB/Wi-Fi) | `http://<IP-LAN-laptop>` | `http://<IP-LAN-laptop>:8000` |
| Chrome / Flutter Web | `http://localhost` | `http://localhost:8000` |

> **Catatan Docker:** backend berjalan di port 80 (Nginx), bukan 8000. Tidak perlu menulis `:80` karena itu port default HTTP.

### Cleartext HTTP
`android/app/src/main/AndroidManifest.xml` sudah mengaktifkan `android:usesCleartextTraffic="true"` + izin `INTERNET` agar bisa mengakses server `http://` lokal saat development.

---

## Menjalankan Aplikasi

```bash
flutter pub get
flutter run
```

Untuk perangkat fisik dengan base URL khusus:
```bash
# Backend Docker (port 80) — Android Emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2

# Backend Docker (port 80) — HP fisik
flutter run --dart-define=API_BASE_URL=http://IP_LAPTOP

# Backend Manual (port 8000) — HP fisik
flutter run --dart-define=API_BASE_URL=http://IP_LAPTOP:8000
```

> **Penting:** setelah menambah/mengubah dependensi yang punya kode native (mis. Firebase, video_player), lakukan **full restart** (`flutter run` ulang), bukan hot reload.

**Akun demo (dari seeder backend):**

| Role | Email | Password |
|------|-------|----------|
| Mahasiswa | `demo@example.com` | `ipalGemink123` |

---

## Integrasi Backend (REST API)

Autentikasi memakai **token Sanctum**. Setelah login/register, token disimpan di perangkat dan dikirim sebagai header `Authorization: Bearer <token>` pada setiap request.

Endpoint utama yang dipakai:

| Modul | Endpoint |
|-------|----------|
| Auth | `POST /api/auth/login`, `POST /api/auth/register`, `POST /api/auth/logout`, `GET /api/auth/me` |
| Activities | `GET/POST /api/activities`, `PUT /api/activities/{id}` |
| Achievements | `GET/POST /api/achievements` |
| Co-Library | `GET /api/documents`, `GET /api/documents/{id}` |
| Co-Guide | `GET /api/guides`, `POST /api/guides/{id}/download` |
| Notifications | `GET /api/notifications`, `PUT /api/notifications/{id}/read`, `PUT /api/notifications/mark-all-read`, `DELETE /api/notifications/{id}` |
| Profile | `GET /api/profile`, `PUT /api/profile` |
| Timeline | `GET/POST /api/posts`, `POST /api/posts/{id}/like`, `POST /api/posts/{id}/comments`, `POST /api/posts/upload-media`, `DELETE /api/posts/{id}`, `POST /api/reports` |
| Premium | `GET /api/premium-transactions/highlights`, `POST /api/midtrans/upload-attachment`, `POST /api/midtrans/create-transaction`, `POST /api/midtrans/check-and-mark-paid` |
| Push (FCM) | `POST /api/fcm-token`, `DELETE /api/fcm-token` |

---

## Catatan Penting & Batasan

- **Hanya untuk mahasiswa.** Panel admin tidak ada di mobile.
- **Premium Post (Midtrans).** Flutter tidak punya SDK Snap, jadi halaman pembayaran dibuka di **browser** (URL redirect dari snap token). Setelah membayar, app **otomatis mengecek status saat kembali aktif** (atau tekan "Cek Status Pembayaran"). Post baru muncul di Premium Highlights hanya setelah status **`paid`**.
  - Di **sandbox**, gunakan kartu kredit test (`4811 1111 1111 1114`, exp bulan/tahun depan, CVV `123`, OTP `112233`) agar langsung lunas. VA/e-wallet tetap `pending` sampai disimulasikan di Midtrans Simulator.
- **Media Timeline.** Foto/video diunggah sungguhan ke server (`/api/posts/upload-media`) dan persist. (Catatan: media yang diposting dari **web** hanya tampil di browser tsb karena web memakai mekanisme localStorage.)
- **Avatar profil** tidak dapat diunggah dari mobile (endpoint upload avatar belum ada di backend) — avatar tampil bila sudah ada di server.

---

## Troubleshooting

| Gejala | Penyebab & Solusi |
|--------|-------------------|
| `Gradle property org.gradle.java.home ... is invalid` | `android/gradle.properties` memuat path JDK milik orang lain. Hapus baris `org.gradle.java.home`, set `JAVA_HOME` ke JDK 17 Anda, lalu `flutter clean && flutter run`. |
| `CSRF token mismatch` saat login | Pastikan request menuju `/api/auth/login` (endpoint mobile). Di server, route `api/auth/*` sudah dikecualikan dari CSRF. |
| `Connection refused` / timeout | Server belum jalan atau base URL salah. Cek apakah Docker sudah up (`docker compose ps`) atau `php artisan serve` berjalan. Emulator = `10.0.2.2`, HP fisik = IP LAN. |
| `Connection refused` di Emulator (Docker) | Pastikan `API_BASE_URL=http://10.0.2.2` (tanpa `:8000`). Docker Nginx jalan di port 80. |
| `Connection refused` di HP fisik (Docker) | Pastikan `API_BASE_URL=http://<IP-LAN-laptop>` (tanpa `:8000`). Periksa firewall Windows tidak memblok port 80. |
| Profil/identitas menampilkan akun lama | Sesi lama ter-cache. Logout (membersihkan token), atau hapus data app / reinstall. AuthGate juga memverifikasi token ke server saat startup. |
| Build error setelah menambah plugin | Lakukan **full restart**: stop app, `flutter clean`, `flutter pub get`, `flutter run`. |
| `Vite manifest not found` (web) | Itu error di **web**, bukan mobile. Jalankan `npm install && npm run build` di proyek web, atau pastikan `docker compose up -d` sudah berjalan. |

---

## Lisensi

Proyek ini dibuat untuk keperluan akademik (mata kuliah Aplikasi Berbasis Platform). Tidak untuk distribusi komersial.
