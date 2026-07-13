import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:openimis_web_app/models/insuree_policy_information.dart';
import 'package:openimis_web_app/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:openimis_web_app/services/api_graphql_services.dart';
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:provider/provider.dart';
import 'package:openimis_web_app/helper/shared_preferences_helper.dart' as helper;

class PolicyInformationPage extends StatefulWidget {
  @override
  _PolicyInformationPageState createState() => _PolicyInformationPageState();
}

class _PolicyInformationPageState extends State<PolicyInformationPage> {
  late AuthBlock auth;
  bool canRefresh = false;
  bool _showHistory = false;

  @override
  void initState() {
    get_info();
    super.initState();
  }

  get_info() async {
    helper.SessionManager().getInfoStatus().then((value) {
      if (value == false) {
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
      backgroundColor: CustomTheme.lightTheme.primaryColor,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: CustomTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: FutureBuilder<InsureePolicyInformation>(
                  future: ApiGraphQlServices().InsureePolicyInformationServicesGQL(
                      auth.user['data']['insureeAuthOtp']['token'],
                      auth.user['data']['insureeAuthOtp']['insuree']['chfId'],
                      canRefresh),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData && snapshot.data!.data.insureeProfile.insureePolicies.isNotEmpty) {
                        var policies = snapshot.data!.data.insureeProfile.insureePoliciesSorted();
                        var firstPolicy = policies.first;
                        var remainingPolicies = policies.length > 1 ? policies.sublist(1) : [];

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildIDCardWidget(firstPolicy),
                              
                              if (remainingPolicies.isNotEmpty) ...[
                                SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _showHistory = !_showHistory;
                                      });
                                    },
                                    icon: Icon(_showHistory ? Icons.expand_less : Icons.history, color: Colors.white),
                                    label: Text(
                                      _showHistory ? "Hide History" : "View Policy History",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: CustomTheme.lightTheme.primaryColor,
                                      minimumSize: Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                if (_showHistory)
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: remainingPolicies.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return _policyInformationListWidget(remainingPolicies[index]);
                                    },
                                  ),
                                SizedBox(height: 20),
                              ]
                            ],
                          ),
                        );
                      } else {
                        return Center(
                            child: Text(
                                "NO POLICY AVAILABLE WITH ASSOCIATED HEALTH FACILITY"));
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              canRefresh = true;
            });
          },
          backgroundColor: Colors.white,
          child: Icon(Icons.refresh, color: CustomTheme.lightTheme.primaryColor)),
    );
  }

  Widget _buildIDCardWidget(dynamic _data) {
    String expiryString = "${_data.policy.expiryDate.year}-${_data.policy.expiryDate.month.toString().padLeft(2, '0')}-${_data.policy.expiryDate.day.toString().padLeft(2, '0')}";
    bool isActive = dateCheckActiveInactive(expiryString);
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CustomTheme.lightTheme.primaryColor,
            CustomTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: CustomTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "HEALTH INSURANCE POLICY",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? "ACTIVE" : "EXPIRED",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          
          Divider(color: Colors.white24, height: 1),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn("POLICY VALUE", "${env.Currency} ${_data.policy.value.toInt()}"),
                    _buildInfoColumn("STATUS", _data.policy.stage.toUpperCase()),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn("ENROLL DATE", _data.policy.enrollDate != null ? "${_data.policy.enrollDate.year}-${_data.policy.enrollDate.month.toString().padLeft(2, '0')}-${_data.policy.enrollDate.day.toString().padLeft(2, '0')}" : "N/A"),
                    if (_data.policy.startDate != null)
                      _buildInfoColumn("ACTIVE DATE", "${_data.policy.startDate.year}-${_data.policy.startDate.month.toString().padLeft(2, '0')}-${_data.policy.startDate.day.toString().padLeft(2, '0')}"),
                    _buildInfoColumn("EXPIRY DATE", expiryString, isExpiry: true),
                  ],
                ),
              ],
            ),
          ),
          
          // Bottom Accent
          Container(
            height: 15,
            decoration: BoxDecoration(
              color: CustomTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {bool isExpiry = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isExpiry && !dateCheckActiveInactive(value) ? Colors.orangeAccent : Colors.white, 
            fontSize: 15, 
            fontWeight: FontWeight.bold
          ),
        ),
      ],
    );
  }

  bool dateCheckActiveInactive(String date) {
    var now = DateTime.now();
    var isPolicyExpire = DateTime.parse(date);
    if (now.difference(isPolicyExpire).inDays > 0) {
      return false;
    }
    return true;
  }

  Widget _policyInformationListWidget(dynamic _data) {
    // Determine active status once
    String expiryString = "${_data.policy.expiryDate.year}-${_data.policy.expiryDate.month.toString().padLeft(2, '0')}-${_data.policy.expiryDate.day.toString().padLeft(2, '0')}";
    bool isActive = dateCheckActiveInactive(expiryString);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        children: [
          // SINGLE LINE TOP SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _data.policy.product != null ? '${_data.policy.product.name}' : "Unknown",
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${env.Currency} ${_data.policy.value.toInt()}',
                    style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 4),
                _buildCompactBadge(isActive ? 'Active' : 'Expired', isActive ? Colors.green : Colors.red),
                SizedBox(width: 4),
                _buildCompactBadge(_data.policy.stage.isNotEmpty ? _data.policy.stage : "N/A", Colors.blue),
              ],
            ),
          ),

          // IMPROVED DATE PANEL: Bigger, Full Dates
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.06),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.0),
                bottomRight: Radius.circular(12.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (_data.policy.enrollDate != null)
                  _buildFullDateColumn('Enroll date', _data.policy.enrollDate),
                if (_data.policy.startDate != null)
                  _buildFullDateColumn('Active date', _data.policy.startDate),
                _buildFullDateColumn('Expiry date', _data.policy.expiryDate, isExpiry: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBadge(String text, MaterialColor color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
          text.toUpperCase(),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color.shade700)
      ),
    );
  }

  // Helper for larger, full-date panels
  Widget _buildFullDateColumn(String label, dynamic dateObj, {bool isExpiry = false}) {
    String formattedDate = '${dateObj.year}-${dateObj.month.toString().padLeft(2, '0')}-${dateObj.day.toString().padLeft(2, '0')}';
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        Text(
          formattedDate,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isExpiry ? Colors.red.shade700 : Colors.black87),
        ),
      ],
    );
  }

  // Helper widget to build the vertical label/date pairs cleanly
  Widget _buildDateColumn(String label, dynamic dateObj, {bool isExpiry = false}) {
    String formattedDate = '${dateObj.year}-${dateObj.month.toString().padLeft(2, '0')}-${dateObj.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500
          ),
        ),
        SizedBox(height: 4.0),
        Text(
          formattedDate,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            color: isExpiry ? Colors.red.shade700 : Colors.black87,
          ),
        ),
      ],
    );
  }
}

