# DOKUMENTASI RESMI RESPONSI PEMROGRAMAN MOBILE
## APLIKASI PRAKIRAAN CUACA "CUACA KITA"

**Mata Kuliah:** Pemrograman Mobile  
**Program Studi:** Informatika – Universitas Jenderal Soedirman (Unsoed)  
**Tautan Video YouTube:** [https://youtu.be/2x8j4a--fZw](https://youtu.be/2x8j4a--fZw)  

---

## 1. RINGKASAN APLIKASI

Aplikasi **"Cuaca Kita"** adalah aplikasi mobile multiplatform berbasis framework **Flutter (versi 3.47+)** dengan bahasa **Dart (versi 3.13+) null-safety**. Aplikasi ini menyediakan informasi kondisi cuaca saat ini dan prakiraan 7 hari ke depan dengan mengonsumsi data langsung dari **Open-Meteo REST API** secara real-time tanpa data tiruan atau hardcoded.

Aplikasi dirancang dengan standar arsitektur industri **Model-View-ViewModel (MVVM)**, menggunakan **Provider** sebagai state management reaktif, **SharedPreferences** sebagai local storage persisten, dan antarmuka bertema **Glassmorphism Dark Theme** yang elegan dan responsif.

---

## 2. STRUKTUR APLIKASI & ARSITEKTUR MVVM

### 2.1 Diagram Aliran Data (Data Flow Architecture)

```
┌────────────────────────────────────────────────────────┐
│                        VIEW                            │
│           HomeScreen | SearchScreen | Widgets          │
│        (Hanya menampilkan UI & membaca ViewModel)      │
└───────────────────────────┬────────────────────────────┘
                            │ Consumer / context.read()
┌───────────────────────────▼────────────────────────────┐
│                      VIEWMODEL                         │
│           WeatherViewModel | SearchViewModel           │
│   (ChangeNotifier, ViewState, Debounce, notifyListeners)│
└───────────────────────────┬────────────────────────────┘
                            │ Method call
┌───────────────────────────▼────────────────────────────┐
│                      REPOSITORY                        │
│                  WeatherRepository                     │
│         (Single Source of Truth / Abstraksi Data)      │
└───────────────────────────┬────────────────────────────┘
                            │ Delegasi tugas
┌───────────────────────────▼────────────────────────────┐
│                       SERVICES                         │
│  WeatherApiService | GeocodingApiService | LocalStorage │
│     (HTTP GET via package `http` & SharedPreferences)  │
└───────────────────────────┬────────────────────────────┘
                            │ Network / Storage I/O
┌───────────────────────────▼────────────────────────────┐
│                     DATA SOURCE                        │
│   Open-Meteo REST API (Online) / SharedPreferences (Disk)│
└────────────────────────────────────────────────────────┘
```

### 2.2 Penjelasan MVVM

1. **Model (`lib/models/`)**:
   - `LocationModel`: Memetakan identitas lokasi (id, name, latitude, longitude, country, admin1). Dilengkapi fungsi serialisasi `toJsonString()` dan `fromJsonString()` untuk penyimpanan SharedPreferences, serta `operator ==` dengan toleransi floating-point presisi untuk mencegah duplikasi data favorit.
   - `CurrentWeatherModel`: Memetakan parameter cuaca saat ini (`temperature_2m`, `relative_humidity_2m`, `apparent_temperature`, `precipitation`, `weather_code`, `wind_speed_10m`).
   - `DailyForecastModel`: Memetakan array paralel harian dari API menjadi list objek per hari (`time`, `weather_code`, `temp_max`, `temp_min`, `precipitation_probability_max`).
   - `WeatherModel`: Entitas gabungan yang menampung cuaca terkini dan prakiraan 7 hari.

2. **View (`lib/views/`)**:
   - `HomeScreen`: Menampilkan cuaca lokasi aktif (default: Kalimanah Kulon, Purbalingga), hero temperature 82px, kartu 2x2 metriks kaca, dan daftar 7 hari dengan highlight baris "Hari Ini".
   - `SearchScreen`: Menyediakan input pencarian kota dengan debounce 500ms, daftar hasil pencarian real-time, daftar favorit (dengan gesture swipe-to-delete), dan riwayat pencarian (dengan tombol hapus semua).
   - Seluruh View murni stateless/stateful widget tanpa logika HTTP GET langsung.

3. **ViewModel (`lib/viewmodels/`)**:
   - `WeatherViewModel`: Mengatur state cuaca menggunakan enum `ViewState` (`initial`, `loading`, `success`, `empty`, `error`). Begitu data diterima dari Repository, ViewModel memanggil `notifyListeners()`.
   - `SearchViewModel`: Mengatur pencarian kota dengan timer debounce 500ms, memuat data lokal dari constructor, dan menangani toggle simpan/hapus lokasi favorit.

4. **Repository (`lib/repositories/`)**:
   - `WeatherRepository`: Berperan sebagai jembatan pemisah. ViewModel tidak perlu mengetahui apakah data berasal dari REST API atau cache lokal.

5. **Service (`lib/services/`)**:
   - `WeatherApiService`: Bertanggung jawab atas HTTP request ke endpoint forecast.
   - `GeocodingApiService`: Bertanggung jawab atas HTTP request ke endpoint search geocoding.
   - `LocalStorageService`: Bertanggung jawab atas operasi I/O SharedPreferences.

---

## 3. IMPLEMENTASI API OPEN-METEO

### 3.1 Endpoint Geocoding (Pencarian Lokasi)
- **URL Base:** `https://geocoding-api.open-meteo.com/v1/search`
- **Method:** `HTTP GET`
- **Query Parameter:**
  - `name`: Kata kunci pencarian (misal: "Purbalingga", "Jakarta")
  - `count`: `10`
  - `language`: `id` (Bahasa Indonesia)
  - `format`: `json`
- **Karakteristik Response:** Menghasilkan array `results`. Jika kota tidak ditemukan, field `results` bernilai `null` dan ditangani secara aman menghasilkan state `ViewState.empty`.

### 3.2 Endpoint Weather Forecast (Prakiraan Cuaca)
- **URL Base:** `https://api.open-meteo.com/v1/forecast`
- **Method:** `HTTP GET`
- **Query Parameter:**
  - `latitude`: Koordinat lintang lokasi (misal: `-7.4050` untuk Kalimanah Kulon)
  - `longitude`: Koordinat bujur lokasi (misal: `109.3360` untuk Kalimanah Kulon)
  - `current`: `temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m`
  - `daily`: `weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max`
  - `timezone`: `auto` *(Wajib: memastikan data waktu disesuaikan otomatis ke zona lokasi, yaitu WIB/GMT+7)*
  - `forecast_days`: `7`

### 3.3 Pemenuhan 9 Field API

| No | Parameter Wajib | Field API Open-Meteo | Komponen Tampilan di Aplikasi |
|:--:|---|---|---|
| 1 | Suhu saat ini | `current.temperature_2m` | `CurrentWeatherCard` (Tipografi raksasa 82px) |
| 2 | Kelembapan udara | `current.relative_humidity_2m` | `CurrentWeatherCard` (Metriks 2x2 kolom 1) |
| 3 | Suhu yang dirasakan | `current.apparent_temperature` | `CurrentWeatherCard` ("Terasa seperti...") |
| 4 | Curah hujan | `current.precipitation` | `CurrentWeatherCard` (Metriks 2x2 kolom 1) |
| 5 | Kode kondisi cuaca | `current.weather_code` | `WeatherCodeMapper` ➔ Ikon Material + Teks Indonesia |
| 6 | Kecepatan angin | `current.wind_speed_10m` | `CurrentWeatherCard` (Metriks 2x2 kolom 2) |
| 7 | Suhu maksimum harian | `daily.temperature_2m_max` | `ForecastTile` (Rentang Max° harian) |
| 8 | Suhu minimum harian | `daily.temperature_2m_min` | `ForecastTile` (Rentang Min° harian) |
| 9 | Peluang hujan maksimum | `daily.precipitation_probability_max` | `CurrentWeatherCard` (Hari ini) & `ForecastTile` (Badge chip kontras tinggi) |

---

## 4. PENYIMPANAN LOKAL (LOCAL STORAGE & PERSISTENCE)

Aplikasi mengimplementasikan library **`shared_preferences`** untuk menyimpan data secara permanen di storage internal perangkat:

1. **Lokasi Favorit (`favorites`)**:
   - Disimpan dalam bentuk `List<String>` berisi JSON hasil serialisasi `LocationModel.toJsonString()`.
   - Dicek duplikasi berdasarkan koordinat latitude & longitude sebelum disimpan.
   - Dilengkapi interaksi **Swipe-to-Dismiss** untuk menghapus dan SnackBar konfirmasi saat ditambahkan.
2. **Riwayat Pencarian (`search_history`)**:
   - Menyimpan otomatis lokasi yang dipilih dari hasil pencarian.
   - Dibatasi maksimal 10 item terbaru tanpa duplikasi (item terbaru diletakkan di indeks teratas).
   - Dilengkapi tombol cepat **"Hapus Semua"**.
3. **Lokasi Terakhir (`last_location`)**:
   - Setiap kali pengguna memilih kota, koordinat dan nama lokasi disimpan sebagai lokasi terakhir.
   - Saat aplikasi dimatikan secara total dan dibuka kembali, aplikasi otomatis memuat kota terakhir tersebut.
4. **Auto-Seed Awal**:
   - Saat aplikasi pertama kali dipasang, penyimpanan lokal otomatis memuat lokasi default **Kalimanah Kulon, Purbalingga** sehingga pengguna langsung memiliki data tersimpan untuk diuji.

---

## 5. HASIL ANALISIS STATIS DAN UNIT TESTING

### 5.1 Analisis Statis (`flutter analyze`)
Hasil pengujian linter resmi Flutter:
```
PS D:\FlutterProjects\pemmob\weather99> flutter analyze
Analyzing weather99...
No issues found! (ran in 3.4s)
```
- Bebas dari error kompilasi
- Bebas dari warning
- Bebas dari penggunaan method/properti deprecated
- 100% Dart Null-Safety

### 5.2 Unit Testing (`flutter test`)
Hasil pengujian unit test pada `test/widget_test.dart`:
```
PS D:\FlutterProjects\pemmob\weather99> flutter test
00:20 +18: All tests passed!
```
- Pengujian parsing JSON `LocationModel` (termasuk handling field null)
- Pengujian roundtrip serialisasi `toJsonString` & `fromJsonString`
- Pengujian perbandingan equality koordinat
- Pengujian parsing `CurrentWeatherModel` (konversi num to double)
- Pengujian penggabungan array paralel `DailyForecastModel`
- Pengujian model agregasi `WeatherModel`
- Pengujian pemetaan kode cuaca WMO `WeatherCodeMapper` beserta fallback kode tak dikenal

---

## 6. SCREENSHOT APLIKASI

Tangkapan layar resolusi penuh telah disematkan di file [`README.md`](../README.md) dengan rincian file:
1. `screenshots/homescreen.png`: Tampilan Home Screen cuaca Kalimanah Kulon.
2. `screenshots/search1.png`: Tampilan Search Screen bagian Favorit & Riwayat Pencarian.
3. `screenshots/search2.png`: Tampilan Search Screen saat pencarian realtime Geocoding API.

---

