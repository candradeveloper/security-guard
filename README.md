# 🔐 Security Guard — Flutter App

Security app lengkap dengan PIN Lock, Intruder Selfie, Vault Terenkripsi, dan GPS Tracker.

## ✨ Fitur

| Fitur | Deskripsi |
|-------|-----------|
| 🔒 **PIN Lock** | Kunci 6 digit, shake animation kalau salah, lockout 30 detik setelah 5x salah |
| 📸 **Intruder Selfie** | Foto otomatis pakai kamera depan setelah 2x salah PIN |
| 🗄️ **Vault** | Simpan file terenkripsi AES-256, key disimpan di Android Keystore |
| 📍 **GPS Tracker** | Rekam log lokasi, tampilkan koordinat real-time |
| ⚙️ **Settings** | Ganti PIN, kunci manual |

## 🚀 Setup di Termux

```bash
# Clone repo
git clone https://github.com/USERNAME/security-guard.git
cd security-guard

# Install dependencies
flutter pub get

# Build APK (butuh Flutter + JDK di Termux)
flutter build apk --release
```

## 🤖 GitHub Actions (Recommended)

Push ke GitHub → Actions otomatis build APK!

### Cara setup:
1. Push project ke GitHub
2. GitHub Actions akan otomatis jalan saat push ke `main`
3. Download APK dari tab **Actions → Artifacts**

### Buat release:
```bash
git tag v1.0.0
git push origin v1.0.0
```
APK otomatis di-release ke GitHub Releases!

## 📁 Struktur Project

```
lib/
├── main.dart                  # Entry point
├── screens/
│   ├── pin_setup_screen.dart  # Setup PIN pertama kali
│   ├── pin_lock_screen.dart   # Lock screen dengan intruder detection
│   ├── dashboard_screen.dart  # Menu utama
│   ├── vault_screen.dart      # File vault terenkripsi
│   ├── intruder_screen.dart   # Galeri foto intruder
│   ├── gps_screen.dart        # GPS tracker
│   └── settings_screen.dart   # Pengaturan
├── widgets/
│   └── pin_pad.dart           # Reusable PIN keypad
└── services/
    ├── intruder_service.dart  # Camera capture logic
    └── vault_service.dart     # AES encryption logic

.github/
└── workflows/
    └── build.yml              # GitHub Actions CI/CD
```

## 🔧 Dependencies

- `flutter_secure_storage` — simpan key enkripsi di Android Keystore
- `encrypt` — enkripsi AES-256 untuk Vault
- `camera` — capture foto intruder
- `geolocator` — akses GPS
- `permission_handler` — request runtime permissions
- `shared_preferences` — simpan PIN dan log GPS
- `google_fonts` — Inter font
- `file_picker` — pilih file untuk di-vault

## 📱 Permissions

- `CAMERA` — untuk Intruder Selfie
- `ACCESS_FINE_LOCATION` — untuk GPS Tracker
- `USE_BIOMETRIC` — untuk fingerprint (future feature)

---

Built with ❤️ by **NACDEV**
# security-guard
