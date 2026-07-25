import 'dart:async';
import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:openimis_web_app/models/policy_information.dart';
import 'package:openimis_web_app/services/api_graphql_services.dart';
import 'package:openimis_web_app/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:openimis_web_app/langlang/app_translation.dart';
import 'package:openimis_web_app/langlang/application.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:openimis_web_app/helper/shared_preferences_helper.dart' as helper;
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:apple_passkit/apple_passkit.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';

class CardDetailPage extends StatefulWidget {
    final String message;
    CardDetailPage({Key? key, required this.message}) : super(key: key);
    @override
    _CardDetailPageState createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
    DateTime dateTimeNow = DateTime.now();
    Future<PolicyInformation>? _policyInfoFuture;

    @override
    void initState() {
        super.initState();
        application.onLocaleChanged = onLocaleChange;
        WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.message.isNotEmpty) {
                showInSnackBar(widget.message);
            }
        });
    }

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        final auth = Provider.of<AuthBlock>(context, listen: false);
        if (auth.user != null && auth.user['data'] != null) {
            final token = auth.user['data']['insureeAuthOtp']['token'];
            final chfId = auth.user['data']['insureeAuthOtp']['insuree']['chfId'];
            _policyInfoFuture ??= ApiGraphQlServices().PolicyInformationServicesGQL(token, chfId);
        }
    }

    void onLocaleChange(Locale locale) async {
        setState(() {
            AppTranslations.load(locale);
        });
    }

    void showInSnackBar(String value) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(value),
                duration: Duration(milliseconds: 3000),
            ),
        );
    }

    String _replaceCHFID(String chfId) {
        final regexp = RegExp(r'(\d{3})(\d{3})(\d{3})');
        return chfId.replaceAllMapped(regexp, (match) => '${match[1]}-${match[2]}-${match[3]}');
    }

    // Helper updated to handle dynamic alignment (Justified layout)
    Widget _buildDateItem(String label, DateTime? date, {bool isExpiry = false, CrossAxisAlignment alignment = CrossAxisAlignment.center}) {
        return Column(
            crossAxisAlignment: alignment,
            children: [
                Text(label, style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 4.0),
                Text(
                    date != null
                        ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
                        : 'N/A',
                    style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: isExpiry ? Colors.red.shade700 : Colors.black87,
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.dotted,
                    ),
                ),
            ],
        );
    }

    Widget _buildAddToAppleWalletButton(String chfId) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton.icon(
                onPressed: () => _addToAppleWallet(chfId),
                icon: const Icon(Icons.wallet, color: Colors.white),
                label: const Text("Add to Apple Wallet"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
            ),
        );
    }

    Widget _buildAddToGoogleWalletButton(String chfId) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton.icon(
                onPressed: () => _addToGoogleWallet(chfId),
                icon: const Icon(Icons.wallet, color: Colors.white),
                label: const Text("Add to Google Wallet"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
            ),
        );
    }

    Future<void> _addToAppleWallet(String chfId) async {
        try {
            // 1. Check if device supports adding passes
            final ApplePassKit passkit = ApplePassKit();
            bool canAdd = await passkit.canAddPasses();
            if (!canAdd) {
                showInSnackBar("Apple Wallet is not available on this device.");
                return;
            }

            // 2. Show loading
            showInSnackBar("Preparing your Apple Wallet pass...");

            // 3. Fetch the .pkpass file from the server
            final String passUrl = "${env.API_HIB_REST_URL}insuree/pass/$chfId";
            final auth = Provider.of<AuthBlock>(context, listen: false);
            final String token = auth.user['data']['insureeAuthOtp']['token'];

            final response = await http.get(
                Uri.parse(passUrl),
                headers: {
                    "Insuree-Token": token,
                    "App-Version": env.APP_VERSION,
                },
            );

            if (response.statusCode == 200) {
                // 4. Present the Wallet prompt
                await passkit.addPass(response.bodyBytes);
            } else {
                showInSnackBar("Failed to download pass. Server returned ${response.statusCode}");
            }
        } catch (e) {
            print("Apple Wallet Error: $e");
            showInSnackBar("Could not add to Wallet: $e");
        }
    }

    Future<void> _addToGoogleWallet(String chfId) async {
        try {
            showInSnackBar("Preparing your Google Wallet pass...");

            final String passUrl = "${env.API_HIB_REST_URL}insuree/google-pass/$chfId";
            final auth = Provider.of<AuthBlock>(context, listen: false);
            final String token = auth.user['data']['insureeAuthOtp']['token'];

            final response = await http.get(
                Uri.parse(passUrl),
                headers: {
                    "Insuree-Token": token,
                    "App-Version": env.APP_VERSION,
                },
            );

            if (response.statusCode == 200) {
                final responseData = jsonDecode(response.body);
                final String jwt = responseData['jwt'];
                
                // Using MethodChannel to communicate with native Android for Google Wallet
                const platform = MethodChannel('hib.np.gov/google_wallet');
                await platform.invokeMethod('savePassesJwt', {'jwt': jwt});
            } else {
                showInSnackBar("Failed to prepare pass. Server returned ${response.statusCode}");
            }
        } catch (e) {
            print("Google Wallet Error: $e");
            showInSnackBar("Could not add to Google Wallet: $e");
        }
    }

    @override
    Widget build(BuildContext context) {
        final auth = Provider.of<AuthBlock>(context);

        return Scaffold(
            backgroundColor: CustomTheme.lightTheme.primaryColor,
            appBar: AppBar(
                elevation: 0.0,
                title: Text(AppTranslations.of(context).text('page_card_details'), style: TextStyle(color: Colors.white)),
                backgroundColor: CustomTheme.lightTheme.primaryColor,
            ),
            body: Column(
                children: <Widget>[
                    Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                            ),
                            child: Padding(
                                padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 10.0),
                                child: FutureBuilder<PolicyInformation>(
                                    future: _policyInfoFuture,
                                    builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                            var policyprofile = snapshot.data!.data.insureeProfile;
                                            var totalPolicies = snapshot.data!.data.insureeProfile.insureePolicies.length - 1;
                                            var insureeProfile = snapshot.data!.data.insureeProfile.insureePolicies[totalPolicies];
                                            return ListView(
                                              children: [
                                                _virtualCardWidget(policyprofile, insureeProfile, auth),
                                                SizedBox(height: 20),
                                                if (Platform.isIOS) 
                                                  _buildAddToAppleWalletButton(policyprofile.chfId),
                                                if (Platform.isAndroid)
                                                  _buildAddToGoogleWalletButton(policyprofile.chfId),
                                              ],
                                            );
                                        } else if (snapshot.hasError) {
                                            return Center(child: Text("Error loading policy information"));
                                        } else {
                                            return Center(child: CircularProgressIndicator());
                                        }
                                    },
                                ),
                            ),
                        ),
                    )
                ],
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () async {
                    await helper.SessionManager().setRefreshApi(true);
                    setState(() {
                        final token = auth.user['data']['insureeAuthOtp']['token'];
                        final chfId = auth.user['data']['insureeAuthOtp']['insuree']['chfId'];
                        _policyInfoFuture = ApiGraphQlServices().PolicyInformationServicesGQL(token, chfId);
                    });
                },
                backgroundColor: Colors.white,
                child: Icon(Icons.refresh, color: CustomTheme.lightTheme.primaryColor),
            ),
        );
    }

    Widget _buildPopupDialog(BuildContext context, AuthBlock auth) {
        return AlertDialog(
            content: Container(
                width: 200,
                height: 200,
                child: QrImageView(
                    data: auth.user['data']['insureeAuthOtp']['insuree']['chfId'].toString(),
                    version: QrVersions.auto,
                    size: 64.0,
                ),
            ),
        );
    }

    Widget _virtualCardWidget(policyprofile, insureeProfile, AuthBlock auth) {
        var chfId = '${policyprofile.chfId}';
        return Container(
            child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: CustomTheme.lightTheme.primaryColor, width: 1.0)),
                child: Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                    Image.asset('assets/images/nepal-embelm.png', height: 40),
                                    Image.asset('assets/images/shs.png', height: 40),
                                    Column(children: [
                                        Text('नेपाल सरकार', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
                                        Text('स्वास्थ्य बीमा बोर्ड', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold))
                                    ]),
                                    InkWell(
                                        onTap: () => showDialog(context: context, builder: (BuildContext context) => _buildPopupDialog(context, auth)),
                                        child: QrImageView(data: auth.user['data']['insureeAuthOtp']['insuree']['chfId'].toString(), version: QrVersions.auto, size: 64.0),
                                    )
                                ],
                            ),
                            SizedBox(height: 8.0),
                            Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text(AppTranslations.of(context).text('member_id') + ': ' + _replaceCHFID(chfId), style: TextStyle(fontSize: 16.0))]),
                            SizedBox(height: 8.0),
                            Row(children: [
                                Text(AppTranslations.of(context).text('name_surname')),
                                Text(': ${policyprofile.otherNames} ${policyprofile.lastName}', style: TextStyle(decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.dotted))
                            ]),
                            SizedBox(height: 8.0),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text(AppTranslations.of(context).text('dob_date') + ': ${insureeProfile.insuree.dob.year}-${insureeProfile.insuree.dob.month}-${insureeProfile.insuree.dob.day}'),
                                Text(AppTranslations.of(context).text('gender') + ': ${insureeProfile.insuree.gender.gender}')
                            ]),
                            SizedBox(height: 8.0),
                            Row(children: [
                                Text(AppTranslations.of(context).text('first_hf') + ':'),
                                SizedBox(width: 8.0),
                                Expanded(child: Text(insureeProfile.insuree.healthFacility != null ? '${insureeProfile.insuree.healthFacility.name}' : "", style: TextStyle(decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.dotted), overflow: TextOverflow.ellipsis))
                            ]),

                            // Justified Layout: Left, Center, Right aligned respectively
                            SizedBox(height: 8.0),
                            Row(
                                children: [
                                    Expanded(child: _buildDateItem(insureeProfile.policy.stage == 'Renewed' ? 'Renewed date:' : 'Enroll date:', insureeProfile.policy.enrollDate, alignment: CrossAxisAlignment.start)),
                                    Expanded(child: _buildDateItem('Active date:', insureeProfile.policy.startDate, alignment: CrossAxisAlignment.center)),
                                    Expanded(child: _buildDateItem('Expiry date:', insureeProfile.policy.expiryDate, isExpiry: true, alignment: CrossAxisAlignment.end)),
                                ],
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}
