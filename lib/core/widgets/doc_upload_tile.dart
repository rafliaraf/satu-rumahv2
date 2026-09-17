import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class DocUploadTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? fileName;
  final VoidCallback onUpload;
  final VoidCallback? onDelete;
  final bool isRequired;

  const DocUploadTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.fileName,
    required this.onUpload,
    this.onDelete,
    this.isRequired = true,
  });

  String _getFileMeta(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        final stat = file.statSync();
        final sizeBytes = stat.size;
        final sizeStr = sizeBytes >= 1024 * 1024
            ? '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB'
            : '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
        final dateStr = DateFormat('d MMM yyyy, HH:mm').format(stat.modified);
        return '$sizeStr · Diunggah $dateStr';
      }
    } catch (_) {}
    return 'Diunggah ${DateFormat('d MMM yyyy').format(DateTime.now())}';
  }

  @override
  Widget build(BuildContext context) {
    final isUploaded = fileName != null && fileName!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded ? AppColors.pistachioCream : AppColors.grey300,
          width: isUploaded ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 4),
                      const Text('*', style: TextStyle(color: AppColors.error)),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600)),
                if (isUploaded) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.description, size: 16, color: AppColors.cocoaBeanRoast),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                fileName!.split(RegExp(r'[/\\]')).last,
                                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.cocoaBeanRoast),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (onDelete != null) ...[
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: onDelete,
                                behavior: HitTestBehavior.opaque,
                                child: const Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child: Icon(Icons.close, size: 18, color: AppColors.error),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getFileMeta(fileName!),
                          style: const TextStyle(fontSize: 10, color: AppColors.grey600),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (!isUploaded)
            ElevatedButton(
              onPressed: onUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.champagneToast,
                foregroundColor: AppColors.cocoaBeanRoast,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Unggah'),
            )
          else
            const Icon(Icons.check_circle, color: AppColors.pistachioCream, size: 28),
        ],
      ),
    );
  }
}
