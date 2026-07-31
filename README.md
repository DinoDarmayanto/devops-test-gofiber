Tentu, ini sudah gue susun ulang dan lengkapi sesuai dengan *template* yang lu kasih, digabung dengan konfigurasi Docker dan penjelasan Terraform sebelumnya.

Lu bisa langsung *copy-paste* teks di dalam blok kode di bawah ini ke dalam *file* `README.md` lu:

```markdown
# DevOps Test Submission - GoFiber & Terraform

**Version:** `1.0.0`
**Project Type:** **Golang:** `1.20`
**Build Tool:** `Docker Compose`
**Database:** `Redis`

## Tech Stack

* Golang (GoFiber)
* Redis
* Docker & Docker Compose
* Terraform (GCP)

## Overview

Proyek ini merupakan hasil pengerjaan DevOps Test yang mencakup dua bagian utama:
1. **Docker Scripting:** Melakukan *containerization* untuk aplikasi `hello-world` berbasis GoFiber beserta integrasi Redis menggunakan *multi-stage build* untuk efisiensi ukuran *image*.
2. **Terraform GCP Analysis:** Penjelasan mengenai fungsi *resource*, *flow* kerja Terraform, serta analisis risiko keamanan dari skrip Terraform GCP.

---

## Folder Structure

```text
devops-test-gofiber
├── docker-compose.yml
├── Dockerfile
├── go.mod
├── go.sum
├── main.go
├── README.md
└── test Devops.pdf
```

## Configuration

### Dockerfile dan Docker Compose

File ini merupakan konfigurasi utama aplikasi yang digunakan saat menjalankan project secara lokal.

**Dockerfile:**

```dockerfile
# Stage 1: Builder
FROM golang:1.20-alpine AS builder
WORKDIR /app
COPY . .
RUN go mod tidy
RUN go build -o main .

# Stage 2: Runner (Minimal Image)
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/main .
EXPOSE 3000
CMD ["./main"]

```

**docker-compose.yml:**

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - REDIS_ADDR=redis:6379
    depends_on:
      - redis

  redis:
    image: "redis:alpine"
    ports:
      - "6379:6379"

```

### Environment Variables

Berikut adalah environment variable yang dapat digunakan untuk melakukan override konfigurasi aplikasi.

| Variable | Default Value | Description |
| --- | --- | --- |
| `REDIS_ADDR` | `redis:6379` | Alamat koneksi dari aplikasi web ke container Redis |

## Application Startup

## Build & Run

---

### Run Application

Untuk melakukan *build* dan menjalankan seluruh *service* secara otomatis, gunakan perintah berikut di terminal:

```bash
docker-compose up -d --build

```

---

### Manual Run

Jika ingin menjalankan dan membangun *image* Docker secara manual tanpa Docker Compose:

```bash
# Build image
docker build -t gofiber-app .

# Run container
docker run -d -p 3000:3000 -e REDIS_ADDR=localhost:6379 --name web-app gofiber-app

```

### Application URLs

Setelah aplikasi berhasil berjalan, endpoint berikut dapat diakses:

| Service | URL |
| --- | --- |
| Web App | `http://localhost:3000` |
| Redis | `localhost:6379` |

---

### Startup Verification

Pastikan aplikasi berhasil berjalan dengan melihat log berikut menggunakan perintah `docker-compose logs web`:

```text
 ┌───────────────────────────────────────────────────┐ 
 │                   Fiber v2.x.x                    │ 
 │               [http://127.0.0.1:3000](http://127.0.0.1:3000)               │ 
 └───────────────────────────────────────────────────┘ 

```

Jika log tersebut muncul, maka aplikasi siap digunakan.

### Configuration Description

| Property | Description |
| --- | --- |
| Multi-stage Build | Menggunakan `golang:alpine` sebagai *builder* dan `alpine:latest` sebagai *runner* agar *image* akhir berukuran sangat kecil dan aman. |
| Port Expose | Aplikasi mengekspos port `3000` sesuai instruksi *test*. |

---

## Penjelasan Terraform GCP (DevOps Test)

### 1. Fungsi Tiap Resource dalam Script

| Resource Terraform | Penjelasan Fungsi |
| --- | --- |
| `provider "google"` | Menentukan bahwa cloud provider yang digunakan adalah GCP dengan mendefinisikan Project ID dan Region target. |
| `google_compute_network.vpc_network` | Membentuk sebuah Virtual Private Cloud (VPC) network baru bernama `example-vpc` sebagai jaringan dasar dan terisolasi. |
| `google_compute_firewall.default-allow-http` | Membuat aturan firewall bernama `allow-http` pada VPC yang baru dibuat untuk mengizinkan lalu lintas masuk (ingress) protokol TCP pada port 80 dari seluruh IP internet (`0.0.0.0/0`). |
| `google_compute_instance.default` | Melakukan deployment Virtual Machine (VM) bernama `example-vm` bertipe `f1-micro` di zona `us-central1-a`. Menggunakan sistem operasi Debian 9, meminta IP Publik secara dinamis, dan menjalankan `metadata_startup_script` untuk menginstal Apache2 web server saat menyala. |

### 2. Flow Urutan Kerja Terraform Saat "terraform apply"

1. **Inisialisasi & Validasi:** Terraform memvalidasi sintaks dan memastikan state file sesuai dengan kondisi aktual.
2. **Pembuatan Execution Plan:** Terraform membandingkan kondisi di GCP dengan kode deklaratif, lalu merencanakan pembuatan resource berdasarkan dependensi (VPC harus ada sebelum Firewall dan VM dibuat).
3. **Persetujuan (Approval):** Terraform akan menampilkan plan dan meminta konfirmasi.
4. **Eksekusi API GCP:** Setelah disetujui, Terraform memanggil API GCP. Ia akan membuat jaringan VPC terlebih dahulu. Setelah jaringan siap, aturan Firewall dan VM Instance dibuat.

### 3. Apa yang Terjadi di GCP Setelah Menjalankan Perintah

* Sebuah jaringan virtual (VPC) `example-vpc` berhasil diciptakan.
* Firewall VPC tersebut telah dilonggarkan untuk menerima koneksi masuk pada port 80 dari seluruh dunia.
* Sebuah VM Instance `example-vm` menyala, mendapatkan IP Publik dari Google, dan dapat diakses publik.
* Web server Apache2 otomatis terinstal dan berjalan pada VM tersebut berkat eksekusi skrip *startup*.

### 4. Keuntungan dan Risiko dari Konfigurasi Ini

* **Keuntungan:** Otomatisasi infrastruktur dan *software* sangat cepat. Resource ter-deploy sekaligus tanpa perlu konfigurasi manual via SSH.
* **Risiko Keamanan:**
* Akses terlalu longgar karena `source_ranges = ["0.0.0.0/0"]` tanpa filter `target_tags`.
* Sistem Operasi usang (`debian-9`) yang sudah *End-of-Life*, sehingga rentan terhadap celah keamanan.
* VM terekspos langsung melalui IP Publik tanpa melalui Load Balancer.



### 5. (Bonus) Optimasi dan Perbaikan Keamanan

* **Pembaruan OS Image:** Ganti `debian-9` menjadi versi terbaru yang masih didukung (`debian-11` atau `debian-12`).
* **Penggunaan Network Tags:** Batasi firewall dengan menambahkan `target_tags` pada blok firewall dan `tags` pada blok VM, sehingga port 80 hanya terbuka khusus untuk VM tersebut.
* **Tutup Akses Publik Langsung:** Hapus blok `access_config` agar VM tidak mendapat IP Publik langsung. Akses dirutekan melalui Load Balancer atau IAP.

---

## Prerequisites

* Docker Engine terinstal.
* Docker Compose terinstal.
* Git terinstal (untuk *version control*).

### Testing Recommendation

Untuk memastikan web server GoFiber berjalan dengan baik, lakukan request GET ke *endpoint* root menggunakan `curl`:

```bash
curl http://localhost:3000

```

Respon yang diharapkan: `Hello, World!`

## Changelog

### v1.0.0

* Menambahkan konfigurasi Dockerfile (*multi-stage build*) untuk aplikasi GoFiber `hello-world`.
* Menambahkan konfigurasi `docker-compose.yml` untuk orkestrasi aplikasi web dan Redis.
* Menyusun dokumentasi penjelasan *script* Terraform GCP beserta analisis mitigasi risiko.

---

## License

Copyright © 2026 Dino Darmayanto

All rights reserved.

Project Submission For: DevOps Test

```

```