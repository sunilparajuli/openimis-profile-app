import 'package:flutter/material.dart';
import 'package:openimis_web_app/langlang/app_translation.dart';
import 'package:openimis_web_app/theme/colors.dart';

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
      return '  ${expiryDate.year}-${expiryDate.month.toString().padLeft(2, '0')}-${expiryDate.day.toString().padLeft(2, '0')} ';
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final policies = profile.insuree.insureePolicies;

    return Container(
      height: 120,
      padding: const EdgeInsets.all(8.0),
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.22),
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              // REMAINING DAYS CARD
              Container(
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: CustomColors.SuccessGreen.withValues(alpha: 0.2))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              topLeft: Radius.circular(8),
                            ),
                            color: CustomColors.SuccessGreen),
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          AppTranslations.of(context).text('remaining'),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        _calculateRemainingDays(policies),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 4.0),
                    ],
                  ),
                ),
              ),
              // EXPIRY ON CARD
              Container(
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: CustomColors.ExpiryOrange.withValues(alpha: 0.2))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              topLeft: Radius.circular(8),
                            ),
                            color: CustomColors.ExpiryOrange),
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          AppTranslations.of(context).text('expire_on'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        _getExpiresOn(policies),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 4.0),
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
