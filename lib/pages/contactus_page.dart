import 'package:openimis_web_app/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:openimis_web_app/services/api_graphql_services.dart';
import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:provider/provider.dart';
import 'package:openimis_web_app/common/env.dart' as env;

import '../models/app_contacts.dart';
import '../screen_size_reducers.dart';

class ContactUsPage extends StatefulWidget {
	@override
	_ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
	late AuthBlock auth;

	@override
	Widget build(BuildContext context) {
		auth = Provider.of<AuthBlock>(context);

		return Scaffold(
			backgroundColor: CustomTheme.lightTheme.primaryColor,
			appBar: AppBar(
				elevation: 0.0,
				title: Text(
					'Contact Us',
					style: TextStyle(color: Colors.white),
				),
				backgroundColor: CustomTheme.lightTheme.primaryColor,
			),
			body: FutureBuilder<AppContactsModel>(
				future: ApiGraphQlServices().AppContactsServicesGQL(),
				builder: (context, snapshot) {
					if (snapshot.hasData) {
						var provinceContacts = snapshot.data!.data.appContacts.provinceContacts;
						var districtContacts = snapshot.data!.data.appContacts.districtContacts;

						return Column(
							children: [
								Expanded(
									child: Container(
										decoration: BoxDecoration(
												color: Colors.white,
												borderRadius: BorderRadius.only(
														topLeft: Radius.circular(30),
														topRight: Radius.circular(30))),
										child: DefaultTabController(
											length: 2,
											child: Container(
												padding: EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
												child: Column(
													children: <Widget>[
														TabBar(
															indicatorColor: CustomTheme.lightTheme.colorScheme.secondary,
															indicatorWeight: 2,
															tabs: [
																Tab(
																	child: Text(
																		'Province Contact',
																		style: TextStyle(
																				fontSize: 14,
																				fontWeight: FontWeight.w400,
																				color: Colors.black),
																	),
																),
																Tab(
																	child: Text(
																		'District Contact',
																		style: TextStyle(
																				fontSize: 14,
																				fontWeight: FontWeight.w400,
																				color: Colors.black),
																	),
																),
															],
														),
														Container(
															height: screenHeight(context, dividedBy: 1.26),
															padding: EdgeInsets.only(top: 8.0),
															child: TabBarView(
																children: [
																	_buildContactList(provinceContacts),
																	_buildContactList(districtContacts),
																],
															),
														)
													],
												),
											),
										),
									),
								),
							],
						);
					} else if (snapshot.hasError) {
						return Center(child: Text("Failed to load contacts", style: TextStyle(color: Colors.white)));
					} else {
						return Center(child: CircularProgressIndicator(color: Colors.white));
					}
				},
			),
		);
	}

	Widget _buildContactList(List<ContactDetail> contacts) {
		if (contacts.isEmpty) {
			return Center(
				child: Text("No contacts available."),
			);
		}

		return ListView.builder(
			itemCount: contacts.length,
			itemBuilder: (BuildContext context, int index) {
				var contact = contacts[index];
				return Container(
					padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
					child: Card(
						shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(0.0),
						),
						elevation: 5,
						shadowColor: CustomTheme.lightTheme.primaryColor,
						child: Container(
							padding: EdgeInsets.fromLTRB(24, 16, 16, 16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								mainAxisSize: MainAxisSize.max,
								children: [
									Text(
										contact.branch,
										style: TextStyle(
											fontSize: 16.0,
											letterSpacing: 0.5,
											fontWeight: FontWeight.bold,
										),
									),
									SizedBox(height: 4.0),
									Text(
										contact.address,
										style: TextStyle(
											fontSize: 14.0,
											fontWeight: FontWeight.normal,
										),
									),
									SizedBox(height: 4.0),
									Text(
										contact.email,
										style: TextStyle(
											fontSize: 14.0,
											fontWeight: FontWeight.normal,
										),
									),
									SizedBox(height: 4.0),
									Text(
										contact.phone,
										style: TextStyle(
											fontSize: 14.0,
											fontWeight: FontWeight.normal,
										),
									),
								],
							),
						),
					),
				);
			},
		);
	}
}