import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openimis_web_app/ui/onboarding/onboarding_card.dart';
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  static const String id = "splash-screen";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AuthBlock auth;
  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds:2000), () async {
      if(auth.isLoggedIn){
        Navigator.of(context).pushNamedAndRemoveUntil('/card',(Route<dynamic> route) => false);
      }
      else {
        checkFirstSeen();



      }


    });
  }

  Future<void> checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);
    if(_seen==false){
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return OpenimisOnboardingPage(); //PageViewScreen();
      }));
    }
    else {
      Navigator.of(context).pushNamedAndRemoveUntil('/insuree_verify',(Route<dynamic> route) => false);
    }
    }


  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthBlock>(context);
    env.setAuth(auth);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Stack(
        children: <Widget>
        [
          Positioned.fill(  //
            child: Image(
              image: AssetImage(env.SPLASH_SCREEN),
              fit : BoxFit.fill,
           ),
          ), 
         
         ]
 ),
    );

  }
}
