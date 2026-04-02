import 'package:flutter/material.dart';

class AppColors {
  // Primary - Green Color Palette
  static const Color primary = Color(0xFF10B981);        // Emerald Green
  static const Color primaryLight = Color(0xFF34D399);   // Light Green
  static const Color primaryDark = Color(0xFF059669);    // Dark Green
  static const Color primaryExtraLight = Color(0xFFD1FAE5); // Extra Light Green

  // Accent - Green variations
  static const Color accent = Color(0xFF6EE7B7);         // Mint Green
  static const Color accentLight = Color(0xFFA7F3D0);    // Light Mint
  static const Color accentDark = Color(0xFF047857);     // Dark Mint

  // Semantic
  static const Color success = Color(0xFF10B981);        // Green (Success)
  static const Color warning = Color(0xFFFF9800);        // Orange
  static const Color error = Color(0xFFEF4444);          // Red
  static const Color info = Color(0xFF3B82F6);           // Blue

  // Neutrals - White & Gray
  static const Color white = Color(0xFFFFFFFF);          // Pure White
  static const Color offWhite = Color(0xFFFAFAFA);       // Off White
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Chat - Green theme
  static const Color chatBubbleSent = Color(0xFF10B981);     // Green
  static const Color chatBubbleReceived = Color(0xFFF3F4F6); // Light Gray
  static const Color chatBubbleSentDark = Color(0xFF059669); // Dark Green
  static const Color chatBubbleReceivedDark = Color(0xFF2C2C2C);

  // Match score colors
  static const Color matchScoreHigh = Color(0xFF10B981);    // Green (High Match)
  static const Color matchScoreMedium = Color(0xFFFF9800);  // Orange (Medium)
  static const Color matchScoreLow = Color(0xFFEF4444);     // Red (Low)

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color matchScoreColor(int score) {
    if (score >= 70) return matchScoreHigh;
    if (score >= 40) return matchScoreMedium;
    return matchScoreLow;
  }
}