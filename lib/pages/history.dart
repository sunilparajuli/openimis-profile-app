import 'dart:async';
import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:openimis_web_app/models/insuree_info.dart';
import 'package:openimis_web_app/theme/custom_theme.dart';
import 'package:flutter/material.dart';

import 'package:openimis_web_app/common/env.dart' as env;
import 'package:openimis_web_app/services/api_graphql_services.dart';
import 'package:openimis_web_app/models/insuree_claims.dart';
import 'package:provider/provider.dart';
import '../langlang/app_translation.dart';
import '../screen_size_reducers.dart';
import 'claimed_item_services.dart';
import 'exploreServices.dart';

class HistoryPage extends StatefulWidget {
	@override
	_HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
	// 1. Keep only the futures you actually use, and declare them as nullable
	//    or initialize them properly without using unsafe 'late' flags.
	Future<InsureeData>? _insureeInfoFuture;
	Future<Claims>? _claimsFuture;

	@override
	void initState() {
		super.initState();
	}

	@override
	void didChangeDependencies() {
		super.didChangeDependencies();

		// 2. Fetch provider-dependent futures here so they only run ONCE
		//    when the page initializes or auth changes, preventing infinite API re-calls.
		final auth = Provider.of<AuthBlock>(context);

		if (auth.user['data'] != null) {
			final token = auth.user['data']['insureeAuthOtp']['token'];
			final chfId = auth.user['data']['insureeAuthOtp']['insuree']['chfId'];

			_insureeInfoFuture ??= ApiGraphQlServices().InsureeInfoServicesGQL(token, chfId, false);
			_claimsFuture ??= ApiGraphQlServices().ClaimsServicesGQL(token, chfId, true);
		}
	}

	String _claimStatusString(int status) {
		if (status == 2) return "Unverifed";
		if (status == 4) return "Checked";
		if (status == 8) return "Reviewed";
		if (status == 16) return "Valuated";
		return "-";
	}

	Color _claimStatusColor(int status) {
		if (status == 2) return Colors.red;
		if (status == 4) return Colors.orange;
		if (status == 8) return Colors.blue;
		if (status == 16) return Colors.green;
		return Colors.black;
	}

	@override
	Widget build(BuildContext context) {
		// Localized provider variable instead of class-level 'late'
		final auth = Provider.of<AuthBlock>(context);

		return Scaffold(
			backgroundColor: CustomTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
			body: Stack(
				children: [
					SingleChildScrollView(
						child: Column(
							children: [
								Stack(
									children: [
										// OPENIMIS LOGO & CURRENT BALANCE
										Container(
											height: screenHeight(context, dividedBy: 4),
											padding: EdgeInsets.all(20),
											width: double.infinity,
											decoration: BoxDecoration(
												borderRadius: BorderRadius.only(
													bottomLeft: Radius.circular(10),
													bottomRight: Radius.circular(10),
												),
												gradient: LinearGradient(
													begin: Alignment.topLeft,
													end: Alignment.bottomRight,
													colors: [
														CustomTheme.lightTheme.primaryColor,
														CustomTheme.lightTheme.splashColor,
													],
												),
											),
											child: FutureBuilder<InsureeData>(
												// 3. Bind the stored future variable here
												future: _insureeInfoFuture,
												builder: (context, snapshot) {
													if (snapshot.hasData) {
														final profile = snapshot.data!.data.profile;
														return Row(
															mainAxisAlignment: MainAxisAlignment.spaceBetween,
															mainAxisSize: MainAxisSize.min,
															children: <Widget>[
																Expanded(
																	child: Column(
																		crossAxisAlignment: CrossAxisAlignment.start,
																		children: <Widget>[
																			CircleAvatar(
																				radius: 30,
																				backgroundColor: Colors.white,
																				child: ClipOval(
																					child: (profile.photo != null && profile.photo!.trim().isNotEmpty)
																							? FadeInImage.assetNetwork(
																									image: profile.photo!.replaceAll('192.168.15.22', 'imistest.hib.gov.np'),
																									placeholder: "assets/images/hib-logo.png",
																									fit: BoxFit.cover,
																									imageErrorBuilder: (context, error, stackTrace) {
																										return Image.asset(
																											"assets/images/hib-logo.png",
																											fit: BoxFit.cover,
																										);
																									},
																								)
																							: Image.asset(
																									"assets/images/hib-logo.png",
																									fit: BoxFit.cover,
																								),
																				),
																			),
																			SizedBox(height: 8),
																			Expanded(
																				child: Text(
																					'${profile.insuree.otherNames} ${profile.insuree.lastName}',
																					style: TextStyle(
																						fontSize: 14,
																						fontWeight: FontWeight.normal,
																						color: Colors.white,
																					),
																					maxLines: 3,
																				),
																			),
																		],
																	),
																),
																VerticalDivider(
																	thickness: 1.5,
																	color: Colors.white,
																),
																Expanded(
																	child: Column(
																		crossAxisAlignment: CrossAxisAlignment.end,
																		mainAxisSize: MainAxisSize.max,
																		children: <Widget>[
																			Text(
																				'Current Balance',
																				style: TextStyle(
																					fontSize: 14,
																					fontWeight: FontWeight.normal,
																					color: Colors.white,
																				),
																			),
																			SizedBox(height: 8.0),
																			Text(
																				'${profile.insuree.insureePolicies[0].policy.value}',
																				style: TextStyle(
																					fontSize: 16,
																					fontWeight: FontWeight.bold,
																					color: Colors.white,
																				),
																			),
																			SizedBox(height: 4.0),
																			Divider(
																				indent: 20.0,
																				thickness: 1.5,
																				color: Colors.white,
																			),
																			SizedBox(height: 4.0),
																			Text(
																				'123',
																				style: TextStyle(
																					fontSize: 14,
																					fontWeight: FontWeight.normal,
																					color: Colors.white,
																				),
																			),
																			SizedBox(height: 8.0),
																			Text(
																				'${profile.insuree.healthFacility.name}',
																				style: TextStyle(
																					fontSize: 14,
																					fontWeight: FontWeight.normal,
																					color: Colors.white,
																				),
																			),
																		],
																	),
																),
															],
														);
													} else if (snapshot.hasError) {
														return Center(child: Text('Error loading data'));
													} else {
														return Center(child: CircularProgressIndicator());
													}
												},
											),
										),

										// CARD
										Container(
											height: 100,
											padding: EdgeInsets.all(8.0),
											margin: EdgeInsets.only(top: 165),
											child: Card(
												shape: RoundedRectangleBorder(
													borderRadius: BorderRadius.circular(20),
												),
												child: Padding(
													padding: EdgeInsets.only(left: 8, top: 2, bottom: 2, right: 8),
													child: Row(
														mainAxisAlignment: MainAxisAlignment.spaceEvenly,
														mainAxisSize: MainAxisSize.max,
														children: [
															Card(
																shape: RoundedRectangleBorder(
																	borderRadius: BorderRadius.circular(8),
																	side: BorderSide(color: CustomTheme.lightTheme.primaryColor),
																),
																child: Column(
																	children: [
																		Container(
																			decoration: BoxDecoration(
																				borderRadius: BorderRadius.only(
																					topRight: Radius.circular(8),
																					topLeft: Radius.circular(8),
																				),
																				color: CustomTheme.lightTheme.primaryColor,
																			),
																			padding: EdgeInsets.all(4),
																			child: Text(
																				'Expiry Date',
																				style: TextStyle(color: Colors.white),
																			),
																		),
																		SizedBox(height: 8.0),
																		Text('2021-10-19'),
																	],
																),
															),
															Card(
																shape: RoundedRectangleBorder(
																	borderRadius: BorderRadius.circular(8),
																	side: BorderSide(color: CustomTheme.lightTheme.primaryColor),
																),
																child: Column(
																	children: [
																		Container(
																			decoration: BoxDecoration(
																				borderRadius: BorderRadius.only(
																					topRight: Radius.circular(8),
																					topLeft: Radius.circular(8),
																				),
																				color: CustomTheme.lightTheme.primaryColor,
																			),
																			padding: EdgeInsets.all(4),
																			child: Text(
																				'Remaining',
																				style: TextStyle(color: Colors.white),
																			),
																		),
																		SizedBox(height: 8.0),
																		Text('125 days'),
																	],
																),
															),
														],
													),
												),
											),
										),
									],
								),
								Container(
									padding: EdgeInsets.only(left: 16.0, right: 16.0),
									child: Column(
										children: [
											ListTile(
												title: Text(
													AppTranslations.of(context).text("history"),
													style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
												),
												leading: Icon(Icons.history, color: CustomTheme.lightTheme.primaryColor, size: 30),
												trailing: GestureDetector(
													onTap: () {
														Navigator.pushNamed(context, '/user-history');
													},
													child: Text(
														AppTranslations.of(context).text('see_all'),
														style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
													),
												),
											),
											FutureBuilder<Claims>(
												// 4. Bind the claims future variable here
												future: _claimsFuture,
												builder: (context, snapshot) {
													if (snapshot.hasData) {
														return ListView.builder(
															shrinkWrap: true,
															scrollDirection: Axis.vertical,
															physics: NeverScrollableScrollPhysics(),
															itemCount: snapshot.data!.data.insureeProfile.insureeClaim.length,
															itemBuilder: (BuildContext context, int index) {
																var claims = snapshot.data!.data.insureeProfile.insureeClaim[index];
																return Card(
																	elevation: 0,
																	color: CustomTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
																	shape: RoundedRectangleBorder(
																		borderRadius: BorderRadius.circular(12),
																		side: BorderSide(
																			color: CustomTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
																			width: 1,
																		),
																	),
																	child: ListTile(
																		title: Text(
																			'${claims.healthFacility.name}',
																			style: TextStyle(fontWeight: FontWeight.w600),
																		),
																		subtitle: Text(
																			'${claims.dateClaimed.year}-${claims.dateClaimed.month.toString().padLeft(2, '0')}-${claims.dateClaimed.day.toString().padLeft(2, '0')}',
																			style: TextStyle(color: Colors.grey[700]),
																		),
																		trailing: Column(
																			mainAxisAlignment: MainAxisAlignment.center,
																			crossAxisAlignment: CrossAxisAlignment.end,
																			children: [
																				Text(
																					'${env.Currency} ${claims.claimed}',
																					style: TextStyle(fontWeight: FontWeight.bold),
																				),
																				Text(
																					_claimStatusString(claims.status),
																					style: TextStyle(
																						color: _claimStatusColor(claims.status),
																						fontSize: 12,
																						fontWeight: FontWeight.w500,
																					),
																				)
																			],
																		),
																		onTap: () {
																			Navigator.push(
																				context,
																				MaterialPageRoute(
																					builder: (context) => ClaimedItemServicesPage(
																						token: env.production ? auth.user['data']['insureeAuthOtp']['token'] : "123",
																						claimId: int.parse(claims.id),
																					),
																				),
																			);
																		},
																	),
																);
															},
														);
													} else if (snapshot.hasError) {
														return Center(child: Text('Error loading history'));
													} else {
														return Center(child: CircularProgressIndicator());
													}
												},
											),
										],
									),
								),
							],
						),
					),
					ExploreServicesPage(),
				],
			),
		);
	}
}