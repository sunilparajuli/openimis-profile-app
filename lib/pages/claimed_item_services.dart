import 'dart:async';
import 'package:openimis_web_app/models/claimeditems.dart';
import 'package:openimis_web_app/models/claimedservices.dart';
import 'package:openimis_web_app/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:openimis_web_app/services/api_graphql_services.dart';


class ClaimedItemServicesPage extends StatefulWidget {
    final int claimId;
    final String token;
    ClaimedItemServicesPage({Key? key, required this.claimId, required this.token}) : super(key: key);
    @override
    _ClaimedItemServicesPageState createState() =>
        _ClaimedItemServicesPageState();
}

class _ClaimedItemServicesPageState extends State<ClaimedItemServicesPage> {
    bool hasNotification = false;
    late Future<ClaimedServices> _claimedServices;
    late Future<ClaimedItems> _claimedItems;
    
    @override
    void initState() {
        // TODO: implement initState
        super.initState();
        _claimedServices = ApiGraphQlServices().ClaimedServicesServicesGQL(widget.token, widget.claimId);
        _claimedItems = ApiGraphQlServices().ClaimedItemServicesGQL(widget.token, widget.claimId);
    }
    
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: CustomTheme.lightTheme.primaryColor,
            appBar: AppBar(
                elevation: 0.0,
                title: Text(
                    'Claimed Item Services',
                    style: TextStyle(color: Colors.white),
                ),
                backgroundColor: CustomTheme.lightTheme.primaryColor,
            ),
            body: Column(
                children: [
                    Expanded(
                        child: Container(
//                            height: screenHeight(context, dividedBy: 1),
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30)),
                            ),
                            child: SingleChildScrollView(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                    Container(
                                        padding: EdgeInsets.only(left:8.0, top: 16.0, bottom: 8.0),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey
                                                        .withValues(alpha: 0.25)))),
                                        width: double.infinity,
                                        child: Text(
                                            'Items',
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold
                                            ),
                                        ),
                                    ),
                                    SizedBox(height: 8.0),
                                    _claimItemListWidget(),
                                    Container(
                                        padding: EdgeInsets.only(left:8.0, top: 16.0, bottom: 8.0),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey
                                                        .withValues(alpha: 0.25)))),
                                        width: double.infinity,
                                        child: Text(
                                            'Services',
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold
                                            ),
                                        ),
                                    ),
                                    SizedBox(height: 8.0),
                                    _claimServicesListWidget(),
                                ],
                            ),
                            ),
                        ),
                    ),
                ],
            )
        );
    }
    
    Widget _claimItemListWidget(){
        return Container(
            child: FutureBuilder<ClaimedItems>(
                future: _claimedItems,
                builder: (context, snapshot) {
                    if (snapshot.hasData) {
                        if (snapshot.data!.data.insureeClaim.isEmpty || snapshot.data!.data.insureeClaim[0].items.isEmpty) {
                            return Center(child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("No items claimed"),
                            ));
                        }
                        return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.data
                                .insureeClaim[0].items.length,
                            itemBuilder: (BuildContext context,
                                int index) {
                                var item = snapshot
                                    .data
                                    !.data
                                    .insureeClaim[0]
                                    .items[index];
                                return Container(
                                    child: ListTile(
                                        title: Text(
                                            '${item.item.name}',
                                            style: TextStyle(
                                                fontSize: 14.4,
                                                fontWeight: FontWeight.normal
                                            ),
                                        ),
                                        subtitle: Text(
                                            'Quantity: ${item.qtyProvided}',
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.grey[700]
                                            ),
                                        ),
                                        trailing: Text(
                                            '${env.Currency} ' + '${item.item.price.toString()}',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: CustomTheme.lightTheme.primaryColor
                                            ),
                                        ),
                                    ),
                                );
                            });
                    } else if (snapshot.hasError) {
                        return Center(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Error: ${snapshot.error}"),
                            ),
                        );
                    } else {
                        return Center(
                            child: CircularProgressIndicator());
                    }
                }),
        );
    }
    
    Widget _claimServicesListWidget(){
        return Container(
            // height: screenHeight(context, dividedBy: 2),
            child: FutureBuilder<ClaimedServices>(
                future: _claimedServices,
                builder: (context, snapshot) {
                    if (snapshot.hasData) {
                        if (snapshot.data!.data.insureeClaim.isEmpty || snapshot.data!.data.insureeClaim[0].services.isEmpty) {
                            return Center(child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("No services claimed"),
                            ));
                        }
                        return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot
                                .data!.data.insureeClaim[0].services.length,
                            itemBuilder: (BuildContext context, int index) {
                                var service = snapshot
                                    .data!.data.insureeClaim[0].services[index];
                                return Container(
                                    child: ListTile(
                                        title: Text(
                                            '${service.service.name}',
                                            style: TextStyle(
                                                fontSize: 14.4,
                                                fontWeight: FontWeight.normal
                                            ),
                                        ),
                                        subtitle: Text(
                                            'Quantity/Days: ${service.qtyProvided}',
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.grey[700]
                                            ),
                                        ),
                                        trailing: Text(
                                            '${env.Currency} ' + '${service.service.price.toString()}',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: CustomTheme.lightTheme.primaryColor
                                            ),
                                        ),
                                    ),
                                );
                            });
                    } else if (snapshot.hasError) {
                        return Center(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Error: ${snapshot.error}"),
                            ),
                        );
                    } else {
                        return Center(
                            child: CircularProgressIndicator()
                        );
                    }
                }),
        );
    }
}
