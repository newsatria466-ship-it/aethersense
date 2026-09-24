Tindaklanjuti peran Anda sebagai Senior Flutter Developer dan UI/UX Designer. Buatkan saya aplikasi mobile Flutter yang berfungsi sebagai dashboard "Smart City Kota Tegal" untuk memonitor lingkungan dan kapasitas tempat sampah berbasis IoT.

---
**1. KONSEP & ALUR KERJA**
- Aplikasi bertindak sebagai MQTT Subscriber.
- Broker: `broker.hivemq.com` (Port 1883).
- Topik: `tegal/smartcity/test`
- Aplikasi harus mem-parsing pesan MQTT berupa JSON string dengan format berikut:
  `{"suhu": 32.5, "kelembapan": 75, "udara": 120, "jarak": 15}`
- Data JSON tersebut harus di-update ke UI secara real-time.

---
**2. KEBUTUHAN UI/UX (DESAIN MODERN & INTERAKTIF)**
- **Tema:** Clean, modern, light mode, dengan latar belakang abu-abu sangat muda (contoh: `#F4F6F9`).
- **AppBar/Header:** Kustom, tanpa elevation, bertuliskan "Smart City Dashboard" dengan sub-judul "Tegal Berbasis IoT".
- **Status Koneksi:** Buat indikator berbentuk 'Pill' (kapsul) di bawah header.
  - Hijau & tulisan "Terhubung" jika MQTT terkoneksi.
  - Merah & tulisan "Terputus" jika gagal/hilang koneksi.
  - Oranye & beranimasi loading saat "Menghubungkan...".
- **Grid Layout (Dashboard Utama):**
  Tampilkan 4 parameter dalam bentuk Grid (2 kolom) berupa Card modern (sudut membulat/rounded corners, soft shadow):
  1. **Suhu Udara:** Tampilkan angka + "°C". Ikon Termometer.
  2. **Kelembapan:** Tampilkan angka + "%". Ikon Tetesan Air.
  3. **Kualitas Udara:** Tampilkan angka + "PPM". Ikon Angin/Daun. 
  4. **Kapasitas Sampah (Jarak):** Tampilkan angka + "cm". Ikon Tempat Sampah.
- **Indikator Peringatan Visual (UX dinamis):**
  Warna angka atau ikon pada Card harus berubah berdasarkan kondisi bahaya:
  - Udara > 200 PPM = Warna teks peringatan (Merah/Oranye).
  - Jarak Sampah < 10 cm = Berarti sampah penuh, ubah warna Card/Teks menjadi Merah.

---
**3. SPESIFIKASI TEKNIS & STATE MANAGEMENT**
- Gunakan package `mqtt_client` terbaru.
- Terapkan mekanisme *auto-reconnect* di latar belakang jika koneksi internet/broker terputus.
- Gunakan state management yang rapi (boleh `Provider`, `GetX`, atau `StatefulWidget` standar asalkan logika MQTT terpisah dari UI/View).
- Pastikan kodenya 100% Null-Safe dan bebas error.

---
**4. OUTPUT YANG SAYA MINTA DARI ANDA**
Tolong berikan balasan dengan urutan berikut:
1. Konfigurasi `pubspec.yaml` (dependencies dan assets icon jika perlu).
2. Konfigurasi `AndroidManifest.xml` (Izin akses Internet).
3. Struktur kode (buat dalam beberapa file jika perlu, misalnya `main.dart` untuk routing/tema, `mqtt_service.dart` untuk logika, dan `dashboard_screen.dart` untuk UI, atau gabung secara terstruktur jika lebih efisien).
4. **Langkah-langkah di terminal untuk mem-build aplikasi ini menjadi file APK rilis (`app-release.apk`) agar bisa saya instal di HP Android.**
