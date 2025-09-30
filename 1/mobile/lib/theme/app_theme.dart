import 'package:flutter/material.dart';

// Paleta de cores moderna - Design System
class AppColors {
  // Cores primárias - Tons de azul moderno
  static const Color primary = Color(0xFF2563EB); // Azul vibrante
  static const Color primaryVariant = Color(0xFF1D4ED8); // Azul mais escuro
  static const Color primaryLight = Color(0xFF60A5FA); // Azul claro
  
  // Cores secundárias - Tons de roxo/índigo
  static const Color secondary = Color(0xFF7C3AED); // Roxo moderno
  static const Color secondaryVariant = Color(0xFF5B21B6); // Roxo escuro
  static const Color secondaryLight = Color(0xFFA78BFA); // Roxo claro
  
  // Cores de fundo
  static const Color background = Color(0xFFF8FAFC); // Branco acinzentado
  static const Color surface = Color(0xFFFFFFFF); // Branco puro
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Cinza muito claro
  
  // Cores de texto
  static const Color onPrimary = Color(0xFFFFFFFF); // Branco
  static const Color onSecondary = Color(0xFFFFFFFF); // Branco
  static const Color onBackground = Color(0xFF0F172A); // Preto/cinza escuro
  static const Color onSurface = Color(0xFF1E293B); // Cinza escuro
  static const Color onSurfaceVariant = Color(0xFF475569); // Cinza médio
  
  // Cores de estado
  static const Color success = Color(0xFF10B981); // Verde
  static const Color warning = Color(0xFFF59E0B); // Amarelo/laranja
  static const Color error = Color(0xFFEF4444); // Vermelho
  static const Color info = Color(0xFF3B82F6); // Azul informativo
  
  // Cores de ícones
  static const Color iconPrimary = Color(0xFF64748B); // Cinza azulado
  static const Color iconSecondary = Color(0xFF94A3B8); // Cinza claro
  static const Color iconDisabled = Color(0xFFCBD5E1); // Cinza muito claro
}

// Sistema de espaçamentos padronizado
class AppSpacing {
  static const double xs = 4.0;   // Extra pequeno
  static const double sm = 8.0;   // Pequeno
  static const double md = 16.0;  // Médio (padrão)
  static const double lg = 24.0;  // Grande
  static const double xl = 32.0;  // Extra grande
  static const double xxl = 48.0; // Extra extra grande
  
  // Espaçamentos específicos
  static const double cardPadding = md;
  static const double screenPadding = md;
  static const double listItemSpacing = sm;
  static const double buttonSpacing = md;
}

// Sistema de bordas e sombras
class AppDecoration {
  // Raios de borda
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  
  // Sombras
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 15,
      offset: const Offset(0, 6),
    ),
  ];
  
  static List<BoxShadow> get strongShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

// Tema principal do app
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Configuração da tipografia
      textTheme: const TextTheme(
        // Headlines (Títulos grandes)
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.onBackground,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.onBackground,
          letterSpacing: -0.25,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.onBackground,
        ),
        
        // Titles (Títulos médios)
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
          letterSpacing: 0.1,
        ),
        
        // Body (Texto de corpo)
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
          letterSpacing: 0.15,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 0.4,
        ),
        
        // Labels (Rótulos e botões)
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
      
      // Scheme de cores
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.onPrimary,
        
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.onSecondary,
        
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceVariant: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        
        background: AppColors.background,
        onBackground: AppColors.onBackground,
        
        error: AppColors.error,
        onError: Colors.white,
      ),
      
      // Configuração do AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onPrimary,
        ),
      ),
      
      // Configuração dos Cards
      cardTheme: CardThemeData(
        color: AppColors.surface,
        shadowColor: Colors.black.withOpacity(0.1),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecoration.radiusMedium),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      
      // Configuração dos botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecoration.radiusMedium),
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecoration.radiusMedium),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecoration.radiusSmall),
          ),
        ),
      ),
      
      // Configuração do FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
        elevation: 6,
      ),
      
      // Configuração dos campos de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecoration.radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecoration.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecoration.radiusMedium),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      
      // Configuração dos ListTiles
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        minLeadingWidth: 40,
      ),
      
      // Configuração dos Checkboxes
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(AppColors.onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // Configuração dos Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecoration.radiusLarge),
        ),
        elevation: 8,
      ),
      
      // Configuração do SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.onSurface,
        contentTextStyle: const TextStyle(color: AppColors.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecoration.radiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}