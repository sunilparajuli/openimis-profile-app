import 'package:openimis_web_app/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OpenimisOnboardingPage extends StatelessWidget {
	static final String path = "lib/src/ui/onboarding/onboarding_card.dart";
	final pages = [
		PageViewModel(
			pageColor: Color(0xF6F6F7FF),
			bubbleBackgroundColor: CustomTheme.lightTheme.primaryColor, //Colors.indigo,
			title: Container(),
			body: Column(
				children: <Widget>[
					Text(
						'Welcome to HIB',
						style: TextStyle(
							color: Colors.grey,
						),
					),
					Text(
						'Your Health is Our Concern',
						style: TextStyle(
							color: Colors.black54,
							fontSize: 16.0
						),
					),
				],
			),
			mainImage: Image.asset(
				env.ONBOARDING_SCREEN_1,
				width: 285.0,
				alignment: Alignment.center,
			),
			textStyle: TextStyle(color: Colors.black),
		),
		PageViewModel(
			pageColor: Color(0xF6F6F7FF),
			iconColor: null,
			bubbleBackgroundColor: CustomTheme.lightTheme.primaryColor, //Colors.indigo,
			title: Container(),
			body: Column(
				children: <Widget>[
					Text(
						'Your Information is in your hand',
						style: TextStyle(
							color: Colors.grey,
						),
					),
					Text(
						'Digitizing health Information',
						style: TextStyle(
							color: Colors.black54,
							fontSize: 16.0
						),
					),
				],
			),
			mainImage: Image.asset(
				env.ONBOARDING_SCREEN_2,
				width: 285.0,
				alignment: Alignment.center,
			),
			textStyle: TextStyle(color: Colors.black),
		),
		PageViewModel(
			pageColor: Color(0xF6F6F7FF),
			iconColor: null,
			bubbleBackgroundColor: CustomTheme.lightTheme.primaryColor,//Colors.indigo,
			title: Container(),
			body: Column(
				children: <Widget>[
					Text(
						'Health Insurance For Universal Health Coverage',
						style: TextStyle(
							color: Colors.grey,
						),
					),
//					Text(
//						'Health Insurance For Universal Health Coverage',
//						style: TextStyle(
//							color: Colors.black54,
//							fontSize: 16.0
//						),
//					),
				],
			),
			mainImage: Image.asset(
				env.ONBOARDING_SCREEN_3,
				width: 285.0,
				alignment: Alignment.center,
			),
			textStyle: TextStyle(color: Colors.black),
		),
	];
	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: SafeArea(
				child: Stack(
					children: <Widget>[
						IntroViewsFlutter(
							pages,
							onTapDoneButton: () async{
								SharedPreferences prefs = await SharedPreferences.getInstance();
								await prefs.setBool('seen', true);
								Navigator.of(context).pushNamedAndRemoveUntil('/insuree_verify',(Route<dynamic> route) => false);
							},
							showSkipButton: false,
							doneText: Text("Get Started",),
							pageButtonsColor: CustomTheme.lightTheme.primaryColor,//Colors.indigo,
							pageButtonTextStyles: new TextStyle(
								// color: Colors.indigo,
								fontSize: 16.0,
								fontFamily: "Regular",
							),
						),
//						Positioned(
//							top: 20.0,
//							left: MediaQuery.of(context).size.width/2 - 50,
//							child: Image.asset(env.LOGO_URL, width: 100, height: 100,)
//						)
					],
				),
			),
		);
	}
}