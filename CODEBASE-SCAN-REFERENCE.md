# SATU RUMAH — Codebase Size & UI/UX Audit Readiness Scan

Status: inventory read-only, bukan audit UI/UX final.

Tanggal scan: 2026-09-03 (Asia/Jakarta)

Repository: `<repository-root>`

Branch/HEAD saat scan: `main` / `12ab98a1d13023a85c8e93bd525cfcf477bb4fa0`

## Executive verdict

- **Source aplikasi tidak sangat besar.** Runtime utama adalah Flutter/Dart dengan 70 file dan sekitar 17.662 baris. Scope ini masih layak diaudit oleh satu model kuat.
- **Kompleksitas UI/UX cukup tinggi dibanding ukuran file.** Ada 26 screen files, tiga shell role aktif, alur pengajuan lima langkah, alur monitoring tiga langkah, detail Admin yang sangat besar, dan banyak style inline.
- **Workspace secara fisik sangat besar karena artefak lokal**, bukan karena source produk: `build/` sekitar 1,36 GB, `.dart_tool/` sekitar 432 MB, graph output sekitar 31 MB, dan `.agents/` sekitar 91 MB. Direktori tersebut jangan dimasukkan sebagai surface UI aplikasi.
- Untuk audit lintas-role yang menghasilkan sintesis A–G, **Sol sebagai lead/synthesizer + Luna Max sebagai pass spesialis read-only** adalah konfigurasi paling aman. Luna Max tunggal masih memadai bila ingin mengurangi biaya atau bila audit dilakukan dalam beberapa pass terarah.

## 1. Snapshot ukuran repository

Angka berikut berasal dari inventory filesystem dan `git ls-files`; generated/cache/work directories dibedakan dari source produk.

| Surface | File | Baris / ukuran | Interpretasi |
|---|---:|---:|---|
| Tracked repository total | 253 | — | Termasuk platform, docs, config, tests, backend |
| Flutter runtime `lib/` | 70 `.dart` | 17.662 baris | Surface utama audit UI/UX |
| Tests `test/` | 13 `.dart` | 1.379 baris | Unit/widget/flow contract tests; bukan visual regression suite |
| Laravel-style backend | 25 `.php` | 1.680 baris | Konteks role/state/API; runtime belum terverifikasi |
| Native/platform shells | 123 tracked files | — | Android/iOS/Web/Windows/Linux/macOS; mayoritas template/config |
| Tracked PNG assets | 37 | — | Tidak ada direktori `assets/` aktif di root Flutter |
| Local files, termasuk generated | 4.408 | — | Tidak cocok dijadikan corpus audit langsung |
| Filtered non-generated/workdir files | 742 | — | Masih mencakup docs/tooling lokal; bukan semua product source |

### Disk-heavy local directories (exclude from UI corpus)

| Directory | Files | Approx. size | Perlakuan |
|---|---:|---:|---|
| `build/` | 2.863 | 1.358,59 MB | Generated build output; exclude |
| `.dart_tool/` | 128 | 431,53 MB | Dependency/cache; exclude |
| `.agents/` | 337 | 90,55 MB | Skill/tool corpus; exclude dari product UI |
| `graphify-out/` | 518 | 31,31 MB | Derived graph/report; gunakan hanya sebagai navigational evidence |
| `docs/` | 89 | 7,93 MB | Include only relevant product/design references |
| `.scratch/` | 98 | 0,53 MB | Historical workflow evidence; exclude from UI source |
| `outputs/` | 21 | 2,40 MB | Generated/work artifacts; exclude |
| `spreadsheet_work/` | 33 | 10,00 MB | Work artifacts; exclude |
| `tmp/` | 4 | 0,52 MB | Temporary artifacts; exclude |

## 2. Runtime module distribution

| Module | Files | Baris | Audit relevance |
|---|---:|---:|---|
| `features/pengajuan` | 18 | 8.700 | Hotspot terbesar: five-step forms, developer detail, Admin detail/review, revision |
| `features/monitoring` | 18 | 4.592 | Hotspot kedua: field shell, list, three-step form, preview/BA/success |
| `core` | 16 | 1.265 | Router, role policy, theme, shared widgets |
| `features/dashboard` | 8 | 1.514 | Developer/Admin home and shell composition |
| `features/profil` | 2 | 586 | Developer/Admin/Perwaskim profile surfaces |
| `features/notifikasi` | 3 | 474 | Cross-role notification list and target routing |
| `features/auth` | 2 | 402 | Splash/login |
| `features/onboarding` | 1 | 94 | Startup entry |
| `lib/` root | 2 | 35 | `main.dart`, `app.dart` |

### Runtime file-kind distribution

| Kind | Files | Baris |
|---|---:|---:|
| Screens | 26 | 10.603 |
| Feature widgets | 17 | 3.575 |
| Providers/controllers | 7 | 1.878 |
| Core non-widget files | 8 | 688 |
| Models | 6 | 577 |
| Utilities | 3 | 212 |
| Repositories | 1 | 94 |
| Root files | 2 | 35 |

### Largest files (likely review hotspots)

1. `lib/features/pengajuan/presentation/screens/pengajuan_admin_detail_screen.dart` — 2.097 lines
2. `lib/features/pengajuan/presentation/screens/pengajuan_detail_screen.dart` — 943 lines
3. `lib/features/pengajuan/presentation/widgets/hasil_survey_tab.dart` — 902 lines
4. `lib/features/pengajuan/presentation/providers/pengajuan_verifikasi_controller.dart` — 796 lines
5. `lib/features/monitoring/presentation/screens/laporan_preview_screen.dart` — 692 lines
6. `lib/features/monitoring/presentation/screens/tambah_monitoring_stepper_screen.dart` — 687 lines
7. `lib/features/pengajuan/presentation/screens/pengajuan_step4_screen.dart` — 613 lines
8. `lib/features/pengajuan/presentation/screens/pengajuan_step3_screen.dart` — 610 lines
9. `lib/features/monitoring/presentation/widgets/tab_beranda_monitoring.dart` — 559 lines
10. `lib/features/monitoring/presentation/providers/monitoring_form_provider.dart` — 480 lines

These are not findings by themselves; they are the first files to inspect during the full audit because they concentrate visual and interaction decisions.

## 3. Role, screen, and navigation inventory

The role vocabulary is defined in `lib/core/auth/role_session.dart:6-47`; route access is centralized in `lib/core/router/route_policy.dart:12-36`; route registration is in `lib/core/router/app_router.dart:63-216`.

There are 25 registered route literals, including `/` and 24 user-facing/protected routes.

| Role / state | Active shell | Main visible screens and flows | Entry route |
|---|---|---|---|
| Guest / anonymous | Startup flow | Splash → onboarding → login; contact-admin dialog; unavailable password recovery | `/splash`, `/onboarding`, `/login` |
| Developer / fallback username | `DashboardScreen` | Beranda, Pengajuan Saya, Notifikasi, Profil; pengajuan Step 1–5; success; detail/revision; BA/SK visibility | `/dashboard` |
| Admin DPKP | `AdminMainScreen` | Beranda, Pengajuan, Monitoring, Notifikasi, Profil; Admin list/detail; document verification; correction; schedule; BA/evaluation; SK/final approval | `/admin` |
| Admin monitoring view | Same Admin shell at tab index 2 | Monitoring history/list and report preview; creation route is role-guarded | `/monitoring` |
| Tim Perwaskim | `MonitoringMainScreen` | Beranda, Riwayat, Profil; assigned survey; monitoring Step 1–3; draft preview; final BA/report; success; notifications | `/monitoring/lapangan` |

### Route/shell duplication signal

- Active shells use `BottomNavigationBar` in `dashboard_screen.dart`, `admin_main_screen.dart`, and `monitoring_main_screen.dart`.
- `developer_main_screen.dart` also contains a separate five-tab developer shell but is **not registered in the router**. `docs/product_flow_stages_1_5.md` explicitly records this as an orphan/legacy surface.
- The active Developer shell has four tabs, while the orphan `DeveloperMainScreen` has five tabs including Monitoring. This is a likely consistency/deprecation decision for the eventual audit, not an implementation instruction yet.

### Design reference coverage

Local visual references exist for multiple roles:

- Developer/login/onboarding/five-step flow: `docs/design/mobile_application_mockup/` (14 subdirectories, 12 HTML mockups, 13 images).
- Admin reference screens: `docs/design/sisi_admin/` (8 image files).
- Tim Monitoring reference screens: `docs/design/tim_monitoring/` (7 image files).
- Monitoring/BA references: `docs/design/monitoring_evaluasi_perumahan/` (2 image files).
- Token/style source of truth candidate: `docs/design/mobile_application_mockup/rustic_authority/DESIGN.md`.

## 4. UI/design-system footprint signals

These are static indicators for the later UI/UX audit.

### Theme and typography

- Global theme is only `AppTheme.lightTheme` (`lib/core/theme/app_theme.dart`); no dark theme or explicit adaptive theme variant was found.
- Brand colors and neutral palette are centralized in `lib/core/theme/app_colors.dart`.
- A 15-level-ish `AppTextStyles` scale is centralized in `lib/core/theme/app_text_styles.dart`, with `fontFamily: 'Inter'`.
- `pubspec.yaml` has no active `assets:` or `fonts:` declaration; `Inter` is not bundled in the Flutter asset configuration. Several screens also use raw `TextStyle` and one `monospace` style.
- Static counts in `lib/`: 35 files use raw `TextStyle(`, 31 files reference `AppTextStyles`, 14 unique hard-coded font sizes (9–32 px), and 64 unique `Color(0x...)` literals.

### Shape, spacing, and color proliferation

- 34 files use `BorderRadius.circular`; observed radius values are 2, 4, 6, 8, 10, 12, 14, 16, 20, and 24 px.
- 40 files use `EdgeInsets` spacing; common values include 8, 10, 12, 14, 16, 20, and 24 px, with many inline variants.
- The most repeated raw colors include `#B91C1C`, `#F9EAE8`, `#2E7D32`, and several screen-local creams/greens in addition to `AppColors`.
- The design reference specifies an 8 px rhythm, 20 px mobile margin, 12/16 px component radii, and named semantic colors; current code should be compared against that reference rather than assumed compliant.

### Shared component footprint

| Shared component | Definition | Approx. callsites | Notes |
|---|---|---:|---|
| `AppButton` | `lib/core/widgets/app_button.dart` | 16 | Used heavily in onboarding, login, and pengajuan; many other screens still construct raw buttons |
| `AppTextField` | `lib/core/widgets/app_text_field.dart` | 6 | Mainly login and pengajuan Step 1; other forms use raw fields |
| `DocUploadTile` | `lib/core/widgets/doc_upload_tile.dart` | 17 | Cross-screen document upload/revision surface |
| `StatusBadge` | `lib/core/widgets/status_badge.dart` | 7 | Developer/list/detail status; monitoring has a separate evaluation badge |
| `StepperHeader` | `lib/core/widgets/stepper_header.dart` | 7 | Five-step pengajuan flow; monitoring has a separate inline stepper |
| `RouteUnavailableScreen` / `RouteNotice` | `lib/core/widgets/route_feedback.dart` | 4+ | Shared route/dead-end feedback |

Static UI constructor counts include approximately 46 `ElevatedButton`, 34 `OutlinedButton`, 24 `TextButton`, 13 `IconButton`, 2 `FloatingActionButton`, 59 `Card`, and 150 `Container` occurrences/lines. These counts indicate substantial opportunity for component convergence, but require visual/context review before proposing merges.

### Navigation, iconography, and emoji signals

- All functional icons found in `lib/` use Material `Icons`; `cupertino_icons` is declared but no `CupertinoIcons` import was found.
- 40 files reference Material icons, with 247 icon constructor occurrences in the static scan. Icon variants are not fully uniform: `home`/`home_outlined`, `notifications`/`notifications_none_outlined`/`notifications_outlined`, `assignment`/`description`/`list_alt`, and rounded/non-rounded variants coexist.
- Emoji appear in functional or notification-facing copy: `📍`, `📝`, `🔓`, `✅`, `👋`, and `🔔`. The later audit should distinguish expressive copy from emoji used as a functional/icon substitute.

### States and accessibility/adaptive signals

- Loading indicators are sparse (3 `CircularProgressIndicator` lines and 4 `LinearProgressIndicator` lines); the local data flow is mostly synchronous.
- Empty/error/unavailable states are explicitly implemented in several lists/routes, but the later audit should compare wording, illustration/icon, CTA, and retry affordance across roles.
- No `RefreshIndicator`, `Semantics`, `semanticLabel`, `MergeSemantics`, or `ExcludeSemantics` usage was found in `lib/`; only a small number of `Tooltip` callsites exist.
- Scroll/adaptive primitives (`SingleChildScrollView`, `ListView`, `GridView`, `Flexible`, `Expanded`, `SafeArea`, and a few `MediaQuery` calls) are present, but no `LayoutBuilder`/`OrientationBuilder` usage was found. One 320 px overflow test exists for a developer detail surface.
- There are no `integration_test/`, `test_driver/`, `golden_test/`, or `goldens/` directories. Visual consistency will need manual/device or newly scoped visual verification later.

## 5. Dependency and integration context

`pubspec.yaml` declares Flutter/Riverpod/GoRouter, file and image selection, PDF/printing, sharing, networking, storage, and code-generation dependencies.

Direct imports found in `lib/`/`test/` include `flutter_riverpod`, `go_router`, `file_picker`, `intl`, `share_plus`, `pdf`, and `printing`. No direct imports were found for `dio`, `flutter_secure_storage`, `shared_preferences`, `flutter_dotenv`, `image_picker`, `url_launcher`, `cupertino_icons`, `freezed_annotation`, `json_annotation`, or `riverpod_annotation` in the inspected source. Treat those as declared/planned dependencies, not evidence of a live API or persistence surface.

The `backend/` directory contains Laravel-style controllers/models/routes but no `backend/composer.json` was found. Project docs state that API persistence, production authentication, and remote notification delivery are not verified. Backend files should be used for role/state vocabulary only during UI audit unless a separate backend audit is requested.

## 6. Tests and behavioral evidence

The 13 test files cover role/session redirects, splash lifecycle, developer empty state, notification target rewriting, five-step validation and duplicate IDs, Admin guards/revision/BA handling, monitoring finalization/idempotency, repository/model behavior, dynamic bullet input, and photo-picker cancellation/races.

There is meaningful behavioral coverage for the Stage 1–5 flow contract (`docs/product_flow_stages_1_5.md`), but no dedicated screenshot/golden/integration suite. The later UI audit should not treat passing behavioral tests as proof of visual consistency or accessibility.

## 7. Graph/navigation evidence and freshness

`graphify-out/GRAPH_REPORT.md` reports:

- 299-file corpus and approximately 646.638 words
- 2.828 nodes, 3.423 edges, 223 communities
- graph built from commit `5f699880`

Current HEAD is `12ab98a`; two commits (`aa068bb` and `12ab98a`) are newer than the graph. The `graphify` CLI was not available on PATH during this scan, and the graph was not rebuilt because rebuilding would modify derived graph artifacts. Use the report only as stale navigation context; revalidate all source references against current files before relying on it.

## 8. Recommended audit corpus for Sol/Luna

### Include

1. `lib/` in full, especially all 26 screens, 17 widgets, and `core/theme`, `core/widgets`, `core/router`.
2. Relevant role/design references under `docs/design/` and `docs/design/mobile_application_mockup/rustic_authority/DESIGN.md`.
3. `docs/product_flow_stages_1_5.md`, `agent_docs/project_overview.md`, and `agent_docs/project_structure.md` for behavior/role vocabulary.
4. `test/` as evidence of supported interactions and known edge cases.
5. `backend/` only for intended role/state/API context, clearly labeled unverified.

### Exclude by default

`build/`, `.dart_tool/`, `.git/`, `graphify-out/` except the stale report, `.agents/`, `.codex/`, `.scratch/`, `outputs/`, `spreadsheet_work/`, `tmp/`, and native template files unless a platform-specific UI issue is found.

### Suggested model split

- **Sol lead:** establish audit rubric, reconcile role differences, prioritize P0–P3, synthesize the consistency matrix, unified tokens, component inventory, icon migration plan, `DESIGN.md` proposal, and phased migration plan.
- **Luna Max specialist passes (read-only):** inspect role shells/screens, shared UI/theme, interaction/state/accessibility, and icon/emoji usage separately, each returning file-backed evidence.
- **Final Sol pass:** deduplicate findings, separate evidence from recommendations, and ensure every finding has severity, affected role/screen, file reference, rationale, and recommended direction.

No implementation should begin until the audit is approved.

## 9. Caveats and workspace state

- `docs/CODEX-NAVIGATION-GUIDE.md` referenced by higher-level workspace instructions is absent in this checkout.
- `flutter` and `dart` executables were not available on PATH, so this scan did not run tests, analyzer, or device rendering.
- Git working tree was already dirty/untracked in workspace/tooling directories: `.agents`, `.codex`, `.scratch`, `outputs`, `spreadsheet_work`, and `tmp`. These were preserved.
- No source/config/dependency/build file was modified or deleted during the scan. This file is the only requested artifact created by this task.

## Primary evidence paths

- Role/session: `lib/core/auth/role_session.dart`
- Router/policy: `lib/core/router/app_router.dart`, `lib/core/router/route_policy.dart`
- Theme: `lib/core/theme/app_colors.dart`, `lib/core/theme/app_text_styles.dart`, `lib/core/theme/app_theme.dart`
- Shared widgets: `lib/core/widgets/`
- Developer shell: `lib/features/dashboard/presentation/screens/dashboard_screen.dart`
- Legacy/orphan developer shell: `lib/features/dashboard/presentation/screens/developer_main_screen.dart`
- Admin shell/home: `lib/features/dashboard/presentation/screens/admin_main_screen.dart`, `tab_beranda_admin.dart`
- Perwaskim shell/home/profile: `lib/features/monitoring/presentation/screens/monitoring_main_screen.dart`, `lib/features/monitoring/presentation/widgets/tab_beranda_monitoring.dart`, `tab_profil_monitoring.dart`
- Pengajuan screens/widgets: `lib/features/pengajuan/presentation/`
- Monitoring screens/widgets: `lib/features/monitoring/presentation/`
- Design tokens/reference: `docs/design/mobile_application_mockup/rustic_authority/DESIGN.md`
- Behavioral contract: `docs/product_flow_stages_1_5.md`
- Project context: `agent_docs/project_overview.md`, `agent_docs/project_structure.md`
- Stale graph context: `graphify-out/GRAPH_REPORT.md`
