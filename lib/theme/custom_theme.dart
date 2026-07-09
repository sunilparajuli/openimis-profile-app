import 'package:flutter/material.dart';
import 'colors.dart';

class CustomTheme{
	static ThemeData get lightTheme {
		return ThemeData(
			primaryColor: CustomColors.LightGreen,
			splashColor: CustomColors.LightGreen1,
			backgroundColor: CustomColors.PinkLight,
			scaffoldBackgroundColor: Colors.white,
			dialogBackgroundColor: Colors.orangeAccent,
			dialogTheme: DialogTheme(
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(18.0)
				),
				titleTextStyle: TextStyle(
					fontSize: 18.0,
					decorationColor: Colors.orangeAccent
				)
			),
			fontFamily: 'Montserrat',
			buttonTheme: ButtonThemeData(
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(18.0)
				),
				buttonColor: CustomColors.BlueDark
			), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: CustomColors.LightGreen2)
		);
	}
}