import 'package:openimis_web_app/models/claimeditems.dart';
import 'package:openimis_web_app/models/claimedservices.dart';
import 'package:openimis_web_app/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:openimis_web_app/services/api_graphql_services.dart';


class ClaimedItemServicesPage extends StatefulWidget {
    final int claimid;
    final String token;
    ClaimedItemServicesPage({Key key, this.claimid, this.token}) : super(key: key);
    @override
    _ClaimedItemServicesPageState createState() =>
        _ClaimedItemServicesPageState();
}

class _ClaimedItemServicesPageState extends State<ClaimedItemServicesPage> {
    bool hasNotification = false;
    Future<ClaimedServices> _claimedservices;
    Future<ClaimedItems> _claimeditems;
    
    @override
    void initState() {
        // TODO: implement initState
        super.initState();
        _claimedservices = ApiGraphQlServices().ClaimedServicesServicesGQL(widget.token,widget.claimid);
        _claimeditems = ApiGraphQlServices().ClaimedItemServicesGQL(widget.token,widget.claimid);
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
                                                        .withOpacity(0.25)))),
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
                                                        .withOpacity(0.25)))),
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
                future: _claimeditems,
                builder: (context, snapshot) {
                    if (snapshot.hasData) {
                        return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data.data
                                .insureeClaim[0].items.length,
                            itemBuilder: (BuildContext context,
                                int index) {
                                var claimeditems = snapshot
                                    .data
                                    .data
                                    .insureeClaim[0]
                                    .items[index];
                                return Container(
                                    child: ListTile(
                                        title: Text(
                                            '${claimeditems.item.name}',
                                            style: TextStyle(
                                                fontSize: 14.4,
                                                fontWeight: FontWeight.normal
                                            ),
                                        ),
                                        subtitle: Text(
                                            'Quantity: ${claimeditems.qtyProvided ?? 0}',
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.grey[700]
                                            ),
                                        ),
                                        trailing: Text(
                                            '${env.Currency} ' + '${claimeditems.item.price.toString()}',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: CustomTheme.lightTheme.primaryColor
                                            ),
                                        ),
                                    ),
                                );
                            });
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
                future: _claimedservices,
                builder: (context, snapshot) {
                    if (snapshot.hasData) {
                        return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot
                                .data.data.insureeClaim[0].services.length,
                            itemBuilder: (BuildContext context, int index) {
                                var claimedservices = snapshot
                                    .data.data.insureeClaim[0].services[index];
                                return Container(
                                    child: ListTile(
                                        title: Text(
                                            '${claimedservices.service.name}',
                                            style: TextStyle(
                                                fontSize: 14.4,
                                                fontWeight: FontWeight.normal
                                            ),
                                        ),
                                        subtitle: Text(
                                            'Quantity/Days: ${claimedservices.qtyProvided ?? 0}',
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.grey[700]
                                            ),
                                        ),
                                        trailing: Text(
                                            '${env.Currency} ' + '${claimedservices.service.price.toString()}',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: CustomTheme.lightTheme.primaryColor
                                            ),
                                        ),
                                    ),
                                );
                            });
                    } else {
                        return Center(
                            child: CircularProgressIndicator()
                        );
                    }
                }),
        );
    }
}
