import 'package:flutter/material.dart';
import 'package:openimis_web_app/langlang/app_translation.dart';
import 'package:openimis_web_app/theme/custom_theme.dart';

class InsureeCardWidget extends StatelessWidget {
  final dynamic profile;

  const InsureeCardWidget({Key? key, required this.profile}) : super(key: key);

  String _calculateRemainingDays(List? insureePolicies) {
    if (insureePolicies == null || insureePolicies.isEmpty) return "No policy";
    
    try {
      var lastPolicy = insureePolicies.last;
      DateTime expiryDate = lastPolicy.policy.expiryDate;
      DateTime dateTimeNow = DateTime.now();
      final differenceInDays = dateTimeNow.difference(expiryDate).inDays;
      if (differenceInDays > 0) {
        return "Expired";
      }
      return differenceInDays.abs().toString();
    } catch (_) {
      return "No policy";
    }
  }

  String _getExpiresOn(List? insureePolicies) {
    if (insureePolicies != null && insureePolicies.isNotEmpty) {
      var lastPolicy = insureePolicies.last;
      DateTime expiryDate = lastPolicy.policy.expiryDate;
      return '  ${expiryDate.year}-${expiryDate.month}-${expiryDate.day} ';
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final policies = profile.insuree.insureePolicies;

    return Container(
      height: 120,
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.22),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      side: BorderSide(color: CustomTheme.lightTheme.primaryColor)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              topLeft: Radius.circular(8),
                            ),
                            color: CustomTheme.lightTheme.primaryColor),
                        padding: EdgeInsets.all(4),
                        child: Text(
                          AppTranslations.of(context).text('remaining'),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        _calculateRemainingDays(policies),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                      side: BorderSide(color: CustomTheme.lightTheme.primaryColor)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              topLeft: Radius.circular(8),
                            ),
                            color: CustomTheme.lightTheme.primaryColor),
                        padding: EdgeInsets.all(4),
                        child: Text(
                          AppTranslations.of(context).text('expire_on'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        _getExpiresOn(policies),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4.0),
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
}
