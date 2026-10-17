# 📘 DOKUMENTASI LENGKAP PROYEK: TEGAL ECOSENSE
> **Smart City IoT Ecosystem & Dashboard Kota Tegal**  
> *Sistem Monitoring Lingkungan Perkotaan, Otomasi Fasilitas Publik, dan Smart Parking Real-Time Berbasis ESP32 & Flutter*

---

## 1. 🌟 Ringkasan Aplikasi (Apa itu Tegal EcoSense?)

**Tegal EcoSense** adalah aplikasi *Smart City Dashboard* berbasis IoT (*Internet of Things*) yang dirancang khusus untuk memantau kondisi lingkungan dan mengelola fasilitas publik perkotaan di **Kota Tegal** (dengan fokus area ikonik seperti kawasan **Alun-Alun Tegal**).

Aplikasi ini menyatukan telemetri berbagai macam sensor fisik di lapangan ke dalam antarmuka ponsel pintar (*mobile app*) yang modern, responsif, dan *real-time*. Melalui aplikasi ini, petugas kota maupun masyarakat dapat:
1. **Memantau potensi genangan air & banjir** secara dini saat curah hujan tinggi.
2. **Melihat iklim mikro perkotaan** (suhu udara, kelembaban, serta deteksi hujan langsung).
3. **Memonitor kualitas udara (AQI / Gas MQ-135)** untuk mendeteksi tingkat polusi kendaraan di pusat kota.
4. **Melihat ketersediaan slot parkir kendaraan (Smart Parking)** di area Alun-Alun secara *live*.
5. **Mengontrol penerangan jalan & taman (Smart Lamp)** secara manual maupun otomatis berdasarkan sensor cahaya.
6. **Mengevaluasi riwayat data 24 jam hingga 7 hari terakhir** untuk analisa tren fluktuasi lingkungan.

---

## 2. 🛠️ Tech Stack & Arsitektur Teknologi

Sistem Tegal EcoSense dibangun menggunakan kombinasi perangkat keras embedded dan aplikasi mobile berkinerja tinggi:

```
┌─────────────────────────┐             ┌─────────────────────────┐             ┌─────────────────────────┐
│     ESP32-S3 (IoT)      │ ──MQTT TCP─>│  MQTT Broker (HiveMQ)   │ ──MQTT TCP─>│   Flutter Mobile App    │
│  (Sensor & Kontrol PJU) │ <─MQTT Sub─ │   (broker.hivemq.com)   │ <─MQTT Pub─ │   (Tegal EcoSense v1)   │
└─────────────────────────┘             └─────────────────────────┘             └─────────────────────────┘
```

### A. Frontend Mobile (Aplikasi Android/iOS)
* **Framework Utama**: [Flutter](https://flutter.dev/) (SDK `>=3.0.0 <4.0.0`) menggunakan bahasa pemrograman **Dart**.
* **State Management**: `Provider` (`ChangeNotifier`) — memastikan UI melakukan *re-render* secara efisien hanya pada komponen yang datanya berubah tanpa membebani memori HP.
* **Protokol Komunikasi Real-Time**: `mqtt_client: ^10.4.0` — terhubung langsung ke broker MQTT melalui soket TCP dengan latensi di bawah 1 detik.
* **Penyimpanan Lokal (Offline-first & History Buffer)**: `shared_preferences: ^2.2.3` — menyimpan hingga 192 rekaman data per jam (FIFO rolling buffer 8 hari) di memori internal HP tanpa perlu server database eksternal di fase awal.
* **Tipografi**: `google_fonts: ^6.2.1` dengan font keluarga **Plus Jakarta Sans** untuk kenyamanan membaca data teknis.
* **Sistem Pembaruan Mandiri (In-App OTA Updater)**:
  * `http: ^1.2.1`: Mengambil metadata rilis (`version.json`) dari GitHub.
  * `package_info_plus: ^8.0.0`: Membaca kode versi aplikasi yang sedang terpasang di HP.
  * `open_filex: ^4.5.0` & `permission_handler: ^11.3.1`: Membuka dan menginstal file paket `.apk` rilis baru langsung dari dalam aplikasi.

### B. Hardware & Firmware Embedded (IoT)
* **Mikrokontroler**: **ESP32-S3** (32-bit Dual-Core Xtensa LX7, 240 MHz, konektivitas Wi-Fi 2.4 GHz 802.11 b/g/n & Bluetooth 5 LE).
* **Firmware**: Arduino C++ (`SmartCIty-ESP32.ino`).
* **Sensor-Sensor yang Terpasang**:
  1. **Sensor Ketinggian Genangan Air / Banjir**: Ultrasonik (HC-SR04) atau sensor water level probe yang mengukur jarak permukaan air dalam satuan centimeter (`cm`).
  2. **Sensor Suhu & Kelembaban Udara**: DHT22 / DHT11 (mengukur suhu dalam `°C` dan kelembaban relatif dalam `%`).
  3. **Sensor Kualitas Udara**: MQ-135 Gas Sensor (mendeteksi gas amonia, sulfida, uap benzena, dan asap/CO2 dalam nilai analog ADC).
  4. **Sensor Hujan**: Raindrop Sensor Plate (mendeteksi konduktivitas tetesan air hujan secara boolean `isRaining`).
  5. **Sensor Parkir**: Sensor jarak per slot parkir untuk mengetahui apakah spot terisi (*occupied*) atau kosong (*empty*).
  6. **Aktuator Smart Lamp**: Modul Relay / Transistor MOSFET untuk menyalakan lampu PJU dan lampu taman Alun-Alun, dikombinasikan dengan sensor LDR (*Light Dependent Resistor*) untuk mode otomatis malam hari.

### C. Protokol Data MQTT
* **Broker**: Public HiveMQ Broker (`broker.hivemq.com` port `1883`).
* **Topic Telemetri (ESP32 $\rightarrow$ Flutter)**: `tegal/ecosense/telemetry`  
  Format data berupa JSON yang dikirim secara berkala:
  ```json
  {
    "water_level": 12.4,
    "flood_status": "Aman",
    "temperature": 29.8,
    "humidity": 72.0,
    "mq135_raw": 340,
    "air_status": "Normal / Baik",
    "is_raining": false,
    "parking": {
      "slot_1": true,
      "slot_2": false,
      "slot_3": true
    },
    "lamp": {
      "pju_1": true,
      "taman": false,
      "auto_mode": true
    }
  }
  ```
* **Topic Kendali (Flutter $\rightarrow$ ESP32)**: `tegal/ecosense/control`  
  Mengirim perintah saklar lampu, mode otomatis, atau reset telemetri.

---

## 3. 🎨 Tema Desain & Standar UI/UX

Aplikasi Tegal EcoSense menganut filosofi desain **Modern Glassmorphism & Cyber-Eco Smart City**, memberikan kesan futuristik, bersih, profesional, dan ramah pengguna.

### A. Palet Warna & Dual-Theme (Mode Terang & Gelap)
1. **Dark Mode (Default & Rekomendasi Utama)**:
   * **Background**: Deep Slate Navy (`#0F172A`) dan Dark Elevated Canvas (`#1E293B`).
   * **Borders**: Sub-pixel glass borders (`#334155`) dengan transparansi halus.
   * **Primary Accent**: Neon Cyan / Sky Blue (`#38BDF8` & `#0284C7`) merepresentasikan teknologi air & masa depan.
   * **Eco Green**: Emerald (`#10B981`) untuk status aman, kelembaban ideal, dan slot parkir kosong.
   * **Warning & Danger**: Amber (`#F59E0B`) untuk status Waspada dan Coral Red (`#EF4444`) untuk Siaga Banjir / Polusi Udara.
2. **Light Mode**:
   * **Background**: Pure Crisp White (`#FFFFFF`) dan Soft Cloud Blue (`#F8FAFC`).
   * **Borders & Dividers**: Silky Platinum Grey (`#E2E8F0`).
   * **Teks**: Deep Charcoal (`#0F172A`) dengan kontras tinggi sehingga sangat nyaman dibaca di bawah sinar matahari luar ruangan.

### B. Prinsip UI/UX yang Diterapkan
* **Visual Hierarchy yang Jelas**:
  * Informasi darurat (seperti status banjir & hujan) ditempatkan pada posisi teratas dengan warna penanda bahaya instan.
* **Hero Banner Ikonik Berbalut Glassmorphism**:
  * Bagian atas menampilkan foto kawasan Alun-Alun Tegal dengan sambutan dinamis (*Selamat Pagi/Siang/Sore/Malam*) dan tanggal aktual.
  * Tombol **`[ 📊 Riwayat Data ▾ ]`** disematkan elegan dengan efek kaca buram (*translucent glass*) di pojok kanan atas foto.
* **Micro-Interactions & Live Feedback**:
  * **Badge Koneksi Berkedip (Pulse Animation)**: Memberikan indikasi visual apakah koneksi ke broker MQTT sedang aktif, terputus, atau menyambung ulang.
  * **Interactive Touch Bezier Chart**: Grafik kurva lengkung mulus (*cubic bezier spline*) dengan area gradient fill. Pengguna dapat menggeser jari di sepanjang grafik untuk menginspeksi nilai sensor di jam tertentu.
  * **Single-Day Focus Modal**: Modal popup yang bersih, tidak padat, dan intuitif untuk membaca 24 titik jam per hari secara terfokus.
  * **Haptic & Visual Toggle Switch**: Setiap tombol kendali lampu dilengkapi visual glow efek saat status perangkat menyala.

---

## 4. 🚀 Konsep & Fitur Utama Aplikasi

### 1. Smart Environmental Monitoring (Fokus Utama)
* **Deteksi Banjir & Genangan Air**:
  * Menampilkan level air dalam centimeter secara instan.
  * Mengkategorikan status menjadi **Aman** ($<20\text{ cm}$), **Waspada** ($20 - 34\text{ cm}$), atau **Siaga Banjir** ($\ge 35\text{ cm}$).
* **Pemantau Cuaca & Hujan**:
  * Menampilkan suhu (°C) dan kelembaban (%).
  * Menampilkan indikator animasi saat tetesan air hujan menyentuh plat sensor di lapangan.
* **Indeks Kualitas Udara (MQ-135 Gas Monitoring)**:
  * Mengukur konsentrasi polutan udara di area Alun-Alun secara kontinu.
  * Memberikan label status kesehatan udara: *Sangat Bersih*, *Normal / Baik*, atau *Polusi Ringan/Sedang*.

### 2. Riwayat Data Harian (On-Device Rolling Buffer)
* **Penyimpanan Cerdas Tanpa Server Database Berat**:
  * Data riwayat otomatis tersimpan di HP pengguna setiap jam baru tiba.
  * Menggunakan sistem antrean **FIFO (First-In, First-Out)** dengan batas maksimal 192 data (8 hari $\times$ 24 jam).
  * Data terlama otomatis dibersihkan sehingga ukuran penyimpanan aplikasi tetap ringan ($< 1\text{ MB}$).
* **Pilihan Hari Tunggal (Single-Day Focus)**:
  * Pengguna dapat memilih hari yang ingin dianalisa dari dropdown:
    * *Hari Ini*
    * *Kemarin*
    * *2 Hari Lalu s/d 7 Hari Lalu* (dilengkapi tanggal kalender nyata, contoh: *Selasa, 29 Sep*).
  * Menampilkan ringkasan statistik khusus hari itu: **Nilai Tertinggi**, **Nilai Terendah**, dan **Rata-Rata**.
  * Dilengkapi grafik fluktuasi 24 jam (pukul 00:00 – 23:00) dan tabel log lengkap 24 baris data per jam.

### 3. Smart Parking System (Alun-Alun Tegal)
* Menyajikan tata letak visual slot parkir mobil/motor.
* Warna kartu parkir otomatis berubah secara *live*:
  * **Hijau**: Tersedia (*Empty*).
  * **Merah**: Terisi (*Occupied*).
* Membantu pengendara mengetahui ketersediaan tempat parkir sebelum tiba di lokasi.

### 4. Smart Public Lighting (Penerangan Jalan Umum)
* **Mode Manual**: Tombol switch on/off instan untuk menyalakan/mematikan lampu PJU 1, PJU 2, dan lampu taman Alun-Alun.
* **Mode Otomatis**: Sensor cahaya LDR pada ESP32 otomatis menyalakan lampu saat senja tiba dan mematikan lampu saat matahari terbit.

### 5. In-App OTA Update System (Auto-Pembaruan Aplikasi)
* Setiap kali aplikasi dibuka, sistem membandingkan nomor versi yang sedang aktif dengan rilis terbaru di repositori GitHub.
* Jika ada versi baru (misalnya rilis perbaikan fitur riwayat atau tampilan baru), muncul dialog *Changelog* pembaruan.
* Pengguna dapat menekan tombol **"Update Sekarang"** $\rightarrow$ aplikasi mengunduh APK baru dan membuka layar instalasi secara otomatis tanpa perlu kirim file APK manual lewat WhatsApp/Drive.

---

## 5. 📂 Struktur Direktori Proyek

```
tes/
├── lib/
│   ├── controllers/
│   │   └── telemetry_controller.dart      # Pengelola state data IoT & listener MQTT
│   ├── models/
│   │   ├── monitoring_history_model.dart  # Data model rekaman riwayat sensor
│   │   └── telemetry_data.dart            # Data model telemetri live dari ESP32
│   ├── screens/
│   │   └── dashboard_screen.dart          # Layar utama dashboard Smart City
│   ├── services/
│   │   ├── monitoring_history_service.dart# Layanan penyimpanan lokal 7 hari (SharedPreferences)
│   │   ├── mqtt_service.dart              # Layanan koneksi broker MQTT & subscription topic
│   │   └── update_service.dart            # Layanan pengecekan & unduh update OTA GitHub
│   ├── utils/
│   │   └── constants.dart                 # Konstanta warna, tema, dan konfigurasi broker
│   ├── widgets/
│   │   ├── climate_card.dart              # Card suhu & kelembaban
│   │   ├── connection_badge.dart          # Pill status online/offline MQTT
│   │   ├── flood_monitor_card.dart        # Card level air & peringatan banjir
│   │   ├── hero_banner_section.dart       # Foto Alun-Alun, greeting, & dropdown riwayat
│   │   ├── monitoring_history_modal.dart  # Modal popup grafik & tabel log 24 jam
│   │   ├── rain_sensor_card.dart          # Card status deteksi hujan
│   │   ├── smart_lamp_section.dart        # Kontrol saklar lampu PJU & taman
│   │   └── smart_parking_section.dart     # Visualisasi slot parkir realtime
│   └── main.dart                          # Titik masuk utama aplikasi Flutter
├── SmartCIty-ESP32.ino                     # Source code firmware mikrokontroler ESP32-S3
├── version.json                           # Metadata versi untuk deteksi OTA update
└── pubspec.yaml                           # Konfigurasi dependensi Flutter
```

---

## 6. 🔮 Rencana Integrasi Mendatang (Roadmap ke Web Laravel & Cloud Database)

Di masa mendatang, sistem ini dirancang siap terhubung dengan portal web **Laravel**:
1. **ESP32** atau **Worker MQTT** akan mengirim telemetri langsung ke API Laravel.
2. **Laravel** menyimpan data ke database cloud (**MySQL / TiDB Cloud**).
3. **Aplikasi Flutter** cukup mengganti pemanggilan data lokal ke endpoint REST API:
   `GET https://domain-web-laravel.com/api/monitoring/history?day_offset=0`  
   sehingga data riwayat dari puluhan titik di Kota Tegal dapat tersinkronisasi terpusat di server pemerintah kota.
