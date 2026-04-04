import 'package:flutter/material.dart';
import 'package:gestion_cliente/core/app_colors.dart';

// Temas aplicables a las distintas ventanas de la app y a sus respectivos elementos.
class AppThemes {
  //Tema de la pantalla de inicio.

  static final inicioTheme = ThemeData(
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      actionsIconTheme: const IconThemeData(color: AppColors.secondaryColor),
     

        ),

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      surface: Colors.white,
      onPrimary: Colors.white
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF656666),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF212121), 
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondaryColor,
        side: BorderSide(color: AppColors.secondaryColor),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color:AppColors.primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryColor),
      ),
    ),
  );


  /* lo dejo comentado, de momento sin uso real hasta no tener listo el principal.


  //Tema Azul claro.
   static final azulClaroTheme = ThemeData(
    primaryColor: AppColors.primaryColor2,
    scaffoldBackgroundColor: AppColors.backgroundColor2,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundColor2,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor2,
      primary: AppColors.primaryColor2,
      secondary: AppColors.secondaryColor2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
  );

  //Tema Verde.

  static final verdeTheme = ThemeData(
    primaryColor: AppColors.primaryColor3,
    scaffoldBackgroundColor: AppColors.backgroundColor3,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundColor3,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor3,
      primary: AppColors.primaryColor3,
      secondary: AppColors.secondaryColor3,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor3,
        foregroundColor: Colors.white,
      ),
    ),
  );

  //Tema Morado/Rosa.

  static final moradoTheme = ThemeData(
    primaryColor: AppColors.primaryColor4,
    scaffoldBackgroundColor: AppColors.backgroundColor4,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundColor4,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor4,
      primary: AppColors.primaryColor4,
      secondary: AppColors.secondaryColor4,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
  );

  //Tema Rojo.

  static final rojoTheme = ThemeData(
    primaryColor: AppColors.primaryColor5,
    scaffoldBackgroundColor: AppColors.backgroundColor5,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundColor5,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor5,
      primary: AppColors.primaryColor5,
      secondary: AppColors.secondaryColor5,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor5,
        foregroundColor: Colors.white,
      ),
    ),
  );
  */
}
