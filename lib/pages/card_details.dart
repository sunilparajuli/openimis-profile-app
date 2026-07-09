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

class CardDetailPage extends StatefulWidget {
    final String message;
    CardDetailPage({Key key, @required this.message}) : super(key: key);
    @override
    _CardDetailPageState createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
    AuthBlock auth;

    DateTime dateTimeNow = DateTime.now();
    
    @override
    void initState() {
        // TODO: implement initState
        super.initState();
        application.onLocaleChanged = onLocaleChange;
//        _policyinformation = ApiGraphQlServices().PolicyInformationServicesGQL(auth.user['data']['insureeAuthOtp']['token'], auth.user['data']['insureeAuthOtp']['insuree']['chfId']);
        Future(() {
            if (widget.message != null && widget.message.isNotEmpty) {
                showInSnackBar(widget.message);
            }
        });

    }
    
    void onLocaleChange(Locale locale) async {
        setState(() {
            AppTranslations.load(locale);
        });
    }

    void showInSnackBar(String value) {
        ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(value), duration: Duration(milliseconds: 3000), ), );
    }

    _replaceCHFID(chfId) {
        // print(chfId);
        final regexp = RegExp(r'(\d{3})(\d{3})(\d{3})');
        final result = chfId.replaceAllMapped(regexp, (match) => '${match[1]}-${match[2]}-${match[3]}');
        print(result);
        return result;
    }

    @override
    Widget build(BuildContext context) {
        auth = Provider.of<AuthBlock>(context);
        return Scaffold(
            backgroundColor: CustomTheme.lightTheme.primaryColor,
	        appBar: AppBar(
		        elevation: 0.0,
		        title: Text(
			       AppTranslations.of(context).text('page_card_details'),
			        style: TextStyle(
				        color: Colors.white
			        ),
		        ),
		        backgroundColor: CustomTheme.lightTheme.primaryColor,
	        ),
            body: Column(
                children: <Widget>[
                    Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30)
                                )
                            ),
                            child: Padding(
                                padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 10.0),
                                child: FutureBuilder<PolicyInformation>(
                                    future: ApiGraphQlServices().PolicyInformationServicesGQL(
                                        auth.user['data']['insureeAuthOtp']['token'],
                                        auth.user['data']['insureeAuthOtp']['insuree']['chfId']
                                    ),
                                    builder: (context, snapshot) {
                                        if(snapshot.hasData) {
                                            var policyprofile = snapshot.data.data.insureeProfile;
                                            var totalPolicies = snapshot.data.data.insureeProfile.insureePolicies.length -1;
                                            var insureeProfile = snapshot.data.data.insureeProfile.insureePolicies[totalPolicies];
                                            return ListView(
                                                children: [
                                                    // CARD
                                                    _virtualCardWidget(policyprofile, insureeProfile),
                                                ],
                                            );
                                        }
                                        else {
                                            return Center(child: CircularProgressIndicator());
                                        }
                                    }
                                ),
                            ),
                        )
                    )
                ],

            ),
            floatingActionButton : FloatingActionButton(onPressed: () async{
                await helper.SessionManager().setRefreshApi(true);
                setState(() {

                });
            },
                child: Icon(Icons.refresh)),
        );
    }

    Widget _buildPopupDialog(BuildContext context) {
      return new AlertDialog(
        content: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
             Container(
               width: 200,
            height: 200,
               child: QrImage(
                  data:  auth.user['data']['insureeAuthOtp']['insuree']['chfId'].toString(),//"1234567890",
                  version: QrVersions.auto,
                  size: 64.0,
                  
              ),
             )
            
          ],
        ),
        // actions: <Widget>[
        //   new FlatButton(
        //     onPressed: () {
        //       Navigator.of(context).pop();
        //     },
        //     textColor: Theme.of(context).primaryColor,
        //     // child: const Text('Close'),
        //   ),
        // ],
      );
    }
    
    // ignore: non_constant_identifier_names
    Widget _virtualCardWidget(policyprofile, insureeProfile){
        var chfId = '${policyprofile.chfId}';
        return Container(
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: CustomTheme.lightTheme.primaryColor, width: 1.0)
                ),
                // color: CustomTheme.lightTheme.splashColor,
                //Colors.orange,
                child: Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                            Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceAround,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                    Image.asset(
                                        'assets/images/nepal-embelm.png',
                                        height: 40,
                                    ),
                                    SizedBox(width: 4.0),
                                    Image.asset(
                                        'assets/images/shs.png',
                                        height: 40,
                                    ),
                                    SizedBox(width: 4.0),
                                    Column(
                                        children: [
                                            Text(
                                                'नेपाल सरकार',
                                                style: TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.bold,
                                                ),
                                            ),
                                            Text(
                                                'स्वास्थ्य बीमा बोर्ड',
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.bold,
                                                ),
                                            ),
                                        ],
                                    ),
                                    SizedBox(width: 8.0),
                                    InkWell(
                                        onTap: (){
                                           showDialog(
                                              context: context,
                                              builder: (BuildContext context) => _buildPopupDialog(context),
                                            );
                                        },
                                        child: QrImage(
                                            data:  auth.user['data']['insureeAuthOtp']['insuree']['chfId'].toString(),//"1234567890",
                                            version: QrVersions.auto,
                                            size: 64.0,
                                        ),
                                    )
                                ],
                            ),
                        
                            SizedBox(height: 8.0),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                    Text(
                                        AppTranslations.of(context).text('member_id') + ': '+ _replaceCHFID(chfId),
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.normal,
                                        ),
                                    ),
                                ],
                            ),
                        
                            SizedBox(height: 8.0),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                    Text(
                                        AppTranslations.of(context).text('name_surname'),
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.normal,
                                        ),
                                    ),
                                    // SizedBox(width: 8.0),
                                    Text(
                                        ': ${policyprofile.otherNames} ${policyprofile.lastName}',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.normal,
                                            decoration: TextDecoration.underline,
                                            decorationStyle: TextDecorationStyle.dotted,
                                        ),
                                    ),
                                ],
                            ),
                        
                            SizedBox(height: 8.0),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                    Text(
                                        AppTranslations.of(context).text('dob_date') + ': ${insureeProfile.insuree.dob.year}-${insureeProfile.insuree.dob.month}-${insureeProfile.insuree.dob.day}',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.normal,
                                        ),
                                    ),
                                    Text(
                                        AppTranslations.of(context).text('gender') + ': ${insureeProfile.insuree.gender.gender}',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.normal,
                                        ),
                                    )
                                ],
                            ),
                        
                            SizedBox(height: 8.0),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                    Text(
                                        AppTranslations.of(context).text('first_hf')+ ':',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.normal,
                                        ),
                                    ),
                                    SizedBox(width: 8.0),
                                    // Expanded(
                                    //     child: new Text("A looooooooooooooooooong text")),

                                      Expanded(child:

                                    Text(
                                        insureeProfile.insuree.healthFacility!=null ?
                                        '${insureeProfile.insuree.healthFacility.name}' : Text(""),

                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.normal,
                                            decoration: TextDecoration.underline,
                                            decorationStyle: TextDecorationStyle.dotted,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                    ),
                                    )
                                ],
                            ),
    
                            SizedBox(height: 8.0),
                            Wrap(
                                spacing: 16.0,
                                runSpacing: 8.0,
                                children: [
                                    if (insureeProfile.policy.startDate != null)
                                        Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                                Text(
                                                    'Start Date:',
                                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
                                                ),
                                                SizedBox(width: 4.0),
                                                Text(
                                                    '${insureeProfile.policy.startDate.year}-${insureeProfile.policy.startDate.month}-${insureeProfile.policy.startDate.day}',
                                                    style: TextStyle(fontSize: 16.0, decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.dotted),
                                                ),
                                            ],
                                        ),
                                    if (insureeProfile.policy.enrollDate != null)
                                        Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                                Text(
                                                    'Enroll Date:',
                                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
                                                ),
                                                SizedBox(width: 4.0),
                                                Text(
                                                    '${insureeProfile.policy.enrollDate.year}-${insureeProfile.policy.enrollDate.month}-${insureeProfile.policy.enrollDate.day}',
                                                    style: TextStyle(fontSize: 16.0, decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.dotted),
                                                ),
                                            ],
                                        ),
                                    Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                            Text(
                                                AppTranslations.of(context).text('expiry_date') + ':',
                                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
                                            ),
                                            SizedBox(width: 4.0),
                                            Text(
                                                insureeProfile.policy.expiryDate != null ? '${insureeProfile.policy.expiryDate.year}-${insureeProfile.policy.expiryDate.month}-${insureeProfile.policy.expiryDate.day}' : "",
                                                style: TextStyle(fontSize: 16.0, decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.dotted),
                                            ),
                                        ],
                                    ),
                                ],
                            ),
                        ],
                    ),
                )
            ),
        );
    }
    

}
