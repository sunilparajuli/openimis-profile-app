import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:openimis_web_app/models/insuree_claims.dart';
import 'package:openimis_web_app/services/api_graphql_services.dart';
import 'package:openimis_web_app/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:provider/provider.dart';

class UserHistoryPage extends StatefulWidget {
	@override
	_UserHistoryPageState createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage> {
// 	Future<Claims> _insureeclaims;
	late AuthBlock auth;
	
	@override
	void initState(){
		super.initState();
		// _insureeclaims = ApiGraphQlServices().ClaimsServicesGQL(auth.user['data']['insureeAuthOtp']['token']);
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
		auth = Provider.of<AuthBlock>(context);
		return Scaffold(
			backgroundColor: CustomTheme.lightTheme.primaryColor,
			appBar: AppBar(
				elevation: 0.0,
				title: Text(
					'History',
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
								padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
								child: FutureBuilder<Claims>(
									future: ApiGraphQlServices()
										.ClaimsServicesGQL(
										auth.user['data']['insureeAuthOtp']['token'],
										auth.user['data']['insureeAuthOtp']['insuree']['chfId'], true
									),
									builder: (context, snapshot){
										if(snapshot.hasData) {
											return ListView.builder(
												shrinkWrap: true,
												scrollDirection: Axis.vertical,
												itemCount: snapshot.data!.data.insureeProfile.insureeClaim.length,
												itemBuilder: (BuildContext context, int index){
													var claims = snapshot.data!.data.insureeProfile.insureeClaim[index];
													
													return _getHistoryWidgetCard(claims);
												}
											);
										}
										else{
											return Center(child: CircularProgressIndicator());
										}
									},
								),
							)
						)
					)
				],
			),
		);
	}
	
	Widget _getHistoryWidgetCard(claims){
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
					// Add navigation if needed, consistent with home/history
				},
			),
		);
	}
}

