import 'dart:io';

import 'package:openimis_web_app/auth/register_card.dart';
import 'package:openimis_web_app/auth/reset-password.dart';
import 'package:openimis_web_app/models/insuree.dart';
import 'package:openimis_web_app/pages/base.dart';
import 'package:openimis_web_app/pages/card_details.dart';
import 'package:openimis_web_app/pages/contactus_page.dart';
import 'package:openimis_web_app/pages/faq.dart';
import 'package:openimis_web_app/pages/feedback.dart';
import 'package:openimis_web_app/pages/healthFacilitiesMaps.dart';
import 'package:openimis_web_app/pages/service_provider_page.dart';
import 'package:openimis_web_app/pages/notice.dart';
import 'package:openimis_web_app/pages/notification.dart';
import 'package:openimis_web_app/pages/office.dart';
import 'package:openimis_web_app/pages/policy_information_page.dart';
import 'package:openimis_web_app/pages/profile_page.dart';
import 'package:openimis_web_app/pages/userhistory.dart';
import 'package:openimis_web_app/services/api_graphql_services.dart';
import 'package:openimis_web_app/theme/custom_theme.dart';
import 'package:openimis_web_app/theme/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:openimis_web_app/ui/splash_screen.dart';
import 'package:openimis_web_app/services/bottom_nav_bar_service.dart';
import 'package:openimis_web_app/auth/login_card.dart';
import 'package:openimis_web_app/pages/settings_page.dart';
import 'package:openimis_web_app/auth/validate_otp_card.dart';
import 'langlang/app_localization_deligate.dart';
import 'package:openimis_web_app/auth/verify_insuree.dart';

import 'package:openimis_web_app/pages/claimed_item_services.dart';
import 'package:openimis_web_app/pages/submission_page.dart';
import 'package:openimis_web_app/langlang/application.dart';
import 'package:openimis_web_app/blocks/bool_provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
    try {
        WidgetsFlutterBinding.ensureInitialized();
        
        // Use try-catch for critical initializations to prevent white screen hangs
        try {
            await dotenv.load(fileName: ".env");
        } catch (e) {
            print("Error loading .env: $e");
        }

        try {
            ByteData data = await rootBundle.load('assets/ca/lets-encrypt-r3.pem');
            SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());
        } catch (e) {
            print("Error loading SSL certificate: $e");
        }

        SystemChrome.setPreferredOrientations(
            [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
            
        runApp(MyApp());
    } catch (e, stackTrace) {
        print("CRITICAL STARTUP ERROR: $e");
        print(stackTrace);
        // Still try to run the app so it's not a permanent white screen
        runApp(MyApp());
    }
}

//  WidgetsFlutterBinding.ensureInitialized();
//  final Locale locale = Locale('en');
class MyApp extends StatefulWidget {
    @override
    _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
    late AppTranslationsDelegate _newLocaleDelegate;
    late Insuree insuree;
    DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

    @override
    void initState() {
        super.initState();
        //await ApiGraphQlServices().service_providers();
        _newLocaleDelegate = AppTranslationsDelegate(newLocale: const Locale('en'));
        application.onLocaleChanged = onLocaleChange;
        getCurrentAppTheme();
    }

    void getCurrentAppTheme() async {
        await ApiGraphQlServices().service_providers();
        themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
    }

    void onLocaleChange(Locale locale) {
        setState(() {
            _newLocaleDelegate = AppTranslationsDelegate(newLocale: locale);
        });
    }
    @override
    Widget build(BuildContext context) {
        return MultiProvider(
            providers: [
                ChangeNotifierProvider<AuthBlock>.value(value: AuthBlock()),
                ChangeNotifierProvider<BottomNavigationBarProvider>.value(value: BottomNavigationBarProvider()),
                ChangeNotifierProvider<LoadingProvider>.value(value: LoadingProvider(),),
                ChangeNotifierProvider(create: (_) {
                    return themeChangeProvider;
                }),
            ],
            child: Consumer<DarkThemeProvider>(
                builder: (BuildContext context, value, Widget? child) {
                    return MaterialApp(
                        localizationsDelegates: [
                            _newLocaleDelegate,
                            GlobalMaterialLocalizations.delegate,
                            GlobalWidgetsLocalizations.delegate,
                        ],
                        supportedLocales: [
                            const Locale("en", ""),
                            const Locale("es", ""),
                        ],
                        debugShowCheckedModeBanner: false,
                        theme: CustomTheme.lightTheme,
                        darkTheme: CustomTheme.darkTheme,
                        themeMode: themeChangeProvider.darkTheme ? ThemeMode.dark : ThemeMode.light,

                        initialRoute: '/splash',
                        routes: <String, WidgetBuilder>{
                            '/card' :(BuildContext context) => Display(initIndex: 0,),
                            '/profile' :(BuildContext context) => SettingsPage(null),
                            '/splash':(BuildContext context) => SplashScreen(),
                            '/':(BuildContext context) => LoginScreen(chfid: ''),
                            '/register':(BuildContext context) => RegisterScreen(),
                            '/otp-verify' :(BuildContext context) => OtpScreen(),
                            '/insuree_verify' :(BuildContext context) => VerifyInsuree(),
                            '/reset-password':(BuildContext context) => ResetPassword(),
                            '/policy-information':(BuildContext context) => PolicyInformationPage(),
                            '/service-provider-list':(BuildContext context) => ServiceProviderPage(),
                            '/notifications':(BuildContext context) => NotificationPage(),
                            '/feedback':(BuildContext context) => FeedbackPage(),
                            '/profile-info' :(BuildContext context) => ProfileInfo(),
                            '/user-history' :(BuildContext context) => UserHistoryPage(),
                            '/show-card' :(BuildContext context) => CardDetailPage(message: ''),
                            '/faq' :(BuildContext context) => FAQ(),
                            '/claimed_item_services' : (BuildContext context) => ClaimedItemServicesPage(claimId: 0, token: ''),
                            '/PaymentsubmissionPage': (BuildContext context) => SubmissionPage(),
                            '/notice': (BuildContext context) => NoticePage(),
                            '/offices': (BuildContext context) => OfficePage(),
                            '/contact': (BuildContext context) => ContactUsPage(),
                            '/map-services' : (BuildContext context) => MapPage(),
                        },
                    );
                }));
    }
}
