import 'dart:convert';

import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:openimis_web_app/models/insuree_policy_information.dart';
import 'package:openimis_web_app/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:openimis_web_app/services/api_graphql_services.dart';
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:provider/provider.dart';
import 'package:openimis_web_app/helper/shared_preferences_helper.dart'
    as helper;

class PolicyInformationPage extends StatefulWidget {
  @override
  _PolicyInformationPageState createState() => _PolicyInformationPageState();
}

class _PolicyInformationPageState extends State<PolicyInformationPage> {
  Future<InsureePolicyInformation> _insureepolicyinformation;
  AuthBlock auth;

  @override
  void initState() {
    // TODO: implement initState
    get_info();
    super.initState();
  }

  bool canRefresh = false;
  get_info() async {
    helper.SessionManager().getInfoStatus().then((value){
      if(value==false){
        setState(() {
          canRefresh = true;
        });

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthBlock>(context);

    return Scaffold(
      backgroundColor:
          CustomTheme.lightTheme.primaryColor, //Color.fromRGBO(41,127,141, 25)

      body: Column(
        children: <Widget>[

          Expanded(
              child: Container(
            decoration: BoxDecoration(
                color: CustomTheme.lightTheme.backgroundColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: FutureBuilder<InsureePolicyInformation>(
                  future: ApiGraphQlServices()
                      .InsureePolicyInformationServicesGQL(
                          auth.user['data']['insureeAuthOtp']['token'],
                          auth.user['data']['insureeAuthOtp']['insuree']
                              ['chfId'], canRefresh),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData && snapshot.data.data != null) {
                        return ListView.builder(
                            itemCount: snapshot.data.data.insureeProfile
                                .insureePolicies.length,
                            itemBuilder: (BuildContext context, int index) {
//																var _data = snapshot.data.data.insureeProfile.insureePolicies[index];
                              var _data = snapshot.data.data.insureeProfile
                                  .insureePoliciesSorted()[index];
                              return _policyInformationListWidget(_data);
                            });
                      } else {
                        return Center(
                            child: Text(
                                "NO POLICY AVAILABLE WITH ASSOCIATED HEALTH FACILITY"));
                      }
                    } else {
                      ;
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),

            ),
          ))
        ],
      ),
      floatingActionButton : FloatingActionButton(onPressed: (){
        setState(() {
          canRefresh = true;
        });
      },
          child: Icon(Icons.refresh)),
    );
  }

  bool dateCheckActiveInactive(date) {
    var now = new DateTime.now();
    var isPolicyExpire = DateTime.parse(date);
    if (now.difference(isPolicyExpire).inDays > 0) {
      return false;
    }
    return true;
  }

  Widget _policyInformationListWidget(_data) {
    return Container(
      margin: EdgeInsets.only(left: 8.0, right: 8.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.5),
            width: 1.0,
          ),
        ),
      ),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
//							_data.insuree.healthFacility!=null ?
//							'${_data.insuree.healthFacility.name}' : Text(""),
              _data.policy.product != null
                  ? '${_data.policy.product.name}'
                  : Text(""),
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
//				leading: Text(
//					_data.insuree.healthFacility.code !=null ?
//					'${_data.insuree.healthFacility.code}': Text(""),
//                    style: TextStyle(
//                        fontSize: 14.0,
//                        fontWeight: FontWeight.w400,
//                    ),
//                ),
        subtitle: Text(
          'Expiry date: ${_data.policy.expiryDate.year}-${_data.policy.expiryDate.month}-${_data.policy.expiryDate.day}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${env.Currency} ${_data.policy.value}',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),

            dateCheckActiveInactive(
                        "${_data.policy.expiryDate.year}-${_data.policy.expiryDate.month.toString().length != 2 ? '0${_data.policy.expiryDate.month}' : _data.policy.expiryDate.month}-${_data.policy.expiryDate.day}") !=
                    false
                ? Text(
                    'Active',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  )
                : Text(
                    'Expired',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),


          ],

        ),


      ),

    );
  }
}
