import 'dart:async';
import 'package:openimis_web_app/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:openimis_web_app/langlang/app_translation.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:openimis_web_app/langlang/application.dart';

import 'package:openimis_web_app/helper/shared_preferences_helper.dart';
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:provider/provider.dart';
import 'package:openimis_web_app/ui/onboarding/onboarding_card.dart';
import 'package:openimis_web_app/services/bottom_nav_bar_service.dart';

class SettingsPage extends StatefulWidget {
  final dynamic feedbackMessage;
  SettingsPage(this.feedbackMessage);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
// 	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static final List<String> languagesList = application.supportedLanguages;
  static final List<String> languageCodesList =
      application.supportedLanguagesCodes;

  final Map<dynamic, dynamic> languagesMap = {
    languagesList[0]: languageCodesList[0],
    languagesList[1]: languageCodesList[1],
  };
  SessionManager prefs = SessionManager();

  File? _image;
  final picker = ImagePicker();
  late AuthBlock auth;

  Future<void> getImage() async {
    var image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _image = File(image.path);
        print('Image Path $_image');
      });
      uploadPic();
    }
  }

  @override
  void initState() {
    super.initState();
    application.onLocaleChanged = onLocaleChange;
  }

  void onLocaleChange(Locale locale) async {
    setState(() {
      AppTranslations.load(locale);
    });
  }

  void _select(String language) async {
    print("dd " + language);

    onLocaleChange(Locale(languagesMap[language]));
  }

  Future<void> uploadPic() async {
    final dynamic fileName = basename(_image!.path);
    //  StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
    //  StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    //  StorageTaskSnapshot taskSnapshot=await uploadTask.onComplete;
    var uri = Uri.parse("/api/profile/");

    var request = new http.MultipartRequest("POST", uri);
    request.files.add(new http.MultipartFile.fromBytes(
        'file', await File.fromUri(Uri.parse(fileName)).readAsBytes(),
        contentType: new MediaType('image', 'jpeg')));
    request.fields['address'] = 'address';
    request.send().then((response) {
      if (response.statusCode == 200) print("Uploaded!");
      setState(() {
        print("Profile Picture uploaded");
        // _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Profile Picture Uploaded')));
      });
    });
  }

  void showMessage(String val, context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(val),
        duration: Duration(milliseconds: 3000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.feedbackMessage != null) {
      showMessage(widget.feedbackMessage, context);
    }
    return Scaffold(
      backgroundColor: CustomTheme
          .lightTheme.colorScheme.surface, //Color.fromRGBO(234, 239, 255, 50),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // PROFILE INFO
            Container(
              margin: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: CustomTheme.lightTheme.primaryColor.withValues(alpha: 0.1), width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  onTap: () {
                    print('Profile Clicked');
                    Navigator.pushNamed(context, '/profile-info');
                  },
                  child: FutureBuilder<String>(
                      future: prefs.getFullname(),
                      builder: (context, snapshot) {
                        var fullname = snapshot.data;
                        if (snapshot.hasData) {
                          return Container(
                            child: ListTile(
                              title: Text('${fullname}', style: TextStyle(fontWeight: FontWeight.w600)),
                              trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                              leading: Container(
                                width: 50.0,
                                height: 50.0,
                                child: FutureBuilder<String>(
                                    future: prefs.getImage(),
                                    builder: (context, snapshot) {
                                      return Card(
                                        elevation: 0,
                                        semanticContainer: true,
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        child: (_image != null)
                                            ? Image.file(
                                                _image!,
                                                fit: BoxFit.cover,
                                              )
                                            : (snapshot.hasData && snapshot.data!.isNotEmpty)
                                                ? Image.network(
                                                    snapshot.data!.replaceAll('192.168.15.22', 'imistest.hib.gov.np'),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: CustomTheme.lightTheme.primaryColor, size: 30),
                                                  )
                                                : Icon(
                                                    Icons.person, color: CustomTheme.lightTheme.primaryColor, size: 30),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          side: BorderSide(color: CustomTheme.lightTheme.primaryColor.withValues(alpha: 0.2)),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          );
                        } else {
                          return ListTile(
                            title: Text("Profile not set"),
                            leading: Icon(Icons.person_outline, color: CustomTheme.lightTheme.primaryColor),
                          );
                        }
                      }),
                ),
              ),
            ),

            // GENERAL
            _buildGeneralWidget(context),

            // UPDATE LANGUAGE
            _buildUpdateLanguageWidget(context),

            // CONTACT US
            _buildContactWidget(context),

            // LOGOUT
            _buildLogoutWidget(context),
            
            // APP VERSION
            _buildAppVersionWidget(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralWidget(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: CustomTheme.lightTheme.primaryColor.withValues(alpha: 0.1), width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.1),
                              width: 1.0))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        AppTranslations.of(context).text("general"),
                        style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: "Open-sans",
                            fontWeight: FontWeight.bold,
                            color: CustomTheme.lightTheme.primaryColor),
                      )
                    ],
                  ),
                ),

                // SERVICE PROVIDER LIST
                Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.1),
                                width: 1.0))),
                    child: GestureDetector(
                        onTap: () {
                          print("Service Provider List Clicked...");
                          Navigator.pushNamed(
                              context, '/service-provider-list');
                        },
                        child: ListTile(
                          title: Text(
                            AppTranslations.of(context)
                                .text("service_provider_list"),
                            style: TextStyle(fontSize: 15),
                          ),
                          leading: Icon(Icons.list, color: CustomTheme.lightTheme.primaryColor),
                          trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                        ))),

                // NOTICE
                Container(
                    child: GestureDetector(
                        onTap: () {
                          print("Notice Board clicked");
                          Navigator.pushNamed(context, '/notice');
                        },
                        child: ListTile(
                          title: Text(
                            AppTranslations.of(context).text("notice"),
                            style: TextStyle(fontSize: 15),
                          ),
                          leading: Icon(Icons.note, color: CustomTheme.lightTheme.primaryColor),
                          trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                        ))),
              ],
            ),
          )),
    );
  }

  Widget _buildUpdateLanguageWidget(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: CustomTheme.lightTheme.primaryColor.withValues(alpha: 0.1), width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(
              AppTranslations.of(context).text("update_language"),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              AppTranslations.of(context).text("change_language_text"),
              style: TextStyle(fontSize: 12),
            ),
            leading: Icon(
              Icons.language,
              size: 28,
              color: CustomTheme.lightTheme.primaryColor,
            ),
            trailing: DropdownButton<String>(
              underline: SizedBox(),
              focusColor: CustomTheme.lightTheme.primaryColor,
              style: TextStyle(color: CustomTheme.lightTheme.primaryColor, fontWeight: FontWeight.bold),
              iconEnabledColor: CustomTheme.lightTheme.primaryColor,
              items:
                  languagesList.map<DropdownMenuItem<String>>((String choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(
                    choice,
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
              onChanged: (String? language) { if (language != null) _select(language); },
              hint: Text('Select', style: TextStyle(fontSize: 14)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactWidget(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: CustomTheme.lightTheme.primaryColor.withValues(alpha: 0.1), width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/contact');
            },
            child: Container(
              child: ListTile(
                title: Text(
                  AppTranslations.of(context).text("contact_us"),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                subtitle: Text('Have any queries? Contact us', style: TextStyle(fontSize: 12)),
                leading: Icon(
                  Icons.phone_in_talk,
                  size: 28,
                  color: CustomTheme.lightTheme.primaryColor,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
            ),
          )),
    );
  }

  Widget _buildLogoutWidget(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.red.withValues(alpha: 0.1), width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: GestureDetector(
            onTap: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(AppTranslations.of(context).text("logout_confirmation_title")),
                    content: Text(AppTranslations.of(context).text("logout_confirmation_message")),
                    actions: <Widget>[
                      TextButton(
                        child: Text(AppTranslations.of(context).text("no")),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text(AppTranslations.of(context).text("yes"), style: TextStyle(color: Colors.red)),
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final bottomNav = Provider.of<BottomNavigationBarProvider>(context, listen: false);
                          final auth = Provider.of<AuthBlock>(context, listen: false);

                          navigator.pop();
                          
                          // Reset the navigation index to homepage (0) before logging out
                          bottomNav.currentIndex = 0;

                          await auth.logout();
                          
                          navigator.pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => OpenimisOnboardingPage()),
                            (Route<dynamic> route) => false
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              child: ListTile(
                title: Text(
                  AppTranslations.of(context).text("logout"),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.red),
                ),
                subtitle: Text('Sign out of your account', style: TextStyle(fontSize: 12)),
                leading: Icon(
                  Icons.logout,
                  size: 28,
                  color: Colors.red,
                ),
              ),
            ),
          )),
    );
  }

  Widget _buildAppVersionWidget(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.1), width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          child: ListTile(
            title: Text('App Version', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            subtitle: Text('${env.APP_VERSION}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            leading: Icon(
              Icons.info_outline,
              size: 24,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
