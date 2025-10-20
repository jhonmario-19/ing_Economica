import 'package:flutter/material.dart';

class AppColors {
  // Colores principales inspirados en billeteras digitales modernas
  static const Color primaryColor = Color(0xFF1A1D29); // Azul oscuro profesional
  static const Color primaryLight = Color(0xFF2A2F42); // Variante más clara
  static const Color accentColor = Color(0xFF00D4AA); // Verde turquesa vibrante
  static const Color accentLight = Color(0xFF4DE0C7); // Verde turquesa claro
  
  // Colores de fondo
  static const Color backgroundColor = Color(0xFFF8FAFC); // Fondo gris muy claro
  static const Color surfaceColor = Color(0xFFFFFFFF); // Blanco puro para tarjetas
  static const Color cardBackground = Color(0xFFF1F5F9); // Gris claro para tarjetas secundarias
  
  // Colores de texto
  static const Color textPrimaryColor = Color(0xFF1E293B); // Negro suave
  static const Color textSecondaryColor = Color(0xFF64748B); // Gris medio
  static const Color textTertiaryColor = Color(0xFF94A3B8); // Gris claro
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Blanco sobre primario
  
  // Colores de estado
  static const Color successColor = Color(0xFF10B981); // Verde éxito
  static const Color successLight = Color(0xFFECFDF5); // Fondo verde claro
  static const Color errorColor = Color(0xFFEF4444); // Rojo error
  static const Color errorLight = Color(0xFFFEF2F2); // Fondo rojo claro
  static const Color warningColor = Color(0xFFF59E0B); // Amarillo warning
  static const Color warningLight = Color(0xFFFEF3C7); // Fondo amarillo claro
  static const Color infoColor = Color(0xFF3B82F6); // Azul info
  static const Color infoLight = Color(0xFFEFF6FF); // Fondo azul claro
  
  // Colores para transacciones
  static const Color incomeColor = Color(0xFF10B981); // Verde para ingresos
  static const Color expenseColor = Color(0xFFEF4444); // Rojo para gastos
  static const Color transferColor = Color(0xFF3B82F6); // Azul para transferencias
  
  // Colores adicionales para UI
  static const Color dividerColor = Color(0xFFE2E8F0);
  static const Color shadowColor = Color(0x1A000000);
  static const Color overlayColor = Color(0x80000000);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, primaryLight],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentColor, accentLight],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successColor, Color(0xFF059669)],
  );
  
  // Métodos helper para obtener colores con opacidad
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  static Color getPrimaryWithOpacity(double opacity) {
    return primaryColor.withOpacity(opacity);
  }
  
  static Color getAccentWithOpacity(double opacity) {
    return accentColor.withOpacity(opacity);
  }
}