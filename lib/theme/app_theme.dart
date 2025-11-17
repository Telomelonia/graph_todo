import 'package:flutter/material.dart';

class AppTheme {
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkSurfaceLight = Color(0xFF3A3A3A);
  static const Color darkBorder = Colors.white24;
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Colors.white70;
  static const Color darkTextHint = Colors.white38;
  static const Color darkGrid = Colors.white10;

  // Light Theme Colors - Very light and minimal
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceLight = Color(0xFFF5F5F5);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightText = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF616161);
  static const Color lightTextHint = Color(0xFF9E9E9E);
  static const Color lightGrid = Color(0xFFEEEEEE);

  // Shared colors
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryRed = Color(0xFFEF4444);
  static const Color primaryOrange = Color(0xFFF97316);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryYellow = Color(0xFFF59E0B);

  // Get colors based on theme mode
  static Color getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? darkBackground : lightBackground;
  }

  static Color getSurfaceColor(bool isDarkMode) {
    return isDarkMode ? darkSurface : lightSurface;
  }

  static Color getSurfaceLightColor(bool isDarkMode) {
    return isDarkMode ? darkSurfaceLight : lightSurfaceLight;
  }

  static Color getBorderColor(bool isDarkMode) {
    return isDarkMode ? darkBorder : lightBorder;
  }

  static Color getTextColor(bool isDarkMode) {
    return isDarkMode ? darkText : lightText;
  }

  static Color getTextSecondaryColor(bool isDarkMode) {
    return isDarkMode ? darkTextSecondary : lightTextSecondary;
  }

  static Color getTextHintColor(bool isDarkMode) {
    return isDarkMode ? darkTextHint : lightTextHint;
  }

  static Color getGridColor(bool isDarkMode) {
    return isDarkMode ? darkGrid : lightGrid;
  }

  // Connection colors
  static Color getConnectionColor(bool isDarkMode, {bool isGolden = false}) {
    if (isGolden) return primaryGreen;
    return isDarkMode ? Colors.white60 : Color(0xFF757575);
  }

  static Color getConnectionDotColor(bool isDarkMode, {bool isGolden = false}) {
    if (isGolden) return primaryGreen;
    return isDarkMode ? Colors.white70 : Color(0xFF616161);
  }

  // Selection colors
  static Color getSelectionColor(bool isDarkMode) {
    return isDarkMode ? Colors.yellow : Colors.orange;
  }

  static Color getEraserColor(bool isDarkMode) {
    return primaryRed;
  }

  static Color getConnectModeColor(bool isDarkMode) {
    return isDarkMode ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.3);
  }

  // Action button colors
  static Color getActionButtonBorder(bool isDarkMode) {
    return isDarkMode ? Colors.white70 : Colors.white;
  }

  // Mode indicator colors
  static Color getModeIndicatorBackground(bool isDarkMode, {bool isError = false}) {
    if (isError) {
      return isDarkMode ? primaryRed.withValues(alpha: 0.9) : primaryRed.withValues(alpha: 0.8);
    }
    return isDarkMode ? Colors.grey.withValues(alpha: 0.9) : Colors.grey.withValues(alpha: 0.8);
  }

  // Info panel colors
  static Color getInfoPanelHeaderBackground(bool isDarkMode) {
    return isDarkMode ? Colors.black.withValues(alpha: 0.3) : Color(0xFFE3F2FD);
  }

  static Color getInfoPanelFieldBackground(bool isDarkMode) {
    return isDarkMode ? Colors.black.withValues(alpha: 0.2) : Color(0xFFF5F5F5);
  }

  // Shadow colors
  static List<BoxShadow> getNodeShadow(bool isDarkMode, double scale) {
    return [
      BoxShadow(
        color: isDarkMode
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.15),
        blurRadius: 8.0 * scale,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // Icon selector dialog
  static Color getIconSelectorBackground(bool isDarkMode) {
    return isDarkMode ? darkSurface : lightSurface;
  }

  static Color getIconSelectorHeaderBackground(bool isDarkMode) {
    return isDarkMode ? Colors.black.withValues(alpha: 0.3) : Color(0xFFE8EAF6);
  }
}
