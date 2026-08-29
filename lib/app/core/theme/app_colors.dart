// lib/app/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // ================================================================
  // 🔥 CORES DA MARCA (AZUL PROFISSIONAL - QUI MANDA)
  // ================================================================
  static const Color primary = Color(0xFF2563EB);      // Azul principal
  static const Color primaryDark = Color(0xFF1D4ED8);   // Azul escuro
  static const Color primaryLight = Color(0xFF60A5FA);  // Azul claro
  static const Color primaryBackground = Color(0xFFEFF6FF); // Fundo azul suave
  static const Color primarySurface = Color(0xFFDBEAFE);    // Superfície azul
  static const Color primaryOrangeBackground = Color(0xFFEFF6FF); // 🔥 Fundo azul suave

  // ================================================================
  // 🔥 CORES DO CHAT (AZUL DA MARCA)
  // ================================================================
  static const Color chatPrimary = Color(0xFF2563EB);      // Azul principal da marca
  static const Color chatLight = Color(0xFF60A5FA);         // Azul claro
  static const Color chatDark = Color(0xFF1D4ED8);          // Azul escuro
  static const Color chatPastel = Color(0xFFDBEAFE);        // Azul pastel
  static const Color chatBackground = Color(0xFFF8FAFC);    // Fundo cinza claríssimo

  // ================================================================
  // 🔥 CORES NEUTRAS
  // ================================================================
  static const Color background = Color(0xFFF8FAFC);     // Fundo cinza claro
  static const Color surface = Color(0xFFF1F5F9);        // Superfície cinza
  static const Color card = Color(0xFFFFFFFF);           // Cards brancos

  // ================================================================
  // 🔥 CORES DE TEXTO
  // ================================================================
  static const Color textPrimary = Color(0xFF1E293B);    // Texto principal (escuro)
  static const Color textSecondary = Color(0xFF64748B);  // Texto secundário (cinza)
  static const Color textHint = Color(0xFF94A3B8);       // Texto de dica (cinza claro)
  static const Color textDisabled = Color(0xFFCBD5E1);   // Texto desabilitado

  // ================================================================
  // 🔥 CORES DE BORDA E DIVISORES
  // ================================================================
  static const Color border = Color(0xFFE2E8F0);         // Borda padrão
  static const Color divider = Color(0xFFF1F5F9);        // Divisor

  // ================================================================
  // 🔥 CORES DE ESTADO
  // ================================================================
  static const Color error = Color(0xFFEF4444);          // Vermelho erro
  static const Color success = Color(0xFF10B981);        // Verde sucesso
  static const Color warning = Color(0xFFF59E0B);        // Amarelo aviso
  static const Color info = Color(0xFF3B82F6);           // Azul info

  // ================================================================
  // 🔥 CORES DE DESTAQUE
  // ================================================================
  static const Color rating = Color(0xFFF59E0B);         // Cor das estrelas (amarelo)
  static const Color verified = Color(0xFF2563EB);       // Azul verificado

  // ================================================================
  // 🔥 GRADIENTES
  // ================================================================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient drawerHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  // ================================================================
  // 🔥 SOMBRAS
  // ================================================================
  static List<BoxShadow> get defaultShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
}