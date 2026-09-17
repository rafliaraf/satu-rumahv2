import 'package:flutter/material.dart';

/// Small, deliberate radius scale for the Rustic Authority surfaces.
class AppRadii {
  static const BorderRadius tight = BorderRadius.all(Radius.circular(4));
  static const BorderRadius small = BorderRadius.all(Radius.circular(8));
  static const BorderRadius control = BorderRadius.all(Radius.circular(12));
  static const BorderRadius card = BorderRadius.all(Radius.circular(16));
  static const BorderRadius hero = BorderRadius.only(
    bottomLeft: Radius.circular(24),
    bottomRight: Radius.circular(24),
  );
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}
