import 'package:flutter/material.dart';
import 'colors.dart';

class CustomTheme {
	static bool _isDark = false;

	static void setTheme(bool isDark) {
		_isDark = isDark;
	}

	static ThemeData get lightTheme {
		return _isDark ? darkTheme : _lightThemeInternal;
	}

	static ThemeData get _lightThemeInternal {
		return ThemeData(
			brightness: Brightness.light,
			// --- Core Branding Colors ---
			primaryColor: CustomColors.BrandPurple,
			splashColor: CustomColors.BrandGreen.withValues(alpha: 0.2), // Smooth branding splash feedback
			scaffoldBackgroundColor: CustomColors.GreyBackground,
			fontFamily: 'Montserrat',

			// --- Component Themes ---
			appBarTheme: const AppBarTheme(
				elevation: 0.0,
				backgroundColor: CustomColors.BrandPurple,
				foregroundColor: Colors.white,
			),

			bottomNavigationBarTheme: const BottomNavigationBarThemeData(
				backgroundColor: CustomColors.NavRed,
				selectedItemColor: Colors.white,
				unselectedItemColor: Colors.white70,
				type: BottomNavigationBarType.fixed,
			),

			dialogTheme: DialogThemeData(
				backgroundColor: Colors.white, // Standard clean background for dialogues
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(18.0),
				),
				titleTextStyle: const TextStyle(
					fontSize: 18.0,
					color: CustomColors.BrandPurple,
					fontWeight: FontWeight.bold,
				),
			),

			buttonTheme: ButtonThemeData(
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(18.0),
				),
				buttonColor: CustomColors.BrandPurple, // Buttons fallback to purple branding
				colorScheme: const ColorScheme.light(),
			),

			iconTheme: const IconThemeData(
				color: Colors.black,
			),

			primaryIconTheme: const IconThemeData(
				color: Colors.white,
			),

			hintColor: CustomColors.BrandPurple,
			highlightColor: CustomColors.BrandPurple,
			hoverColor: const Color(0xff4285F4),
			focusColor: const Color(0xffA8DAB5),
			disabledColor: Colors.grey,
			cardColor: Colors.white,
			canvasColor: Colors.grey[50],

			// --- Modern Color Scheme ---
			colorScheme: ColorScheme.fromSwatch(
				brightness: Brightness.light,
			).copyWith(
				primary: CustomColors.BrandPurple,
				secondary: CustomColors.BrandGreen,
				surface: Colors.white,
			),

			textSelectionTheme: const TextSelectionThemeData(
				selectionColor: Colors.black,
			),
		);
	}

	static ThemeData get darkTheme {
		return ThemeData(
			brightness: Brightness.dark,
			// --- Core Branding Colors ---
			primaryColor: Colors.black,
			splashColor: CustomColors.BrandGreen.withValues(alpha: 0.2),
			scaffoldBackgroundColor: Colors.black,
			fontFamily: 'Montserrat',

			// --- Component Themes ---
			appBarTheme: const AppBarTheme(
				elevation: 0.0,
				backgroundColor: Colors.black,
				foregroundColor: Colors.white,
			),

			bottomNavigationBarTheme: const BottomNavigationBarThemeData(
				backgroundColor: CustomColors.NavRed,
				selectedItemColor: Colors.white,
				unselectedItemColor: Colors.white70,
				type: BottomNavigationBarType.fixed,
			),

			dialogTheme: DialogThemeData(
				backgroundColor: const Color(0xFF151515),
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(18.0),
				),
				titleTextStyle: const TextStyle(
					fontSize: 18.0,
					color: Colors.white,
					fontWeight: FontWeight.bold,
				),
			),

			buttonTheme: ButtonThemeData(
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(18.0),
				),
				buttonColor: Colors.black,
				colorScheme: const ColorScheme.dark(),
			),

			iconTheme: const IconThemeData(
				color: Colors.white,
			),

			primaryIconTheme: const IconThemeData(
				color: Colors.black,
			),

			hintColor: Colors.black,
			highlightColor: const Color(0xff372901),
			hoverColor: const Color(0xff3A3A3B),
			focusColor: const Color(0xff0B2512),
			disabledColor: Colors.grey,
			cardColor: const Color(0xFF151515),
			canvasColor: Colors.black,

			// --- Modern Color Scheme ---
			colorScheme: ColorScheme.fromSwatch(
				brightness: Brightness.dark,
			).copyWith(
				primary: Colors.black,
				secondary: Colors.black,
				surface: const Color(0xFF151515),
			),

			textSelectionTheme: const TextSelectionThemeData(
				selectionColor: Colors.white,
			),
		);
	}
}