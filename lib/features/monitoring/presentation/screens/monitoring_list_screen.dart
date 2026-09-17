import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/prototype_data_banner.dart';
import '../../data/models/status_hasil_evaluasi.dart';
import '../providers/monitoring_list_provider.dart';

class MonitoringListScreen extends ConsumerStatefulWidget {
  final bool showBottomNav;

  const MonitoringListScreen({super.key, this.showBottomNav = true});

  @override
  ConsumerState<MonitoringListScreen> createState() =>
      _MonitoringListScreenState();
}

class _MonitoringListScreenState extends ConsumerState<MonitoringListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  final List<String> _filters = [
    'Semua',
    'Sesuai Siteplan',
    'Perlu Evaluasi',
    'Tidak Sesuai',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(monitoringListProvider);

    final filteredList = list.where((item) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesQuery =
            item.namaPerumahan.toLowerCase().contains(q) ||
            item.namaDeveloper.toLowerCase().contains(q) ||
            item.lokasiPerumahan.toLowerCase().contains(q);
        if (!matchesQuery) return false;
      }

      // Status chip filter
      if (_selectedFilter == 'Sesuai Siteplan') {
        return item.statusHasilEvaluasi == StatusHasilEvaluasi.sesuaiSiteplan;
      } else if (_selectedFilter == 'Perlu Evaluasi') {
        return item.statusHasilEvaluasi ==
            StatusHasilEvaluasi.perluEvaluasiLanjutan;
      } else if (_selectedFilter == 'Tidak Sesuai') {
        return item.statusHasilEvaluasi ==
            StatusHasilEvaluasi.tidakSesuaiSiteplan;
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/monitoring/lapangan');
              }
            },
            borderRadius: AppRadii.pill,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.grey300),
                color: Colors.white,
              ),
              child: const Icon(
                Icons.close,
                color: AppColors.cocoaBeanRoast,
                size: 18,
              ),
            ),
          ),
        ),
        title: const Text(
          'Riwayat Monitoring',
          style: TextStyle(
            color: AppColors.cocoaBeanRoast,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: PrototypeDataBanner(),
          ),
          // Search Bar + Square Filter Button Row (Mockup 4)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari perumahan / developer...',
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadii.pill,
                        borderSide: const BorderSide(color: AppColors.grey300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadii.pill,
                        borderSide: const BorderSide(color: AppColors.grey300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadii.pill,
                        borderSide: const BorderSide(
                          color: AppColors.actionPrimary,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadii.control,
                    border: Border.all(color: AppColors.grey300),
                  ),
                  child: IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Gunakan filter status di bawah untuk menyaring riwayat.',
                          ),
                        ),
                      );
                    },
                    tooltip: 'Petunjuk filter status',
                    icon: const Icon(
                      Icons.tune,
                      color: AppColors.cocoaBeanRoast,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Horizontal Scrollable Filter Chips (Mockup 4)
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (ctx, idx) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;

                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    }
                  },
                  selectedColor: AppColors.actionPrimary,
                  backgroundColor: Colors.white,
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.cocoaBeanRoast,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.actionPrimary
                        : AppColors.grey300,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: AppRadii.pill),
                  showCheckmark: false,
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Sub-header Uppercase Section Title (Mockup 4)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ARSIP LAPANGAN',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.actionPrimary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedFilter == 'Semua'
                          ? 'Semua monitoring'
                          : _selectedFilter,
                      style: AppTextStyles.headlineSmall,
                    ),
                  ],
                ),
                Text(
                  '${filteredList.length} laporan',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Cards List (Mockup 4)
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada laporan monitoring.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final dateStr = DateFormat(
                        'dd MMM yyyy',
                      ).format(item.tanggalMonitoring);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadii.card,
                          border: Border.all(color: AppColors.grey200),
                        ),
                        child: InkWell(
                          onTap: () {
                            context.push(
                              '/monitoring/preview',
                              extra: {'model': item, 'isDraft': false},
                            );
                          },
                          borderRadius: AppRadii.card,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.namaPerumahan,
                                        style: AppTextStyles.titleMedium
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward,
                                      size: 16,
                                      color: AppColors.textMuted,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.namaDeveloper.isNotEmpty
                                      ? item.namaDeveloper
                                      : 'PT. Developer Tasik',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Divider(
                                  height: 1,
                                  color: AppColors.grey200,
                                ),
                                const SizedBox(height: 12),

                                // Footer Row: Date & Status Pill Badge
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dateStr,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textMuted,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    _buildStatusBadge(item.statusHasilEvaluasi),
                                  ],
                                ),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.actionPrimary,
        elevation: 3,
        onPressed: () => context.push('/monitoring/tambah'),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Tambah Monitoring',
          style: AppTextStyles.labelLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(StatusHasilEvaluasi status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: AppRadii.control,
      ),
      child: Text(
        status.label,
        style: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.bold,
          color: status.color,
        ),
      ),
    );
  }
}
