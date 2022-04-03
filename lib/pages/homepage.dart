import 'dart:convert';

import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:openimis_web_app/models/insuree_info.dart';
import 'package:openimis_web_app/models/usp_policy_insuree_hib.dart';
import 'package:openimis_web_app/pages/exploreServices.dart';
import 'package:openimis_web_app/services/api_rest_services.dart';
import 'package:openimis_web_app/services/bottom_nav_bar_service.dart';
import 'package:flutter/material.dart';
import 'package:openimis_web_app/pages/claimed_item_services.dart';
import 'package:openimis_web_app/screen_size_reducers.dart';
import 'package:openimis_web_app/theme/custom_theme.dart';
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:openimis_web_app/models/medical_services.dart';
import 'package:openimis_web_app/models/claimed_services_items.dart';
import 'package:openimis_web_app/services/api_graphql_services.dart';
import 'package:openimis_web_app/models/claimed.dart';
import 'package:openimis_web_app/models/insuree_claims.dart';
import 'package:openimis_web_app/langlang/app_translation.dart';
import 'package:provider/provider.dart';
import 'package:openimis_web_app/helper/shared_preferences_helper.dart';
import 'package:openimis_web_app/langlang/application.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Homepage extends StatefulWidget {
	@override
	_HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
	Future<MedicalServices> _medicalservices;
	Future<UspPolicyInsureeHib> _usppolicybalance;
	Future<Claims> _insureeclaims;
	Future<Claimed> _claimed;
	Future<ClaimedServicesItems> _claimedservicesitems;
	AuthBlock auth;
	dynamic insureeCardDetail;
	SessionManager prefs =  SessionManager();
	double balance;
	var jpt;
	final storage = FlutterSecureStorage();
	// dynamic remainingDays;
	
	@override
	 void initState() {
		super.initState();
		application.onLocaleChanged = onLocaleChange;
			get_balance();

		_medicalservices = ApiGraphQlServices().MedicalServicesGQL('medicalservice');





		
	}

	get_balance() async {
		var user = await storage.read(key: 'user');
		var j =  json.decode(user);
		ApiRestServices().UspPolicyHIB(j['data']['insureeAuthOtp']['insuree']['chfId']).then((value){
			balance = value.balance;
		});
		return balance;
	}
	void onLocaleChange(Locale locale) async {
		setState(() {
			AppTranslations.load(locale);
		});
	}
	
	Widget build(BuildContext context) {
		auth = Provider.of<AuthBlock>(context);
		jpt = auth;
		final bottom_nav = Provider.of<BottomNavigationBarProvider>(context);
    
		return Scaffold(
			backgroundColor: CustomTheme.lightTheme.backgroundColor.withOpacity(0.5),
			body: Stack(
				children: [
					SingleChildScrollView(
						child: Column(
							children: [
								FutureBuilder<InsureeData>(
									future: ApiGraphQlServices().InsureeInfoServicesGQL(
										auth.user['data']['insureeAuthOtp']['token'],
										auth.user['data']['insureeAuthOtp']['insuree']['chfId']
									),
									builder: (context, snapshot) {
										
										if (snapshot.hasData && snapshot.data.data!=null ) {
											prefs.setFullname("${snapshot.data.data.profile.insuree.otherNames} ${snapshot.data.data.profile.insuree.lastName}");
											prefs.setImage("${snapshot.data.data.profile.photo}");
											
											return Stack(
												children: [
													// OPENIMIS LOGO & CURRENT BALANCE
													_InsureeInfoWidget(snapshot),
													
													// CARD
													_InsureeCardWidget(snapshot),
												],
											);
										}
										
										else {
											return Center(child: CircularProgressIndicator(),);
										}
									}
								
								),
								_ClaimHistoryWidget(),
							],
						),
					),
					
					// bottom_nav.currentIndex== 0 ? ExploreServicesPage() : Text(""),
				],
			),
		);
	}
	
	Widget _InsureeInfoWidget(snapshot){
		return Container(
			height: screenHeight(context, dividedBy: 3.5), //220,
			padding: EdgeInsets.all(20),
			width: double.infinity,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.only(
					bottomLeft: Radius.circular(10),
					bottomRight: Radius.circular(10)
				),
				gradient: LinearGradient(
					begin: Alignment.topLeft,
					end: Alignment.bottomRight,
					colors: [
						CustomTheme.lightTheme.primaryColor,
						CustomTheme.lightTheme.splashColor
					]
				),
			),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				mainAxisSize: MainAxisSize.min,
				children: <Widget>[
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment
								.start,
							children: <Widget>[
								CircleAvatar(
									radius: 50,
									backgroundColor: Colors.white,
									child: ClipOval(
										child: FadeInImage.assetNetwork(
											image: snapshot.hasData ? snapshot.data.data.profile.photo.replaceAll('192.168.15.22', 'imistest.hib.gov.np'): //todo server returns local ip but we need domain ip need fix
											"assets/images/openimis-logo.png",
											placeholder: "assets/images/openimis-logo.png",
											fit: BoxFit.contain,
                                        ),
									),
								),
								
								
								SizedBox(height: 8),
								Expanded(
									child: Text(
										'${snapshot.data.data.profile.insuree.otherNames} ${snapshot.data.data.profile.insuree.lastName}',
										style: TextStyle(
											fontSize: 14,
											fontWeight: FontWeight
												.normal,
											color: Colors.white
										),
										maxLines: 3,
									),
								)
							],
						),
					),
					
					VerticalDivider(
						thickness: 1.5,
						color: Colors.white,
					),
					
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment
								.end,
							mainAxisSize: MainAxisSize.max,
							children: <Widget>[
								Text(
									AppTranslations.of(context).text('current_balance'),
									style: TextStyle(
										fontSize: 18,
										fontWeight: FontWeight.bold,
										color: Colors.white
									),
								),
								SizedBox(height: 8.0),
								Text(
									env.Currency + '${balance.toString()}',
									style: TextStyle(
										fontSize: 16,
										fontWeight: FontWeight.bold,
										color: Colors.white
									),
								),
								SizedBox(height: 4.0),
								Divider(
									indent: 20.0,
									thickness: 1.5,
									color: Colors.white,
								),
								SizedBox(height: 8.0),
                                Text(
                                    AppTranslations.of(context).text('first_service_point'),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),
                                ),
                                SizedBox(height: 8.0),
								Text(
									'${snapshot.data.data.profile.insuree.healthFacility.name ?? "N/A"}',
									style: TextStyle(
										fontSize: 16,
										fontWeight: FontWeight.normal,
										color: Colors.white
									),
								)
							],
						),
					),
				],
			)
		);
	}

	String _InsureeCardWidgetExpiresOn(args){
		var insureePolicies = args['insureePolicies'];
		if( insureePolicies != null){
			List listInsureePolicies = insureePolicies;
			var lastPolicy = insureePolicies[listInsureePolicies.length-1];
			DateTime expiryDate = lastPolicy.policy.expiryDate;
			return '  ${expiryDate.year}-${expiryDate.month}-${expiryDate.day} ';
		}
		return "";
	}
	
	Widget _InsureeCardWidget(snapshot){
		return Container(
			height: MediaQuery.of(context).size.height*0.16, //100
			padding: EdgeInsets.all(8.0),
			margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.22), //165
			child: Card(
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(20)
				),
				child: Padding(
					padding: EdgeInsets.all(4.0),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.spaceEvenly,
						mainAxisSize: MainAxisSize.max,
						children: [
							Container(
								child: Card(
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(8),
										side: BorderSide(color: CustomTheme.lightTheme.primaryColor)
									),
									child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
										mainAxisSize: MainAxisSize.min,
										children: [
											Container(
												width: MediaQuery.of(context).size.width*0.4, //150,
												decoration: BoxDecoration(
													borderRadius: BorderRadius.only(
														topRight: Radius.circular(8),
														topLeft: Radius.circular(8),
													),
													color: CustomTheme.lightTheme.primaryColor
												),
												padding: EdgeInsets.all(4),
												child: Text(
													AppTranslations.of(context).text('remaining'),
													style: TextStyle(
														fontSize: 16,
														fontWeight: FontWeight.bold,
														color: Colors.white
													),
												),
											),
											SizedBox(height: 4.0),
											Text(
												'${int.parse(snapshot.data.data.profile.remainingDays) > 0 ?
												snapshot.data.data.profile.remainingDays : "Expired" }',
												style: TextStyle(
													fontSize: 16,
													fontWeight: FontWeight.bold
												),
												// textAlign: TextAlign.center,
											),
                                            SizedBox(height: 4.0),
										],
									),
								),
							),
							Container(
								child: Card(
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(8),
										side: BorderSide(color: CustomTheme.lightTheme.primaryColor)
									),
									child: Column(
										// crossAxisAlignment: CrossAxisAlignment.center,
										children: [
											Container(
												width: MediaQuery.of(context).size.width*0.4, // 150,
												decoration: BoxDecoration(
													borderRadius: BorderRadius.only(
														topRight: Radius.circular(8),
														topLeft: Radius.circular(8),
													),
													color: CustomTheme.lightTheme.primaryColor
												),
												padding: EdgeInsets.all(4),
												child: Text(
													AppTranslations.of(context).text('expire_on'),
													style: TextStyle(
														fontSize: 16,
														fontWeight: FontWeight.bold,
														color: Colors.white,
													),
													// textAlign: TextAlign.center,
												),
											),
											SizedBox(height: 4.0),
											
											//Text('  ${snapshot.data.data.profile.insuree.insureePolicies[0].policy.expiryDate.year}-${snapshot.data.data.profile.insuree.insureePolicies[0].policy.expiryDate.month}-${snapshot.data.data.profile.insuree.insureePolicies[0].policy.expiryDate.day}  ')
											Text(
												_InsureeCardWidgetExpiresOn({'insureePolicies': snapshot.data.data.profile.insuree.insureePolicies}),
												style: TextStyle(
													fontSize: 16,
													fontWeight: FontWeight.bold
												),
											)
											//Text('${remainingDays.lastName}')
										],
									),
								),
							),
						],
					)
				)
			),
		);
	}
	
	Widget _ClaimHistoryWidget(){
		return Container(
			padding: EdgeInsets.only(left: 16.0, right: 16.0),
			child: Column(
				children: [
					ListTile(
						title: Text(
							AppTranslations.of(context).text("history"),
							style: TextStyle(
								fontSize: 18.0,
								fontWeight: FontWeight.normal
							),
						),
						leading: Icon(Icons.history, color: Colors.green, size: 30,),
						trailing: GestureDetector(
							onTap: (){
								Navigator.pushNamed(context, '/user-history');
							},
							child: Text(
								AppTranslations.of(context).text('see_all'),
								style: TextStyle(
									fontSize: 16.0,
									fontWeight: FontWeight.normal
								),
							),
						)
					),
					FutureBuilder<Claims>(
						future: ApiGraphQlServices()
							.ClaimsServicesGQL(
							auth.user['data']['insureeAuthOtp']['token'],
							auth.user['data']['insureeAuthOtp']['insuree']['chfId']
						),
						builder: (context, snapshot) {
							if(snapshot.hasData && snapshot.data.data!=null) {
								return ListView.builder(
									shrinkWrap: true,
									scrollDirection: Axis.vertical,
									physics: NeverScrollableScrollPhysics(),
									itemCount: snapshot.data.data.insureeProfile.insureeClaim.length,
									itemBuilder: (BuildContext context, int index){
										var claims = snapshot.data.data.insureeProfile.insureeClaim[index];
										return ListTile(
											title: Text('${claims.healthFacility.name}'),
											subtitle: Text('${claims.dateClaimed.year}-${claims.dateClaimed.month}-${claims.dateClaimed.day}'),
											trailing:
											Column(
												children: [
													Text('${env.Currency} ${claims.claimed}'),
													claims.status==2 ? Text('Unverified', style: TextStyle(color: Colors.red),) : Text("")
												],
											),

											onTap: () {
												Navigator.push(
													context,
													MaterialPageRoute(
														builder: (context) => ClaimedItemServicesPage(claimid: int.parse(claims.id)),
													),
												);
											},
										);
									}
								);
							}
							
							else{
								return Center(child: CircularProgressIndicator());
							}
						}
					)
				],
			),
		);
	}
}