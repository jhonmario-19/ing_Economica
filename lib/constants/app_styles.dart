import 'package:flutter/material.dart';
import 'package:billetera/constants/app_colors.dart';

class AppStyles {
  // ===== ESTILOS DE TEXTO =====
  
  // Títulos principales
  static TextStyle get headingLarge => const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryColor,
        height: 1.2,
        letterSpacing: -0.5,
      );
  
  static TextStyle get headingMedium => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryColor,
        height: 1.3,
        letterSpacing: -0.3,
      );

  static TextStyle get headingSmall => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryColor,
        height: 1.4,
      );

  // Subtítulos
  static TextStyle get subheadingLarge => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryColor,
        height: 1.4,
      );
      
  static TextStyle get subheadingMedium => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryColor,
        height: 1.5,
      );

  static TextStyle get subheadingSmall => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiaryColor,
        height: 1.4,
      );

  // Texto de cuerpo
  static TextStyle get bodyLarge => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimaryColor,
        height: 1.6,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimaryColor,
        height: 1.5,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondaryColor,
        height: 1.4,
      );

  // Estilos especiales para balance y montos
  static TextStyle get balanceLarge => const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.textOnPrimary,
        height: 1.1,
        letterSpacing: -1.0,
      );

  static TextStyle get balanceMedium => const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get balanceSmall => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
        height: 1.3,
      );

  // Estilos para botones
  static TextStyle get buttonLarge => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  static TextStyle get buttonMedium => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.2,
      );

  static TextStyle get buttonSmall => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.2,
      );

  // ===== DECORACIONES DE CONTENEDORES =====
  
  // Tarjeta principal moderna
  static BoxDecoration get primaryCardDecoration => BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      );

  // Tarjeta de balance con gradiente
  static BoxDecoration get balanceCardDecoration => BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      );

  // Tarjeta simple sin sombra fuerte
  static BoxDecoration get simpleCardDecoration => BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.dividerColor,
          width: 1,
        ),
      );

  // Contenedor de acción rápida
  static BoxDecoration get actionContainerDecoration => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dividerColor,
          width: 1,
        ),
      );

  // ===== ESTILOS DE ENTRADA (INPUT) =====
  
  static InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon, 
        color: AppColors.textTertiaryColor,
        size: 20,
      ),
      suffixIcon: suffix,
      
      // Bordes
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.accentColor, 
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.errorColor, 
          width: 2,
        ),
      ),
      
      // Relleno y colores
      filled: true,
      fillColor: AppColors.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16, 
        horizontal: 16,
      ),
      
      // Estilos de texto
      labelStyle: const TextStyle(
        color: AppColors.textSecondaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: const TextStyle(
        color: AppColors.textTertiaryColor,
        fontSize: 14,
      ),
      errorStyle: const TextStyle(
        color: AppColors.errorColor,
        fontSize: 12,
      ),
    );
  }

  // ===== ESTILOS DE BOTONES =====
  
  // Botón principal
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        minimumSize: const Size(double.infinity, 52),
        textStyle: buttonLarge,
      );

  // Botón secundario
  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimaryColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.dividerColor),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        minimumSize: const Size(double.infinity, 52),
        textStyle: buttonLarge,
      );

  // Botón de acento
  static ButtonStyle get accentButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentColor,
        foregroundColor: AppColors.surfaceColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        minimumSize: const Size(double.infinity, 52),
        textStyle: buttonLarge,
      );

  // Botón de texto
  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
        foregroundColor: AppColors.accentColor,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        textStyle: buttonMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );

  // Botón de éxito
  static ButtonStyle get successButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppColors.successColor,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        minimumSize: const Size(double.infinity, 52),
        textStyle: buttonLarge,
      );

  // Botón de error
  static ButtonStyle get errorButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppColors.errorColor,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        minimumSize: const Size(double.infinity, 52),
        textStyle: buttonLarge,
      );

  // ===== ESPACIADO CONSTANTE =====
  
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // ===== RADIOS DE BORDE =====
  
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;

  // ===== MÉTODOS HELPER =====
  
  // Obtener decoración con color personalizado
  static BoxDecoration getColoredCardDecoration(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radiusM),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Obtener estilo de texto con color personalizado
  static TextStyle getCustomTextStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}