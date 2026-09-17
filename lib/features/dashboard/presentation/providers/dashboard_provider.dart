import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider untuk menyimpan index tab dashboard yang sedang aktif.
/// Bisa diubah dari mana saja untuk navigasi ke tab tertentu.
final dashboardTabProvider = StateProvider<int>((ref) => 0);
