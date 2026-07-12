import 'package:flutter/material.dart';
import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:openimis_web_app/langlang/app_translation.dart';
import 'package:openimis_web_app/models/insuree_claims.dart';
import 'package:openimis_web_app/pages/claimed_item_services.dart';
import 'package:openimis_web_app/theme/custom_theme.dart';

class ClaimHistoryWidget extends StatelessWidget {
  final Future<Claims>? claimsFuture;
  final AuthBlock auth;

  const ClaimHistoryWidget({Key? key, required this.claimsFuture, required this.auth}) : super(key: key);

  Color _claimStatusColor(int status) {
    if (status == 2) return Colors.red;
    if (status == 4) return Colors.orange;
    if (status == 8) return Colors.blue;
    if (status == 16) return Colors.green;
    return Colors.black;
  }

  String _claimStatusString(int status) {
    if (status == 2) return "Unverifed";
    if (status == 4) return "Checked";
    if (status == 8) return "Reviewed";
    if (status == 16) return "Valuated";
    return "-";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              AppTranslations.of(context).text("history"),
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
            ),
            leading: GestureDetector(
              onTap: () {
                print("123");
              },
              child: Icon(Icons.history, color: CustomTheme.lightTheme.primaryColor, size: 30),
            ),
            trailing: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/user-history');
              },
              child: Text(
                AppTranslations.of(context).text('see_all'),
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
              ),
            )
          ),
          FutureBuilder<Claims>(
            future: claimsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final claimsList = snapshot.data!.data.insureeProfile.insureeClaim;
                if (claimsList.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("No claim history found."),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: claimsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    var claim = claimsList[index];
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
                          '${claim.healthFacility.name}',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${claim.dateClaimed.year}-${claim.dateClaimed.month.toString().padLeft(2, '0')}-${claim.dateClaimed.day.toString().padLeft(2, '0')}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${env.Currency} ${claim.claimed}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _claimStatusString(claim.status),
                              style: TextStyle(
                                color: _claimStatusColor(claim.status),
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
                                claimId: int.parse(claim.id)
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                );
              } else if (snapshot.hasError) {
                print("Claims error: ${snapshot.error}");
                return Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Failed to load claims: ${snapshot.error}"),
                );
              }
              return Center(child: CircularProgressIndicator());
            }
          )
        ],
      ),
    );
  }
}
