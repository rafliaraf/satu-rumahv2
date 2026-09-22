import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Sepasang tombol toggle verifikasi dokumen ("Sesuai" / "Tidak Sesuai").
///
/// Menggunakan [Wrap] sehingga tombol otomatis turun baris pada layar
/// sempit dan tidak pernah menyebabkan RenderFlex horizontal overflow.
///
/// [isVerified] — null = belum diputuskan, true = Sesuai, false = Tidak Sesuai.
/// [onVerified] — dipanggil saat user memilih "Sesuai".
/// [onRejected] — dipanggil saat user memilih "Tidak Sesuai".
class VerificationRadioGroup extends StatelessWidget {
  final bool? isVerified;
  final VoidCallback onVerified;
  final VoidCallback onRejected;

  const VerificationRadioGroup({
    super.key,
    required this.isVerified,
    required this.onVerified,
    required this.onRejected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _VerificationChip(
          label: 'Sesuai',
          selected: isVerified == true,
          selectedColor: AppColors.statusSuccess,
          selectedBackground: AppColors.surfaceSuccess,
          selectedIcon: Icons.check_circle,
          onTap: onVerified,
        ),
        _VerificationChip(
          label: 'Tidak Sesuai',
          selected: isVerified == false,
          selectedColor: AppColors.chilliDust,
          selectedBackground: AppColors.surfaceAttention,
          selectedIcon: Icons.cancel,
          onTap: onRejected,
        ),
      ],
    );
  }
}

class _VerificationChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedColor;
  final Color selectedBackground;
  final IconData selectedIcon;
  final VoidCallback onTap;

  const _VerificationChip({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.selectedBackground,
    required this.selectedIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? selectedBackground : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? selectedColor : AppColors.borderSubtle,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? selectedIcon : Icons.radio_button_unchecked,
              size: 14,
              color: selected ? selectedColor : AppColors.textMuted,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? selectedColor : AppColors.textMuted,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
