import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:openimis_web_app/models/notifications.dart';
import 'package:openimis_web_app/services/api_graphql_services.dart';
import 'package:openimis_web_app/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  NotificationPage({Key key}) : super(key: key);
  @override
  _NotificationPageState createState() => _NotificationPageState();
}


class _NotificationPageState extends State<NotificationPage> {
  bool hasNotification = false;
//   Future<Notifications> _notifications;
	AuthBlock auth;
  @override
  Widget build(BuildContext context) {
		auth = Provider.of<AuthBlock>(context);
	  return Scaffold(
		  backgroundColor: CustomTheme.lightTheme.primaryColor,
		  appBar: AppBar(
			  elevation: 0.0,
			  title: Text(
				  'Notifications',
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
					child: FutureBuilder<Notifications>(
									future: ApiGraphQlServices().NotificationsServicesGQL(
											auth.user['data']['insureeAuthOtp']['token'],
											auth.user['data']['insureeAuthOtp']['insuree']['chfId']
									),
									builder: (context, snapshot) {
										if(snapshot.hasData && snapshot.data.data!=null) {
											return ListView.builder(
													shrinkWrap: true,
													scrollDirection: Axis.vertical,
													physics: NeverScrollableScrollPhysics(),
													itemCount: snapshot.data.data.notifications.edges.length,
													itemBuilder: (BuildContext context, int index){
														var _notifications = snapshot.data.data.notifications.edges[index];
														var date = "${_notifications.node.createdAt.year}-${_notifications.node.createdAt.month}-${_notifications.node.createdAt.day}";
														/*return ListTile(
															title: Text('${_notifications.node.message}'),
															subtitle: Text('${date}'),
															onTap: () {
															},
														);*/
														
														return Container(
															padding: EdgeInsets.all(12.0),
															child: Card(
																shape: RoundedRectangleBorder(
																	borderRadius: BorderRadius.circular(0.0),
																),
																elevation: 5,
																shadowColor: CustomTheme.lightTheme.primaryColor,
																child: Container(
																	padding: EdgeInsets.only(left: 4.0),
																	child: Column(
																		crossAxisAlignment: CrossAxisAlignment.start,
																		mainAxisSize: MainAxisSize.max,
																		children: [
																			ListTile(
																				title: Text(
																					'${_notifications.node.message}',
																					style: TextStyle(
																						fontSize: 16.0,
																						fontWeight: FontWeight.normal
																					),
																				),
																				
																				subtitle: Padding(
																					padding: EdgeInsets.only(top: 8.0),
																					child: Text(
																						'${date}',
																						style: TextStyle(
																							fontSize: 14.0,
																							fontWeight: FontWeight.w400,
																						),
																					),
																				)
																			),
																		],
																	),
																),
															)
														);
													}
											);
										}
										else{
											return Center(child: CircularProgressIndicator());
										}
									}
							)
					  )
				  )
			  ],
		  ),
	  );
  }

}
