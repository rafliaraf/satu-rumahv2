import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/prototype_data_banner.dart';
import '../../../dashboard/presentation/widgets/admin_header_widget.dart';
import '../../data/models/status_tahap_pengajuan.dart';
import '../providers/pengajuan_form_controller.dart';

class PengajuanAdminListScreen extends ConsumerStatefulWidget {
  const PengajuanAdminListScreen({super.key});

  @override
  ConsumerState<PengajuanAdminListScreen> createState() =>
      _PengajuanAdminListScreenState();
}

class _PengajuanAdminListScreenState
    extends ConsumerState<PengajuanAdminListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  StatusTahapPengajuan? _selectedFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pengajuanList = ref.watch(pengajuanListProvider);

    final filteredList = pengajuanList.where((item) {
      final matchesQuery =
          _searchQuery.isEmpty ||
          item.namaPerumahan.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          item.namaPt.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.id.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter =
          _selectedFilter == null ||
          item.statusTahap == _selectedFilter ||
          (_selectedFilter == StatusTahapPengajuan.perluPerbaikan &&
              item.revisionSubmitted);

      return matchesQuery && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: const AdminHeaderWidget(),
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: PrototypeDataBanner(),
          ),
          // Title Section
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 8,
            ),
            child: Text(
              'Pengajuan',
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.cocoaBeanRoast,
              ),
            ),
          ),

          // Search Bar with Filter Funnel Icon
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
                      hintText: 'Cari perumahan/developer',
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: AppRadii.pill,
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.filter_list,
                    color: AppColors.cocoaBeanRoast,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips Horizontal List
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua',
                  isSelected: _selectedFilter == null,
                  onTap: () => setState(() => _selectedFilter = null),
                ),
                const SizedBox(width: 8),
                ...StatusTahapPengajuan.values.map((status) {
                  final isSelected = _selectedFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildFilterChip(
                      label: status.label,
                      isSelected: isSelected,
                      onTap: () => setState(
                        () => _selectedFilter = isSelected ? null : status,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Card List
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.folder_off_outlined,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada pengajuan ditemukan.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
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
                      final status = item.statusTahap;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.card,
                        ),
                        elevation: 0,
                        color: Colors.white,
                        child: InkWell(
                          borderRadius: AppRadii.card,
                          onTap: () {
                            context.push('/admin/pengajuan/detail/${item.id}');
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Thumbnail
                                    ClipRRect(
                                      borderRadius: AppRadii.control,
                                      child: Container(
                                        width: 68,
                                        height: 68,
                                        decoration: const BoxDecoration(
                                          color: AppColors.surfaceSubtle,
                                          borderRadius: AppRadii.control,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons
                                                  .image_not_supported_outlined,
                                              color: AppColors.textMuted,
                                              size: 22,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Foto belum ada',
                                              style: AppTextStyles.labelSmall
                                                  .copyWith(
                                                    color: AppColors.textMuted,
                                                    fontSize: 9,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.namaPerumahan,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors
                                                        .cocoaBeanRoast,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const Icon(
                                                Icons.more_horiz,
                                                color: AppColors.textMuted,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item.namaPt,
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color: AppColors.textMuted,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: status.backgroundColor,
                                                  borderRadius:
                                                      AppRadii.control,
                                                ),
                                                child: Text(
                                                  item.revisionSubmitted
                                                      ? 'Revisi Dikirim'
                                                      : status.label,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: status.color,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  item.tanggal,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.end,
                                                  style: AppTextStyles
                                                      .labelSmall
                                                      .copyWith(
                                                        color:
                                                            AppColors.textMuted,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Bottom Progress Bar
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                child: ClipRRect(
                                  borderRadius: AppRadii.small,
                                  child: LinearProgressIndicator(
                                    value: status.progressRatio,
                                    backgroundColor: AppColors.grey200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      status.color,
                                    ),
                                    minHeight: 5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Footer Text
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                'Menampilkan ${filteredList.length} dari ${pengajuanList.length} pengajuan',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.chilliDust : Colors.white,
          borderRadius: AppRadii.pill,
          border: Border.all(
            color: isSelected ? AppColors.chilliDust : AppColors.grey300,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.cocoaBeanRoast,
          ),
        ),
      ),
    );
  }
}
