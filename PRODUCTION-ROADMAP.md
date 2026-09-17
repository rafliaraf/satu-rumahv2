# SATU RUMAH: audit proses bisnis dan roadmap production

Tanggal audit: 8 September 2026. Baseline: branch `ui/anti-slop-consistency-pass`, termasuk perubahan kerja yang belum di-commit. Penanggung jawab analisis dan sintesis: Astra; pemindaian dibagi ke empat subagent GPT 5.6 Luna dengan reasoning max.

Status dokumen: rencana implementasi untuk ditinjau, bukan bukti kelulusan production. Pembuatan dokumen ini tidak mengimplementasikan backend, panel admin Laravel, atau deployment. File ditempatkan di root repo karena folder docs/ diabaikan oleh aturan Git saat ini.

## 1. Kesimpulan

Urutan besar pengembang mengajukan, admin memverifikasi, Perwaskim melakukan survey, lalu admin memproses BA/SK sudah menjadi fondasi yang masuk akal. Implementasinya belum dapat dinyatakan benar untuk operasional: guard Flutter dan backend berbeda, beberapa hasil hanya berupa state lokal, dan dokumen kebutuhan memiliki konflik tentang cakupan monitoring. Kebenaran terhadap SOP dinas belum dapat disahkan dari kode atau mockup.

Prioritas berikutnya adalah menetapkan kontrak proses bisnis, menjalankan backend yang dapat diuji, kemudian menghubungkan satu alur lengkap dengan data tersimpan. Konsistensi visual tetap dipertahankan selama integrasi.

## 2. Batas audit dan cara membaca bukti

- Sumber utama: kode aktif di `lib/`, sumber PHP di `backend/`, skema database, konfigurasi platform, dan test yang tersedia.
- Dokumen `docs/guide/`, `docs/product_flow_stages_1_5.md`, `CODEBASE-SCAN-REFERENCE.md`, dan `UI-UX-AUDIT-WORKING-MEMORY.md` merupakan konteks. Pernyataan lama seperti "selesai", "aman", atau "BA nyata" harus diperiksa terhadap implementasi.
- Temuan kode PHP adalah analisis statis terhadap sumber yang belum memiliki runtime Laravel lengkap di folder `backend/`. Ini bukan laporan eksploitasi terhadap server yang sedang berjalan.
- Tidak ada persentase kesiapan, SLA, atau estimasi tanggal selesai yang direka. Fase selesai ketika kriteria penerimaannya terbukti.
- Referensi file dan nomor baris berlaku untuk baseline audit ini; nomor baris dapat berubah saat implementasi.
- Antislop digunakan terbatas pada C-2, C-4, C-5 serta R-26, R-27, R-35, R-36, R-38: aksi berfungsi, keadaan gagal tertangani, dan klaim punya bukti. Audit ini tidak memberikan sertifikat kelulusan visual atau menjalankan wizard instalasi skill.

### Kontrak MVP yang sudah tersedia

Pemindaian menemukan `.scratch/satu-rumah-laravel-admin/spec.md`, berstatus `ready-for-agent`, dengan keputusan per 18 Agustus 2026 dan 11 ticket di folder `issues/`. Dokumen ini menjadi acuan target bisnis production, sedangkan `docs/product_flow_stages_1_5.md` menjelaskan perilaku prototipe lokal. Jika keduanya berbeda, catat gap implementasi; jangan otomatis menganggap perilaku prototipe sebagai aturan yang disahkan. Arahan user pada sesi ini menunda UI panel admin Laravel, sehingga sequencing panel di spec lama disesuaikan menjadi R8.

Keputusan yang diadopsi tanpa meminta persetujuan ulang:

- Satu Laravel monolith; panel admin dirender Laravel, tanpa SPA admin terpisah. Tiga role kanonik: admin, pengembang, perwaskim (`spec.md:92`).
- Akun awal melalui local/testing seeder atau provisioning internal; tidak ada self-registration, CRUD pengguna panel, SSO, atau role dinamis pada MVP (`spec.md:102`).
- Katalog backend read-only: lima slot perusahaan dan sebelas slot perumahan, seluruh 16 wajib untuk semua tipe (`spec.md:119`). Lima perusahaan: ktp, nib, npwp_doc, asosiasi, legalitas. Sebelas perumahan: surat_permohonan, info_intensitas_ruang, bukti_kepemilikan_lahan, bukti_tpu, rekomendasi_teknis_dinas, andalalin, rekomendasi_air_bersih, rekomendasi_listrik, pernyataan_psu, penanggungjawab_teknis, proposal_pembangunan.
- Minimal satu file teknis, boleh multi-file; 21 kategori hanya checklist cakupan, bukan 21 upload wajib. PDF/DWG/DXF/ZIP diperbolehkan untuk teknis, RAR ditolak, maksimal 10 MB per file (`spec.md:128`).
- Satu file aktif per slot dan riwayat versi. Versi pengganti kembali belum diperiksa; revisi kembali ke tahap asal setelah lolos review (`spec.md:136`).
- Survey harus terkait pengajuan dan schedule; satu Perwaskim ditugaskan; reschedule mempertahankan riwayat (`spec.md:168`). Monitoring mandiri bukan baseline MVP ini.
- Dokumen final adalah PDF private yang diunggah Admin, maksimal 10 MB, dan wajib sebelum selesai (`spec.md:184`). Tanda tangan elektronik tidak termasuk MVP.
- Notifikasi hanya in-app dan penerima eksplisit. Limit kontrak: login 5/menit per identitas+IP, API 60/menit per user, upload 30/10 menit per user (`spec.md:176,200`). Angka ini berasal dari spec, bukan SLA yang dihasilkan audit.

Tidak ada bukti SOP dinas yang ditandatangani ikut diaudit. Acuan di atas adalah kontrak proyek; detail kewenangan formal BA/SK dan penutupan perbaikan fisik masih perlu dilengkapi.

## 3. Keputusan proses yang harus ditetapkan

Daftar berikut memisahkan keputusan yang sudah diadopsi dari detail yang masih terbuka. R0 merekonsiliasi dokumen dan hanya meminta keputusan yang belum ada; tidak membuka ulang seluruh spec. Pengembangan fondasi yang independen dapat berjalan.

| ID | Keputusan | Alasan dan usulan awal |
|---|---|---|
| D01 | Cakupan monitoring | SUDAH ADA: MVP mengikuti monitoring terkait pengajuan dan schedule dari spec. Tandai guide standalone sebagai konteks lama. Bila diminta lagi, monitoring mandiri menjadi perluasan eksplisit dan tidak dapat meloloskan pengajuan lewat nama sama. |
| D02 | Siapa yang boleh memverifikasi teknis, memfinalkan BA, dan menyetujui SK? | SUDAH ADA: Admin mereview/approve dan mengunggah PDF final, Perwaskim memfinalkan laporan tugasnya. TERBUKA: pengesahan BA serta pejabat formal di dokumen. Tidak otomatis memerlukan role tambahan atau approval berlapis. |
| D03 | Apa makna draft dan `pengajuanBaru`? | Submit saat ini langsung masuk `verifikasiAdministrasi`, sementara dokumen alur menyebut draft/baru. Usulan: draft disimpan terpisah dari antrian yang sudah disubmit; admin menerima record setelah submit berhasil. |
| D04 | Bagaimana revisi ditinjau ulang? | SUDAH ADA: versi baru null/belum diperiksa; admin memverifikasi ulang sebelum revisi lolos. Flag resubmit tidak boleh menjadi bypass. Penerimaan massal hanya boleh jika tetap mencatat review versi/item dan tidak mengabaikan penolakan. |
| D05 | Bagaimana perbaikan fisik/RTL ditutup? | Perbaikan drainase atau pekerjaan lapangan tidak selalu berarti mengganti dokumen. Tentukan bukti penyelesaian, penanggung jawab, tenggat jika berlaku, dan kapan survey ulang diperlukan. |
| D06 | Apa syarat BA dan SK dianggap final? | SUDAH ADA: PDF persetujuan akhir diunggah Admin secara private, maksimal 10 MB; tanda tangan elektronik di luar MVP. TERBUKA: status pengesahan BA, format/keunikan nomor, pejabat dan cara koreksi. Preview, file tersimpan dan pengesahan adalah kondisi berbeda. |
| D07 | Hasil `perluEvaluasiLanjutan` boleh lanjut ke persetujuan? | SUDAH ADA: spec melarang hasil ini langsung selesai. TERBUKA: apakah tetap survey atau masuk review persetujuan yang tertahan, serta jalur survey ulang. Usulan default sebelum keputusan: blokir persetujuan survey hingga tindak lanjut diterima. |
| D08 | Siapa mengelola akun dan kepemilikan perusahaan? | SUDAH ADA: provisioning internal, tanpa registrasi/CRUD panel; pengembang hanya miliknya, Perwaskim hanya assignment. TERBUKA: operator provisioning/reset/nonaktif dan apakah satu perusahaan mempunyai beberapa user; jangan membangun multi-tenant secara otomatis. |
| D09 | Apa cakupan rilis pertama? | Tentukan Android, Flutter Web, atau keduanya; fasilitas hosting, domain, database, storage dan pengelolanya. Panel admin Laravel adalah tambahan kemudian, tetapi identitas dan aturan bisnisnya disiapkan sekarang. |
| D10 | Aturan dokumen, retensi, dan pembatalan? | SUDAH ADA: 16 wajib, multi-file teknis, 21 kategori opsional dan batas 10 MB. TERBUKA: retensi, operator akses data, serta pembatalan/penolakan terminal jika dibutuhkan. Jangan mempertahankan katalog lama Flutter sebagai master. |

## 4. Kontrak transisi yang direkomendasikan

Ini rancangan untuk disahkan, bukan klaim SOP resmi. Nama enum yang sudah ada dapat dipertahankan melalui adapter API; jangan mengubah status hanya demi mengganti istilah. Monitoring final dan PDF persetujuan akhir adalah kewajiban spec. Syarat pengesahan/artefak BA tambahan mengikuti D06; bila UI tetap menawarkan BA, file tersebut wajib nyata dan dapat diakses, bukan sekadar nama file.

| Kondisi | Aktor dan aksi | Syarat server | Hasil yang harus tersimpan |
|---|---|---|---|
| Draft | Pengembang pemilik menyimpan/mengirim | Simpan draft: hanya field yang diisi divalidasi. Submit: data lengkap, persetujuan, 16 slot dan minimal satu file teknis tersedia | Draft belum masuk antrean; submit membuat satu pengajuan dalam verifikasi administrasi dan bukti pengiriman |
| Verifikasi administrasi | Admin menerima atau meminta revisi | Paket dokumen saat ini lengkap, keputusan review tercatat, tidak ada penolakan belum terselesaikan | Masuk teknis atau revisi dengan asal tahap dan item yang diminta |
| Perlu perbaikan | Pengembang pemilik mengirim revisi | Permintaan masih terbuka, seluruh item relevan dipenuhi | Versi dokumen baru dan status menunggu review; tidak otomatis disetujui |
| Review revisi | Admin menerima/menolak ulang | Menilai versi baru; keputusan eksplisit sesuai D04 | Kembali ke jalur tahap asal, atau revisi lanjutan dengan riwayat utuh |
| Verifikasi teknis | Admin/petugas berwenang menjadwalkan survey | Dokumen teknis dan keputusan yang diwajibkan sah; petugas aktif dan berwenang | Penugasan ber-ID, jadwal aktif, instruksi, dan penerima notifikasi |
| Survey lapangan | Perwaskim yang ditugaskan menyimpan draft/final | Pengajuan, jadwal aktif, dan petugas cocok; data serta RTL valid | Laporan final terkait jadwal/putaran; artefak BA berstatus terpisah bila termasuk D06 |
| Hasil tidak sesuai/evaluasi lanjutan | Admin meminta tindak lanjut | Catatan temuan dan bukti yang diperlukan jelas | RTL terbuka, tanggapan pengembang dan survey ulang bila diperlukan; tidak meloloskan persetujuan |
| Survey diterima | Admin menyetujui tahap | Laporan final untuk putaran aktif diterima; BA memenuhi D06; RTL penghambat selesai | Masuk persetujuan dengan rujukan versi laporan dan BA yang dipakai |
| Persetujuan | Pejabat/petugas berwenang mencatat SK dan menyelesaikan | SK tersimpan, terhubung dan disahkan sesuai D02/D06 | Selesai, nomor dan versi SK, aktor/waktu/keputusan tercatat |
| Selesai | Pengguna yang berhak melihat/mengunduh | Policy kepemilikan dan akses dokumen | Read-only pada jalur normal; koreksi/pembukaan kembali perlu proses eksplisit bila disahkan |

Invariant lintas tahap: server adalah pemutus terakhir; satu aksi tidak boleh melompati tahap; penolakan tidak mengubah data; retry tidak menggandakan keputusan; aksi dari dua perangkat yang memakai versi lama ditolak sebagai konflik; laporan dengan nama perumahan sama tidak menjadi bukti milik pengajuan lain.

## 5. Temuan kode

Prioritas: P0 memblokir runtime/rilis atau menembus batas akses inti; P1 dapat menghasilkan keputusan/data salah atau alur tidak selesai; P2 mengurangi ketahanan/kejelasan. Semua temuan masih TERBUKA. Dampak PHP ditelusuri secara statis; runtime API belum tersedia untuk pengujian request.

Singkatan sumber di tabel: PC = `backend/app/Http/Controllers/Api/PengajuanController.php`; MC = `backend/app/Http/Controllers/Api/MonitoringController.php`; NC = `backend/app/Http/Controllers/Api/NotifikasiController.php`; VC = `lib/features/pengajuan/presentation/providers/pengajuan_verifikasi_controller.dart`; MF = `lib/features/monitoring/presentation/providers/monitoring_form_provider.dart`.

### A. Backend dan batas akses

| ID | Prioritas | Bukti dan pemicu | Dampak serta arah perbaikan | Fase/test |
|---|---|---|---|---|
| F01 | P0 | Inventaris `backend/` tidak memiliki composer.json/lock, artisan, bootstrap/app.php, config auth atau test harness. `backend/app/Models/User.php:8` memakai Sanctum; migration token tidak tersedia | Fresh checkout belum menjadi aplikasi Laravel runnable. Bootstrap dengan versi terpilih, migration auth dan CI sebelum menyatakan API berjalan | R1; boot/migration/route/auth smoke |
| F02 | P0 | PC:127 membaca `$pengajuan->status_tahap` sebelum lookup record | Endpoint approve akan gagal. Muat record dengan policy/transaction. Lolos PHP lint tidak mendeteksi variabel runtime ini | R1/R4; T07/T09 |
| F03 | P0 | PC:96, MC:136 dan `backend/routes/api.php:49` tidak menerapkan owner/assignment/admin policy pada detail dan metrics | Setelah runtime hidup, user terautentikasi dapat meminta record lintas pemilik atau metrics admin. Terapkan policy pada list/detail/mutasi/file | R2; T01/T02/T06 |
| F04 | P1 | PC:39 dan MC:64 memakai Request biasa. Rules di `backend/app/Http/Requests/StorePengajuanRequest.php:16` dan StoreMonitoringRequest.php:14 tidak dipakai controller | Validasi dokumen wajib dan limit foto yang terlihat di FormRequest tidak aktif; tipe anggota array salah dapat mencapai trim(). Sambungkan validator dan uji nested types, tanggal, referensi file | R3/R4; T03/T07 |
| F05 | P1 | PC:137 mencari laporan lewat ID ATAU nama; :150 hanya menolak hasil tidak sesuai; :159 melanjutkan teknis tanpa schedule, persetujuan tanpa SK dan default ke selesai | Cacat transisi laten setelah F02 diperbaiki. Nama sama, evaluasi lanjutan dan bukti tidak lengkap dapat memberi keputusan salah. Gunakan matriks transisi dan putaran aktif | R4; T06-T10 |
| F06 | P1 | PC:184 dan :221 tidak membatasi asal tahap; assignment hanya required. MC:91 menerima schedule ID/pengajuan ID tanpa mencocokkan petugas | Jadwal dapat mengubah tahap yang tidak layak; petugas dapat mengirim untuk tugas lain atau pasangan schedule/pengajuan berbeda. Validasi state, FK, role dan assignment | R2/R4; T02/T06/T08 |
| F07 | P0 | NC:15 memberi null-user notification ke semua user, padahal PC:77 menganggapnya untuk admin; NC:25 mengubah read status berdasar ID tanpa owner; :36 mengubah broadcast secara global | Informasi lintas penerima terbuka dan read status dapat diubah orang lain. Gunakan penerima eksplisit dan read receipt per user | R2/R4; T01/T12 |
| F08 | P1 | PC:58, :191, :231 dan MC:100 melakukan beberapa write tanpa transaksi/idempotency | Gagal di tengah proses meninggalkan status/notifikasi/jadwal parsial; retry dapat menggandakan. Tambah transaksi, constraints, intent key dan retry notifikasi setelah commit | R3/R4; T10/T11 |
| F09 | P1 | MC:87 memakai detik dikali 1000; PC:53 memilih 900 kemungkinan ID per hari; PC:237 memakai waktu detik dan angka acak untuk schedule | Dua laporan pada detik sama berbenturan ID. Gunakan ID sesuai konkurensi dan constraint/retry; ID waktu bukan pengganti idempotency | R1/R4; T10 |
| F10 | P1 | MC:17 dan `lib/features/monitoring/data/models/monitoring_model.dart:14` membuat nomor BA hanya dari bulan/tahun; migration `2026_07_20_000004_create_monitoring_models_table.php:15` tanpa uniqueness nomor | Laporan pada bulan sama bernomor sama. Sahkan D06 lalu implementasikan alokasi nomor atomik dan aturan koreksi/pembatalan | R4; T09/T10 |
| F11 | P1 | PC:71 menyimpan uploadedDocs kiriman client; MC:119 menyimpan photoPaths. `backend/app/Services/BaPdfService.php:28` hanya menyusun array payload | Tidak ada bukti upload/download privat atau PDF backend tersimpan. Path string tidak membuktikan bytes dan hak akses. Bangun lifecycle file dan metadata artefak | R3/R4; T03/T09/T11 |
| F12 | P1 | `backend/routes/api.php:29` sampai akhir belum menyediakan resubmit revisi, upload/download dokumen/BA/SK, daftar tugas dan finalize terpisah. `backend/app/Models/Pengajuan.php:58` belum mengirim semua state revisi/BA/SK/history Flutter | Menghubungkan Dio saja belum menyelesaikan alur. Lengkapi kontrak, resource/adapter dan schema sebelum mengganti fixture | R1/R3/R4/R5; T04/T08/T09 |
| F13 | P1 | `backend/routes/api.php:20` tidak mendeklarasikan throttle; `backend/app/Http/Controllers/Api/AuthController.php:30` membuat token; :52 hanya logout token; `backend/database/seeders/DatabaseSeeder.php:17` berisi akun demo | Proteksi login/expiry dan lifecycle belum terbukti; logout belum siap langsung untuk session web. Tetapkan limiter/revocation/expiry dan seeding per environment | R2/R8; T02/T13/T16 |
| F14 | P1 | Migration `backend/database/migrations/2026_07_20_000007_create_survey_schedules_table.php:17` dan `2026_07_20_000008_add_survey_schedule_id_to_monitoring_models_table.php:11` membuat referensi assignment/schedule tanpa FK yang memadai | Referensi petugas/schedule dapat tidak valid. Tambah FK/index/constraint dengan strategi migrasi dan validasi role pada DB target | R1/R4; T06/T10 |

F05 bukan klaim endpoint approve sudah bekerja atau telah dieksploitasi: F02 terlebih dahulu menghalangi eksekusinya.

### B. Flutter dan konsistensi proses lintas client

| ID | Prioritas | Bukti dan pemicu | Dampak serta arah perbaikan | Fase/test |
|---|---|---|---|---|
| F15 | P0 | `lib/core/auth/role_session.dart:65` menentukan role dari username; login tidak membuktikan credential server. Data lokal tercatat di `agent_docs/project_overview.md:34` | Auth demo dan state proses-lokal belum melayani pengguna nyata. Hubungkan identity/repository server, pisahkan demo environment dan bersihkan state pergantian akun | R2/R5; T01/T02/T13 |
| F16 | P1 | MF:327 membuat nama BA lalu memanggil upload state. VC:113 hanya memeriksa teks dan satu nama fallback | Finalisasi memberi kesan BA tersedia tanpa file tersimpan. Pisahkan finalisasi laporan dari kesiapan artefak dan uji download aktual | R4/R5; T09 |
| F17 | P1 | VC:254 mengizinkan approve revisi administratif sebelum document guard; :498 menghapus hasil verifikasi versi lama dan :520 menandai revisionSubmitted. Test pengajuan_verifikasi_controller_test.dart:272 justru mengabadikan direct approval | Tidak sesuai target spec yang mewajibkan review versi baru. Ubah aturan dan test terkait agar resubmit belum berarti terverifikasi | R3; T04 |
| F18 | P1 | VC:579 menjadwal ulang lewat _advance; guard survey memakai riwayat final/path tanpa putaran. `lib/features/monitoring/presentation/providers/monitoring_list_provider.dart:25` memilih status survey ATAU tanggal tidak null | Hasil lama belum dibatasi jadwal aktif; tugas bertanggal lama dapat tetap tampil sesudah tahap lanjut. Gunakan schedule ID/putaran/status sebagai sumber penugasan dan guard | R4/R5; T08 |
| F19 | P2 | MF:359 selalu menyatakan tombol approve terbuka setelah finalize, termasuk evaluasi yang ditolak guard | Notifikasi bertentangan dengan kondisi bisnis. Bentuk pesan dari hasil server dan tindak lanjut yang diperlukan | R4/R5; T07/T14 |
| F24 | P1 | VC:62 dan `backend/app/Http/Requests/StorePengajuanRequest.php:23` masih memakai katalog lama, termasuk kkpr_doc/pbg_induk, sedangkan spec.md:119 menetapkan 16 slot berbeda. API serializer belum memuat paket teknis/cakupan | Kelengkapan menurut UI tidak sama dengan kontrak bisnis target. Migrasikan mapping katalog, jangan menganggap file lama otomatis ekuivalen dengan persyaratan baru; tentukan penanganan data lama bila ada | R0/R3/R5; T03 |
| F25 | P1 | `lib/features/pengajuan/presentation/widgets/jadwalkan_survey_modal.dart:152` hanya mengirim tanggal/catatan, meskipun UI punya pilihan petugas; backend PC:226 mewajibkan assigned_perwaskim_id | Pemilihan petugas tidak terbawa ke operasi. Hubungkan ID petugas dan schedule server pada callback/model, lalu uji akun Perwaskim berbeda | R4/R5; T06 |
| F26 | P1 | `lib/features/pengajuan/data/models/hasil_survey_model.dart:55` tidak membaca beritaAcaraPath dalam fromJson; backend Pengajuan serializer juga tidak membawa BA/SK/history | Round-trip API menghilangkan state yang dipakai guard. Buat contract tests serialize/reload dengan versi dokumen, laporan, BA dan SK | R1/R5; T08/T09 |
| F27 | P1 | `lib/features/pengajuan/presentation/screens/pengajuan_detail_screen.dart:810` menampilkan Unduh SK tetapi callback hanya snackbar | Pengembang tidak menerima hasil yang dijanjikan walau UI menyatakan tersedia. Hubungkan authorized download; sampai tersedia beri label jujur (antislop R-26/R-38) | R4/R5; T09/T14 |
| F28 | P2 | `lib/features/monitoring/presentation/widgets/evidence_photo_picker.dart:147` merender path lokal sebagai Image.asset. `hasil_survey_model.dart:38` mensyaratkan foto untuk sudahTerlaksana, sedangkan finalisasi boleh tanpa foto | Evidence lokal dapat gagal terlihat dan status pelaksanaan tidak konsisten. Gunakan renderer sesuai platform; satukan definisi final dan kewajiban evidence | R4/R5; T07/T14 |

### C. Release dan pembuktian operasional

| ID | Prioritas | Bukti dan pemicu | Dampak serta arah perbaikan | Fase/test |
|---|---|---|---|---|
| F20 | P1 | `android/app/build.gradle.kts:32` memakai signingConfigs debug untuk release. `android/app/src/main/AndroidManifest.xml:1` tidak mendeklarasikan INTERNET, sedangkan debug/profile memilikinya | Signing belum siap distribusi; deklarasi network untuk release harus ditetapkan dan merged manifest diperiksa, bukan menganggap debug sama dengan release | R6; T15 |
| F21 | P1 | Inventaris tidak menemukan `.github/workflows`, backend/tests atau integration_test. Dokumen test lama mengacu state kerja sebelumnya | Belum ada bukti build/test otomatis dan end-to-end server untuk commit rilis. CI mulai R1, hasil integrasi dan artifact release ditambahkan bertahap | R1/R5/R6; T01-T15 |
| F22 | P1 | Backend config/storage/public belum ada; tidak ditemukan konfigurasi operasional backup/restore/alert/rollback pada baseline. `.gitignore:47` mengabaikan .env.* | Deployment dan pemulihan belum dapat direproduksi. Sediakan env contoh tanpa secret dengan pengecualian ignore yang tepat, runbook dan bukti restore DB beserta file | R1/R6; T15 |
| F23 | P2 | `web/index.html:21` dan `web/manifest.json:2` masih metadata template; hosting rewrite/HTTPS tidak tersedia. iOS project tanpa DEVELOPMENT_TEAM dan Info.plist tanpa deklarasi privasi fitur native | Selesaikan metadata dan hosting bila web dirilis. Signing dan izin fitur iOS memerlukan validasi macOS bila iOS dipilih; keberadaan folder iOS tidak menjadikannya target wajib | R6 bersyarat D09; T15 |

### D. Konflik kebutuhan yang bukan sekadar bug

Guide `docs/guide/guide-monitoring-evaluasi-satu-rumah.md:5` menempatkan monitoring di luar flow pengajuan dengan admin internal dan input perumahan bebas. Target spec.md:168 sudah memilih monitoring terhubung. D01 menetapkan prioritas sumber ini; standalone tetap menjadi konteks lama, bukan kewajiban tersembunyi pada rilis.

VC:388 mewajibkan dokumen pada mintaPerbaikan; ini belum mewakili tindak lanjut fisik secara mandiri. Penutupan drainase/PSU dan survey ulang membutuhkan D05, bukan sekadar upload ulang berkas.

## 6. Fondasi untuk Flutter dan panel admin Laravel

Arsitektur yang direkomendasikan: satu aplikasi backend Laravel, satu sumber identitas, satu database operasional, dan satu lapisan aturan bisnis. Flutter mengakses API versi `/api/v1`. Panel Laravel yang ditambahkan kemudian menggunakan service/action dan policy yang sama melalui controller web; tidak perlu memanggil API sendiri melalui HTTP jika berada dalam aplikasi Laravel yang sama.

- Login mobile menggunakan token yang dikelola server. Role ditentukan oleh akun server, bukan awalan username atau field kiriman client.
- Login admin web menggunakan session/cookie dengan CSRF dan regenerasi session. Panel dirender Laravel sesuai spec, tanpa SPA terpisah. Flutter Web, jika ikut dirilis sebagai client browser, perlu rancangan cookie/domain sendiri; jangan menyalin penyimpanan token mobile secara otomatis. Dasar mekanismenya: [Laravel Sanctum](https://laravel.com/framework/docs/13.x/sanctum).
- Pisahkan logout token perangkat dan logout session web. Handler token saat ini memanggil `currentAccessToken()->delete()` dan tidak dapat dianggap otomatis cocok untuk session web.
- Usulkan service/action seperti SubmitPengajuan, ReviewRevision, ScheduleSurvey, FinalizeMonitoring dan CompleteApproval. Controller hanya mengurus transport/validasi/policy; aturan transisi tidak disalin ke panel web. Penamaan ini rancangan, belum berupa class yang ada.
- Policy memeriksa role, pemilik perusahaan/pengajuan, penugasan dan status. Menu tersembunyi atau role middleware saja tidak cukup untuk izin per objek. Lihat [Laravel authorization](https://laravel.com/framework/docs/13.x/authorization).
- Transaksi database melindungi perubahan status beserta riwayatnya. Gunakan kontrol versi dan penguncian saat diperlukan; retry idempotent harus punya constraint penyimpanan. File upload dan pengiriman notifikasi tidak otomatis menjadi atomik hanya karena memakai transaksi SQL. Lihat [Laravel database transactions](https://laravel.com/framework/docs/13.x/database).
- Notifikasi menyimpan jenis kejadian, resource ID dan penerima, bukan hanya route Flutter. Flutter dan panel web membentuk tujuan masing-masing dan tetap melewati policy.
- Tetapkan versi PHP/Laravel yang didukung fasilitas hosting saat bootstrap, pin dependency dan lockfile. Referensi framework di dokumen ini bukan bukti versi backend yang sudah terpasang.

## 7. Rencana kontrak API

Endpoint bertanda usulan belum diimplementasikan. Finalisasi nama, payload, error, pagination, authorization dan contoh response dituangkan dalam `docs/api/openapi.yaml` pada R1.

| Area | Sumber yang sudah ada | Perlu disiapkan |
|---|---|---|
| Identitas | POST auth/login, POST auth/logout, GET auth/me | Akun aktif, rate limit, expiration/revocation token, lifecycle akun; session login web saat fase panel |
| Katalog | Model DokumenType dan source seeder | Usulan GET katalog read-only: 16 slot/format/max size/section dan 21 kategori teknis sesuai spec, tanpa CRUD master panel |
| Pengajuan | GET/POST pengajuan, GET pengajuan/{id} | Kepemilikan, pagination, draft/submit sesuai D03, retry idempotent, versi record |
| Dokumen | JSON uploadedDocs dan verifiedDocs | Usulan upload metadata+bytes, versi file, pemeriksaan dokumen yang merujuk versi, download privat yang berizin |
| Revisi | POST pengajuan/{id}/minta-perbaikan | Usulan daftar permintaan revisi, submit tanggapan/versi baru, keputusan review revisi dan riwayat |
| Persetujuan | POST pengajuan/{id}/approve-tahap | Guard terpusat; expectedVersion/expectedStage; tolak lompatan/record selesai; alasan blokir terstruktur |
| Jadwal | POST pengajuan/{id}/jadwalkan-survey | Usulan GET survey-schedules sesuai actor, daftar petugas yang berhak, detail, reschedule/cancel bila disahkan |
| Monitoring | GET/POST monitoring, GET monitoring/{id} | Draft update dan finalize terpisah; hubungan schedule/pengajuan wajib untuk jenis survey; jangan cocokkan nama |
| BA dan SK | Helper payload BA; belum ada endpoint lengkap | Usulan simpan/generate BA, status artefak, download, SK upload dan keputusan final sesuai kewenangan |
| Notifikasi | GET notifikasi, PATCH read/read-all | Penerima eksplisit, read receipt per pengguna, event/resource target, pagination |
| Profil/metrics | GET auth/me dan admin/dashboard-metrics | Policy admin pada metrics; profil memakai identitas server; pengaturan profil hanya yang disahkan |

Aturan kontrak: pilih casing wire format secara konsisten; enum punya daftar nilai dan pemetaan yang diuji; tanggal dikirim sebagai ISO 8601 dengan kebijakan zona waktu yang jelas; jumlah unit integer; luas lahan dan satuan disepakati; ID file bukan local path. Error minimal membedakan 401, 403, 404, 409, 422, dan gangguan server. Gunakan kode alasan yang stabil agar pesan UI tidak menebak dari teks.

Mutasi menerima identitas intent/idempotency key dengan scope akun dan aksi. Key sama dan payload sama mengembalikan hasil tersimpan, key sama dan payload berbeda ditolak; dua aksi berbeda pada versi lama menghasilkan konflik. Retry otomatis tidak diterapkan sembarang pada POST.

## 8. Model data yang dibutuhkan

Gunakan tabel yang ada sebagai dasar setelah diperiksa terhadap kontrak. Jangan menganggap seluruh model berikut wajib menjadi layanan atau tabel terpisah; implementasikan representasi paling sederhana yang menjaga invariant.

- User dan kepemilikan perusahaan sesuai D08, role kanonik, status akun dan identitas petugas.
- Pengajuan dengan owner, status, versi record dan waktu submit; nomor tampilan terpisah dari ID internal bila diperlukan.
- Dokumen dengan jenis, versi, storage key, ukuran/MIME/hash, pemilik, pengunggah dan hasil review versi tersebut.
- Permintaan revisi dengan asal tahap, item dokumen/temuan fisik, tanggapan, keputusan review, dan status penutupan.
- Survey schedule dengan pengajuan, petugas, putaran, status aktif/terlaksana/diganti/dibatalkan sesuai kontrak.
- Monitoring dengan schedule/pengajuan yang valid, actor, status draft/final, evaluasi dan RTL. Artefak BA punya status/file/nomor serta metadata pengesahan yang diperlukan.
- SK dengan pengajuan, file dan metadata pengesahan. Riwayat keputusan menyimpan actor, waktu, versi sebelumnya/sesudah, alasan dan rujukan dokumen.
- Notifikasi penerima dan read receipt; catatan idempotency. Penyampaian notifikasi yang gagal dapat dicoba ulang setelah commit tanpa menggandakan keputusan bisnis.

## 9. Roadmap dan kriteria selesai

Semua fase berikut berstatus BELUM DIEKSEKUSI oleh audit ini. R0 menjadi prasyarat aturan bisnis; pekerjaan bootstrap R1 dapat berjalan sambil keputusan yang relevan diselesaikan. CI dasar dimulai sejak R1, tidak ditunda sampai rilis.

| Fase | Pekerjaan dan hasil | Dependensi | Kriteria keluar |
|---|---|---|---|
| R0: kontrak proses | Adopsi keputusan spec yang sudah ada, tutup detail TERBUKA D01-D10, rekonsiliasi katalog/role/transisi dan skenario; pisahkan panel yang ditunda | Pemilik proses dan baseline audit | Tidak ada keputusan terbuka yang mengubah izin/transisi wajib pada cakupan rilis; setiap keputusan punya pemilik dan catatan |
| R1: backend dapat dijalankan | Bootstrap Laravel lengkap; pin PHP/dependencies; env contoh tanpa secret; database/migration; test harness; OpenAPI awal; CI lint/test | R0 untuk domain; hosting untuk versi | Fresh checkout dapat install, boot, route:list, migrate pada DB uji dan menjalankan test; production tidak seed akun demo |
| R2: identitas dan batas akses | Auth mobile nyata, user lifecycle sesuai scope, policy owner/assignment, limiter, token expiry/revoke, actor audit | R1 + D02/D08 | Akun salah/nonaktif ditolak; user A tidak dapat membaca/mengubah data user B; Perwaskim tidak dapat mengirim tugas petugas lain; metrics admin tertutup |
| R3: dokumen dan submit/revisi | Storage privat; upload/download nyata; versioning; validasi bersyarat; draft/submit; review admin dan resubmit; transaksi/idempotency | R2 + D03/D04/D10 | File tetap ada setelah restart; file user lain ditolak; submit ganda satu hasil; dokumen pengganti perlu keputusan pada versi baru; aturan submit identik di UI/API |
| R4: survey sampai selesai | Penugasan/putaran; draft/final; RTL fisik; BA sesuai D06; keputusan survey; PDF final/SK; riwayat dan notification receipts | R3 + D01/D05/D06/D07 | Putaran lama tidak meloloskan yang baru; hasil negatif tertahan; PDF final/SK dan BA yang diekspos bisa diunduh pengguna berhak; dua persetujuan bersamaan tidak menggandakan atau melompati status |
| R5: integrasi Flutter dan QA nyata | Adapter API, session server, state loading/error/retry; alur lengkap lintas akun/perangkat; pertahankan konsistensi UI | Integrasi bertahap mulai R2/R3, selesai setelah R4 | Pengembang A submit di perangkat A, admin review di perangkat B, petugas finalize di C; refresh/restart mempertahankan data; tidak ada sukses palsu saat API/file gagal |
| R6: staging dan release candidate | Build target yang disepakati; signing; config produksi; CI build; backup/restore; logs/crash/error alert; UAT petugas | R5 | Release artifact teruji pada target nyata; restore dibuktikan; SOP operasional dan rollback tersedia; tidak ada blocker bisnis/akses/data terbuka |
| R7: pilot dan production | Pilot terbatas dengan petugas, pencatatan temuan, perbaikan blocker, keputusan go-live dan pemilik dukungan | R6 + UAT disetujui | Hasil UAT ditandatangani pemilik proses; akses/domain/storage siap; cutover dan rollback disepakati; deploy mendapat otorisasi |
| R8: panel admin Laravel | UI web admin, session login, review dokumen/jadwal/BA/SK sesuai kebutuhan; reuse service/policy | R2-R4 menjadi fondasi; waktu setelah rilis awal sesuai user | Aksi yang sama dari Flutter dan panel menghasilkan keputusan/izin/riwayat yang sama; cross-client conflict dan logout masing-masing teruji |

Urutan implementasi awal yang disarankan: selesaikan kontrak rilis pertama, nyalakan backend beserta policy, buktikan login dan satu pengajuan berfile nyata sampai review admin. Lanjutkan revisi, lalu survey/BA/SK. Setiap irisan dihubungkan ke Flutter dan diuji sebelum memperluas fitur.

### Hubungan dengan ticket yang sudah disiapkan

Semua nama berikut berada di `.scratch/satu-rumah-laravel-admin/issues/` dan masih berstatus ready-for-agent pada inventaris audit. Roadmap tidak membuat duplikat ticket atau mengubah statusnya. Karena user menunda panel, bagian UI web pada ticket lama dipisahkan dari backend/API ketika implementasi dimulai; dependency direvisi secara eksplisit, bukan dianggap seluruh ticket telah selesai setelah separuh pekerjaan. Spec menyebut 12 epic P0 dan 11 ticket yang disetujui; pemetaan epic-ke-ticket belum dibuktikan di audit ini. R0 harus mengecek cakupan tersebut, bukan mengarang epic ke-12 atau menganggapnya otomatis milestone Android.

| Ticket yang ada | Fase roadmap dan penyesuaian |
|---|---|
| 01-secure-laravel-shell-and-auth.md | R1/R2 untuk runtime/auth API dan fondasi session; UI login admin serta browser acceptance di R8 |
| 02-complete-document-submission-api.md | R3, termasuk katalog 16 slot dan multi-file teknis |
| 03-operational-dashboard-and-admin-queue.md | Read API/metrics pada R3-R5; UI antrean panel di R8 |
| 04-submission-detail-and-private-document-access.md | Policy/private file API pada R2/R3; tampilan panel di R8 |
| 05-verification-revision-and-version-history.md | Aturan/review API pada R3; UI panel di R8 |
| 06-survey-scheduling-and-assignment.md | Assignment/reschedule API pada R4; UI panel di R8 |
| 07-field-monitoring-and-admin-review.md | Laporan/finalize dan review API pada R4; UI panel di R8 |
| 08-approval-and-final-document.md | Guard dan file akhir API pada R4; UI panel di R8 |
| 09-in-app-notifications-and-read-state.md | Delivery/read receipt API pada R4; UI panel di R8 |
| 10-api-contract-and-android-handoff.md | Kontrak dimulai setiap irisan R1-R4, handoff lengkap R5. Ticket ini tetap tidak mengimplementasikan Flutter |
| 11-security-regression-and-release-gate.md | Test keamanan sejak R1/R2, gate aplikasi R6; browser panel dinilai lagi R8 |

R5 adalah jalur kerja Flutter terpisah dari ticket tim Laravel, sesuai ownership spec. Roadmap ini mencakup aplikasi keseluruhan; PIC personal dan waktu pelaksanaan tidak ditetapkan otomatis. Operasional R6/R7 memperluas rencana MVP lama sesuai tujuan user menuju production. Asumsi kerja sementara: Admin Flutter yang sudah ada menjadi antarmuka admin rilis awal. D09 menetapkan targetnya; jika tidak dipilih, harus ada antarmuka admin operasional lain sebelum R5/R6 lolos. Penundaan panel tidak boleh menunda endpoint review, assignment, dan persetujuan Admin.

R6/R7 menilai cakupan rilis pertama setelah panel ditunda, bukan mengklaim seluruh MVP Laravel lama selesai. Kriteria browser panel pada ticket 11 tetap terbuka sampai R8. Saat implementasi dimulai, dependency dan acceptance ticket perlu dipisahkan menjadi backend/API serta panel agar status selesai parsial tidak menyamarkan pekerjaan tersisa.

## 10. Paket pengujian wajib

| ID | Skenario | Bukti yang harus ada |
|---|---|---|
| T01 | Dua pengembang berbeda | List/detail/file/notifikasi terisolasi; ID yang ditebak tidak memberi akses |
| T02 | Tiga role + guest/nonaktif | Setiap endpoint diuji untuk role diizinkan dan ditolak; akun tidak aktif/session expired tidak dapat mutasi |
| T03 | Submit valid/tidak lengkap | Seluruh 16 slot wajib dan minimal satu file teknis diuji; 21 kategori tetap opsional; tipe/ukuran termasuk batas 10 MB diuji; data sukses bisa dibaca sesudah restart |
| T04 | Revisi dua putaran | Asal tahap benar, versi baru terkait permintaan, keputusan sebelumnya tidak melekat pada versi baru, penolakan aktif memblokir approve |
| T05 | Tindak lanjut fisik | Temuan lapangan dapat ditanggapi tanpa memalsukan revisi dokumen; penutupan dan survey ulang mengikuti D05 |
| T06 | Penugasan salah dan nama sama | Petugas tidak ditugaskan ditolak; laporan pengajuan A tidak meloloskan B walau nama sama; schedule dan pengajuan harus cocok |
| T07 | Tiga hasil evaluasi | Hasil sesuai hanya meloloskan bila BA dan guard lain lengkap; dua hasil lain wajib RTL dan tetap tertahan sesuai D07 |
| T08 | Survey ulang | BA/laporan lama tidak memenuhi putaran baru; draft baru tidak menggantikan final secara tidak sengaja; penjadwalan ulang terlacak |
| T09 | Artefak final/SK dan BA | PDF final/SK wajib nyata, privat dan terkait record; selesai tanpanya ditolak. Untuk BA yang diwajibkan D06 atau ditawarkan UI, gagal upload/generate tidak memberi status tersedia dan file harus dapat diunduh ulang |
| T10 | Retry dan konkurensi | Submit/finalize/approve berulang menghasilkan satu keputusan; dua request paralel diuji pada engine database target; konflik versi menghasilkan 409 |
| T11 | Gagal di tengah operasi | Gagal simpan riwayat tidak meninggalkan status parsial; gagal notifikasi dapat dipulihkan tanpa mengulang keputusan; file orphan ditangani |
| T12 | Notifikasi multi-user | Membaca milik sendiri tidak menandai milik orang lain; link Flutter dan web memakai resource yang sama dengan policy berlaku |
| T13 | Sesi dan jaringan | Timeout/401/403/422/5xx terlihat benar, input yang belum terkirim tetap dapat dipulihkan, logout tidak membawa data/draft user A ke user B |
| T14 | UI saat data nyata | Loading/empty/error/retry dan progress upload; nama panjang, layar kecil, keyboard web; aksi yang belum tersedia diberi label jujur |
| T15 | Operasional | Build release, konfigurasi target, restore backup, rollback aplikasi/migration yang kompatibel, alert error dan akses operator dibuktikan |
| T16 | Panel admin kemudian | User admin yang sama login web; service/policy memberi hasil yang sama; CSRF/logout web dan token logout mobile terpisah benar |

Test unit/widget lokal tetap berguna untuk validasi dan state UI, tetapi tidak membuktikan database, akses antar-user atau file remote. Kriteria lulus mencakup API integration test dan UAT dengan akun terpisah. Laporan test lama tidak dianggap hasil baru audit ini.

## 11. Gate go-live

- Proses dan role yang termasuk rilis telah disahkan, termasuk PDF final/SK, keputusan cakupan BA pada D06, serta tindak lanjut hasil tidak sesuai.
- Seluruh temuan blocker pada cakupan rilis sudah diperbaiki dan ada test regresinya.
- Fresh checkout dan pipeline menghasilkan build yang dapat ditelusuri ke commit dan konfigurasi; versi dependency terkunci.
- Data, dokumen, hak akses, retry dan konkurensi lolos T01-T13; UI lolos T14 pada target rilis.
- Production tidak memuat login demo, data contoh operasional atau fallback sukses lokal.
- Android memakai signing release yang dikelola, izin network sesuai build, versi/identitas final; untuk web periksa HTTPS, auth domain/cookie, CORS, deep-link refresh dan cache. Rujukan: [Flutter Android release](https://docs.flutter.dev/deployment/android).
- Backup database dan dokumen dapat dipulihkan bersama; log tidak memuat password/token atau isi dokumen pribadi; pemilik dukungan, alert, dan rollback ditetapkan.
- UAT petugas selesai dengan temuan tercatat dan keputusan go-live. Deployment dilakukan setelah izin eksplisit, bukan akibat dokumen roadmap selesai.

## 12. Batas tambahan integrasi

Panel admin Laravel disiapkan melalui API, policy, model identitas, dan service bersama. Implementasi UI panel masuk R8. Push notification eksternal, WhatsApp, GIS/drone, tanda tangan elektronik, Word export, dan offline sync penuh tidak otomatis masuk rilis pertama; masukkan hanya bila kebutuhan operasional disahkan. Notifikasi in-app yang tersimpan dan pemulihan input saat jaringan gagal tetap termasuk alur inti.

## 13. Handoff

### Bukti audit pada sesi ini

- Empat pemindaian Luna max membaca backend, Flutter, dokumen bisnis, dan konfigurasi release; Astra memeriksa ulang jalur persetujuan, revisi, finalisasi BA, notification ownership dan kontrak auth yang menentukan kesimpulan.
- Subagent backend menjalankan `php -l` untuk seluruh file PHP backend dan melaporkan lolos syntax. Ini tidak menguji Laravel boot, variabel runtime, SQL, policy, atau request API.
- Flutter analyze/test/build dan UAT tidak dijalankan ulang pada pekerjaan dokumentasi ini. Hasil terdahulu, termasuk 49 test yang dilaporkan pada revisi UI, bukan sertifikasi production atau hasil baru sesi audit.
- Graphify tidak tersedia di PATH; sumber diperiksa langsung. Helper shell/sandbox awal gagal; pembacaan dan penyuntingan dokumen dilanjutkan memakai jalur tool yang mendapat persetujuan otomatis.
- Deliverable ini hanya menambah dokumen roadmap pada branch kerja yang ada. Status fitur, perbaikan source dan deploy belum berubah akibat audit.

### Paket awal yang dapat langsung dikerjakan

1. Adopsi keputusan yang sudah ada dari spec dan catat hanya detail terbuka D01-D10 beserta pemiliknya. Rekonsiliasi katalog dan pilih skenario T01-T16 yang berlaku untuk target rilis.
2. Bentuk backend runnable di branch implementasi terpisah dari pass UI, dengan manifest/lockfile, env contoh, migration, test DB dan CI. Jangan menjalankan migrate:fresh terhadap database operasional.
3. Tambahkan test gagal yang mereproduksi F02/F03/F04/F07, kemudian perbaiki runtime, batas akses dan validasi sebagai fondasi.
4. Tulis kontrak OpenAPI untuk login/me, satu pengajuan berfile, dan review admin; hubungkan irisan itu ke Flutter dengan dua akun berbeda dan bukti persistence.
5. Lanjutkan fase revisi serta survey/BA/SK setelah contract dan bukti irisan pertama stabil. Panel Laravel menggunakan fondasi tersebut pada R8.

Dokumen ini merupakan titik awal pekerjaan production berikutnya. Implementer membaca bagian keputusan, temuan, dan fase terkait; memilih satu irisan dengan acceptance test yang jelas; mencatat hasil verifikasi baru dan memperbarui status fase hanya setelah terbukti. Jangan menggunakan status visual yang konsisten, keberhasilan `flutter run`, atau keberadaan file controller sebagai bukti kesiapan production.
