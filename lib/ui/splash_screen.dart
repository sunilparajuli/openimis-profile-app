import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openimis_web_app/ui/onboarding/onboarding_card.dart';
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:provider/provider.dart';
import 'package:openimis_web_app/services/biometric_service.dart';
import 'package:openimis_web_app/helper/shared_preferences_helper.dart';

class SplashScreen extends StatefulWidget {
  static const String id = "splash-screen";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AuthBlock auth;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      auth = Provider.of<AuthBlock>(context);
      _initialized = true;
      _startTimer();
    }
  }

  void _startTimer() {
    Timer(Duration(milliseconds: 2000), () async {
      // Ensure we have the latest user state before deciding where to go
      if (auth.user.isNotEmpty || auth.isLoggedIn) {
        bool bioEnabled = await SessionManager().isBiometricEnabled();
        if (bioEnabled) {
          bool authenticated = await BiometricService().authenticate();
          if (authenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil('/card', (Route<dynamic> route) => false);
          } else {
            // Authentication failed or canceled. Show a retry option.
            _showBiometricRetryDialog();
          }
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil('/card', (Route<dynamic> route) => false);
        }
      } else {
        checkFirstSeen();
      }
    });
  }

  void _showBiometricRetryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Biometric Authentication'),
        content: Text('Please authenticate to continue to your profile.'),
        actions: [
          TextButton(
            onPressed: () async {
              // Standard logout if they can't/won't authenticate
              await auth.logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              bool authenticated = await BiometricService().authenticate();
              if (authenticated) {
                Navigator.of(context).pushNamedAndRemoveUntil('/card', (Route<dynamic> route) => false);
              } else {
                _showBiometricRetryDialog();
              }
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
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
