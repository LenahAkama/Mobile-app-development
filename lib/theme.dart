// lib/theme.dart

import 'package:flutter/material.dart';

const kPrimary = Color(0xFF0A1628);
const kAccent = Color(0xFF00D4AA);
const kAccentLight = Color(0xFF00FFD1);
const kSurface = Color(0xFF122040);
const kCard = Color(0xFF1A2E4A);
const kTextPrimary = Color(0xFFE8F0FE);
const kTextSecondary = Color(0xFF8FA8C8);
const kError = Color(0xFFFF6B6B);
const kSuccess = Color(0xFF00D4AA);
const kWarning = Color(0xFFFFB347);

const List<String> kCategories = [
  'Technology',
  'Business',
  'Design',
  'Education',
  'Health',
  'Arts',
  'Sports',
  'Networking',
  'Other',
];

// Shared widget used across screens
class CategoryBadge extends StatelessWidget {
  final String label;
  const CategoryBadge({super.key, required this.label});

  static const _colors = {
    'Technology': Color(0xFF7B61FF),
    'Business': Color(0xFFFFB347),
    'Design': Color(0xFFFF6B6B),
    'Education': Color(0xFF4FC3F7),
    'Health': Color(0xFF81C784),
    'Arts': Color(0xFFE91E63),
    'Sports': Color(0xFFFF9800),
    'Networking': Color(0xFF00D4AA),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[label] ?? kAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: kPrimary,
    colorScheme: const ColorScheme.dark(
      primary: kAccent,
      secondary: kAccentLight,
      surface: kSurface,
      error: kError,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: kPrimary,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: kTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: kTextPrimary),
    ),
    cardTheme: CardThemeData(
      color: kCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2A4060)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2A4060)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kAccent, width: 1.5),
      ),
      labelStyle: const TextStyle(color: kTextSecondary),
      hintStyle: const TextStyle(color: kTextSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAccent,
        foregroundColor: kPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: kAccent),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kSurface,
      selectedItemColor: kAccent,
      unselectedItemColor: kTextSecondary,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
    ),
  );
}
