import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';

ThemeData appTHeme() {
  return ThemeData(
      fontFamily: 'DINNextLTArabic',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: AppTextStyle.text20_700,
      ),
      scaffoldBackgroundColor: Colors.white,
      canvasColor: Colors.white,
      primarySwatch: Colors.blue,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.black), // Default text style
        bodyMedium: TextStyle(color: Colors.black), // For smaller text
        displayLarge: TextStyle(color: Colors.black), // Headlines
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: Colors.grey[600], // Lighter grey color for hint text
          fontSize: 16, // A standard font size for hints
        ),
        labelStyle: TextStyle(
          color: Colors.black, // Label color (for fields with label)
          fontSize: 16, // Standard font size for labels
          fontWeight: FontWeight.w500, // Medium weight for clarity
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.6), // Slightly greyish black for border
            width: 1.5, // Slightly thicker border for better visibility
          ),
          borderRadius: BorderRadius.circular(12.0), // Rounded corners for modern look
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.6), // Slightly greyish black for disabled state
            width: 1.5, // Slightly thicker border for better visibility
          ),
          borderRadius: BorderRadius.circular(12.0), // Rounded corners for modern look
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.blue, // Blue color when the field is focused
            width: 2.0, // Thicker border when focused
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red, // Red color for error state
            width: 2.0, // Slightly thicker for visibility
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red, // Red color when focused and in error state
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        // Optional: Adding `contentPadding` to adjust space inside the field
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 14), // More space for readability
      ));
}
