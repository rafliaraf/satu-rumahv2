import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class DynamicBulletField extends StatefulWidget {
  final String label;
  final List<String> items;
  final ValueChanged<List<String>> onItemsChanged;
  final String placeholderText;

  const DynamicBulletField({
    super.key,
    required this.label,
    required this.items,
    required this.onItemsChanged,
    this.placeholderText = 'Masukkan poin...',
  });

  @override
  State<DynamicBulletField> createState() => _DynamicBulletFieldState();
}

class _DynamicBulletFieldState extends State<DynamicBulletField> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final list = widget.items.isEmpty ? [''] : widget.items;
    _controllers = list.map((item) => TextEditingController(text: item)).toList();
  }

  @override
  void didUpdateWidget(covariant DynamicBulletField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final list = widget.items.isEmpty ? [''] : widget.items;
    if (list.length != _controllers.length) {
      for (var c in _controllers) {
        c.dispose();
      }
      _controllers = list.map((item) => TextEditingController(text: item)).toList();
    } else {
      for (int i = 0; i < list.length; i++) {
        if (_controllers[i].text != list[i]) {
          _controllers[i].text = list[i];
        }
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _notifyParent() {
    widget.onItemsChanged(_controllers.map((c) => c.text).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.cocoaBeanRoast,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._controllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('• ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    onChanged: (_) => _notifyParent(),
                    decoration: InputDecoration(
                      hintText: widget.placeholderText,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.grey300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.grey300),
                      ),
                    ),
                  ),
                ),
                if (_controllers.length > 1) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.chilliDust, size: 20),
                    onPressed: () {
                      setState(() {
                        _controllers[index].dispose();
                        _controllers.removeAt(index);
                      });
                      _notifyParent();
                    },
                  ),
                ],
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _controllers.add(TextEditingController());
              });
              _notifyParent();
            },
            icon: const Icon(Icons.add, size: 18, color: AppColors.chilliDust),
            label: const Text(
              '+ Tambah Poin',
              style: TextStyle(color: AppColors.chilliDust, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
