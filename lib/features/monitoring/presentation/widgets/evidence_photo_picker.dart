import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_picker_util.dart';

typedef PhotoPathPicker = Future<List<String>> Function();

class EvidencePhotoPicker extends StatefulWidget {
  final List<String> photoPaths;
  final ValueChanged<List<String>> onPhotosChanged;
  final int maxPhotos;
  final PhotoPathPicker? pickPhotoPaths;

  const EvidencePhotoPicker({
    super.key,
    required this.photoPaths,
    required this.onPhotosChanged,
    this.maxPhotos = 10,
    this.pickPhotoPaths,
  });

  @override
  State<EvidencePhotoPicker> createState() => _EvidencePhotoPickerState();
}

class _EvidencePhotoPickerState extends State<EvidencePhotoPicker> {
  int _pickRequestId = 0;

  @override
  void didUpdateWidget(covariant EvidencePhotoPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.photoPaths, widget.photoPaths)) {
      // A parent update supersedes any picker result that is still pending.
      _pickRequestId++;
    }
  }

  @override
  void dispose() {
    // Invalidate callbacks awaiting the native file picker before disposal.
    _pickRequestId++;
    super.dispose();
  }

  Future<List<String>> _pickFromDevice() async {
    final pickedFiles = await FilePickerUtil.pickMultipleFiles(
      allowedExtensions: ['jpg', 'jpeg', 'png', 'heic', 'webp'],
    );
    return pickedFiles.map((file) => file.path ?? file.name).toList();
  }

  Future<void> _pickPhotos() async {
    final requestId = ++_pickRequestId;
    final pickedPaths = await (widget.pickPhotoPaths ?? _pickFromDevice)();

    if (!mounted || requestId != _pickRequestId || pickedPaths.isEmpty) {
      // Cancellation, disposal, or an older out-of-order result must not
      // mutate the form (and cancellation must not create a fake photo).
      return;
    }

    final updated = List<String>.from(widget.photoPaths);
    for (final path in pickedPaths) {
      if (updated.length >= widget.maxPhotos) break;
      if (!updated.contains(path)) updated.add(path);
    }
    if (updated.length != widget.photoPaths.length) {
      widget.onPhotosChanged(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoPaths = widget.photoPaths;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Upload Foto Evidence ',
              style: TextStyle(
                color: AppColors.cocoaBeanRoast,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              '(Maks. ${widget.maxPhotos} foto)',
              style: const TextStyle(color: AppColors.grey600, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: (photoPaths.length < widget.maxPhotos)
              ? photoPaths.length + 1
              : photoPaths.length,
          itemBuilder: (context, index) {
            if (index == photoPaths.length &&
                photoPaths.length < widget.maxPhotos) {
              return InkWell(
                onTap: _pickPhotos,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE53935).withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        color: Color(0xFFB91C1C),
                        size: 22,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tambah\nFoto',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFB91C1C),
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final path = photoPaths[index];
            final isUrl = path.startsWith('http');

            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: isUrl
                      ? Image.network(
                          path,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => _buildImageError(),
                        )
                      : Image.asset(
                          path,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => _buildImageError(),
                        ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () {
                      _pickRequestId++;
                      final updated = List<String>.from(widget.photoPaths)
                        ..removeAt(index);
                      widget.onPhotosChanged(updated);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFB91C1C),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildImageError() {
    return Container(
      color: AppColors.grey200,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo, color: AppColors.grey600, size: 24),
            SizedBox(height: 2),
            Text(
              'Foto Evidence',
              style: TextStyle(fontSize: 9, color: AppColors.grey700),
            ),
          ],
        ),
      ),
    );
  }
}
