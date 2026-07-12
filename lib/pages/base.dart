import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:openimis_web_app/pages/policy_information_page.dart';
import 'package:openimis_web_app/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:openimis_web_app/services/bottom_nav_bar_service.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:openimis_web_app/pages/settings_page.dart';
import 'package:openimis_web_app/langlang/app_translation.dart';
import 'package:openimis_web_app/langlang/application.dart';

import 'home_page.dart';

class Display extends StatefulWidget {
  final int initIndex;
  Display({Key? key, required this.initIndex}) : super(key: key);

  @override
  _DisplayState createState() => _DisplayState();
}

class _DisplayState extends State<Display> {

    @override
    initState(){
        super.initState();
        application.onLocaleChanged = onLocaleChange;
    }

    void onLocaleChange(Locale locale) async {
        setState(() {
            AppTranslations.load(locale);
        });
    }
    _getDrawerItemWidget(int index) {
        switch (index) {
            case 0:
                return new Homepage();
            case 1:
                return new PolicyInformationPage();
            case 2:
                return new SettingsPage(null);
            default:
                return new Text("Error");
        }
    }

    // List<String> titleList = ["page_title_openimis", "page_title_history", "page_title_policy_information", "page_title_settings"];

    List<String> titleList = ["page_title_openimis", "page_title_policy_information", "page_title_settings"];

    Widget build(BuildContext context) {
        final bottomNavProvider = Provider.of<BottomNavigationBarProvider>(context);
        var connectionStatus = Provider.of<ConnectivityResult>(context);
        if(connectionStatus==ConnectivityResult.none){setState(() {});}

        return Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: CustomTheme.lightTheme.primaryColor, //Color.fromRGBO(234, 239, 255, 50),
                elevation: 0.0,
                actions: <Widget>[
                    // _createLanguageDropDown()
                    IconButton(
                        icon: Icon(Icons.credit_card_rounded, color: Colors.white, size: 30,),
                        onPressed: (){
                            print('Show Card Clicked...');
                            Navigator.pushNamed(context, '/show-card');
                        }
                    )
                ],
                title: Text(
                    AppTranslations.of(context).text(titleList[bottomNavProvider.currentIndex]),
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500
                    ),
                    textAlign: TextAlign.center,
                ),
            ),
           
            body :
            // connectionStatus==ConnectivityResult.none ?
            //         Container(child: Center(child: Text(AppTranslations.of(context).text('no_internet_connection')),),)
            //     :
            _getDrawerItemWidget(bottomNavProvider.currentIndex),
            bottomNavigationBar: CurvedNavigationBar(
                color: CustomTheme.lightTheme.primaryColor,
                height: 60,
                onTap: (index) {
                    bottomNavProvider.currentIndex = index;
                },
                backgroundColor: CustomTheme.lightTheme.colorScheme.surface,
                items: <Widget>[
                    Icon(
                        Icons.home,
                        size: 30,
                        color: Colors.white,
                    ),
//                    Icon(
//                        Icons.history,
//                        size: 30,
//                        color: Colors.white,
//                    ),
                    Icon(
                        Icons.policy_rounded,
                        size: 30,
                        color: Colors.white,
                    ),
                    Icon(
                        Icons.more_vert,
                        size: 30,
                        color: Colors.white,
                    ),
                ],
            ),
        );
    }
}