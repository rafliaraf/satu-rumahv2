import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/prototype_data_banner.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/pengajuan_form_controller.dart';

class PengajuanSayaListScreen extends ConsumerStatefulWidget {
  const PengajuanSayaListScreen({super.key});

  @override
  ConsumerState<PengajuanSayaListScreen> createState() =>
      _PengajuanSayaListScreenState();
}

class _PengajuanSayaListScreenState
    extends ConsumerState<PengajuanSayaListScreen> {
  String _filterStatus = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(pengajuanListProvider);

    // Filtering and Searching
    final filteredList = list.where((item) {
      final matchesSearch =
          item.namaPerumahan.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          item.id.toLowerCase().contains(_searchQuery.toLowerCase());

      if (_filterStatus == 'Semua') return matchesSearch;
      if (_filterStatus == 'Proses')
        return matchesSearch && item.status == 'Dalam Proses';
      if (_filterStatus == 'Selesai')
        return matchesSearch && item.status == 'Selesai';
      if (_filterStatus == 'Revisi')
        return matchesSearch && item.status == 'Perlu Perbaikan';
      return matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Pengajuan Saya', style: AppTextStyles.headlineLarge),
        elevation: 0,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: PrototypeDataBanner(),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Cari nomor pengajuan atau perumahan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: ['Semua', 'Proses', 'Selesai', 'Revisi'].map((status) {
                final isSelected = _filterStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    selectedColor: AppColors.champagneToast,
                    checkmarkColor: AppColors.cocoaBeanRoast,
                    onSelected: (val) {
                      setState(() {
                        _filterStatus = status;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Submission List
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.home_work_outlined,
                          size: 64,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada pengajuan ditemukan',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredList.length,
                    padding: const EdgeInsets.all(16.0),
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () =>
                              context.push('/pengajuan/detail/${item.id}'),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.id,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    StatusBadge(status: item.status),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.namaPerumahan,
                                  style: AppTextStyles.titleLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Lahan: ${item.luasLahan} m² | ${item.jumlahUnit} Unit',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.grey600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.tanggal,
                                      style: AppTextStyles.labelSmall,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          item.status == 'Perlu Perbaikan'
                                              ? 'Perbaiki Sekarang'
                                              : 'Lihat Detail',
                                          style: AppTextStyles.labelMedium
                                              .copyWith(
                                                color: AppColors.chilliDust,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right,
                                          size: 16,
                                          color: AppColors.chilliDust,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (item.status == 'Perlu Perbaikan' &&
                                    item.catatanPerbaikan != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(
                                        alpha: 0.05,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.error.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Catatan: ${item.catatanPerbaikan}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.chilliDust,
        foregroundColor: Colors.white,
        onPressed: () {
          ref.read(pengajuanFormProvider.notifier).reset();
          context.push('/pengajuan/step1');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
