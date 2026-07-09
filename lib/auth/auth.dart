import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:openimis_web_app/blocks/auth_block.dart';
import 'signin.dart';

class Auth extends StatelessWidget {
    final List<Widget> tabs = [
        SignIn(),
    ];

    @override
    Widget build(BuildContext context) {
        final authBlock = Provider.of<AuthBlock>(context);
        
        if (authBlock.isLoggedIn) {
            WidgetsBinding.instance.addPostFrameCallback((_){
                Navigator.popAndPushNamed(context, '/card');
            });
        }

        return Scaffold(
            appBar: AppBar(
                title: Text(authBlock.currentIndex == 0 ? 'Sign In' : 'Create Account'),
                backgroundColor: Color.fromRGBO(0, 153, 182, 50),
            ),
            body: tabs[authBlock.currentIndex],
        );
    }
}