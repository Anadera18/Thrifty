# Thrifty

Location-Based Secondhand Fashion Marketplace with AI-Powered Clothing Condition Grading.

---

## 🏗️ Struktur Proyek

- **`frontend/`**: Aplikasi mobile Flutter dengan fitur pencarian berbasis lokasi, marketplace secondhand, dan integrasi AI Condition Grading.
- **`ml/`**: Workspace Machine Learning (MobileNetV2 Dual-Head Transfer Learning) untuk klasifikasi kategori (`Shirt`, `T-Shirt`, `Pants`, `Jacket`) dan grading kondisi (`Grade A`, `Grade B`, `Grade C`, `Grade D`) beserta REST API microservice (FastAPI).
- **`backend/`**: Node.js & Express REST API proxy controller untuk AI grading dan integrasi backend marketplace.
- **`docs/`**: Dokumen proposal PBL, QA test plan, dan aset desain.

---

## ⚡ Cara Menjalankan

### 1. Menjalankan AI/ML Microservice
```powershell
# Jalankan script 1-klik di folder ml
.\ml\run_ml_service.ps1
# Atau klik ganda: ml\run_ml_service.bat
```
Akses Swagger documentation di [http://localhost:8000/docs](http://localhost:8000/docs).

### 2. Menjalankan Flutter App
```powershell
cd frontend
flutter run
```
*(Mendukung Android Emulator, Chrome/Web Server, dan Perangkat Fisik. Jika ML service tidak dijalankan, Flutter secara otomatis menggunakan mesin analisis visual lokal yang cerdas tanpa error).*

### 3. Menjalankan Node.js Backend (Opsional)
```powershell
cd backend
npm install
npm start
```
*(Backend berjalan di port 5000: `http://localhost:5000/api/v1/ai/grade-and-classify`)*.


---

## 📊 Hasil Evaluasi Model AI (Machine Learning)

| Evaluasi | Hasil | Keterangan |
| :--- | :---: | :--- |
| **Akurasi Kategori Pakaian** | **100.00%** | 4 Kelas: *Shirt, T-Shirt, Pants, Jacket* |
| **Akurasi Grading Kondisi** | **84.38%** | 4 Kelas: *Grade A, B, C, D* (Target proposal: $\\ge 80\\%$) |
| **Blind Test Google Drive** | **82.38% Confidence** | 545 Foto pakaian secondhand asli |

Grafik dan visual hasil training & evaluasi dapat dilihat di:
- [Confusion Matrix](ml/reports/confusion_matrix.png)
- [Training Curves](ml/reports/training_curves.png)
- [Drive Test Samples Visual Grid](ml/reports/drive_test_samples.png)
- Folder Hasil: [\ml/reports/\](ml/reports/) dan [\ml/results/\](ml/results/)
