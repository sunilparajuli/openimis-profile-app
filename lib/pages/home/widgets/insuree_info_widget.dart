import 'package:flutter/material.dart';
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:openimis_web_app/langlang/app_translation.dart';
import 'package:openimis_web_app/screen_size_reducers.dart';

class InsureeInfoWidget extends StatelessWidget {
  final dynamic profile;
  final double balance;

  const InsureeInfoWidget({Key? key, required this.profile, required this.balance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final insuree = profile.insuree;
    return Container(
      height: screenHeight(context, dividedBy: 3.5),
      padding: EdgeInsets.all(20),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: (profile.photo != null && profile.photo.toString().trim().isNotEmpty)
                        ? FadeInImage.assetNetwork(
                            image: profile.photo.replaceAll('192.168.15.22', 'imistest.hib.gov.np'),
                            placeholder: "assets/images/openimis-logo.png",
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            imageErrorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                "assets/images/openimis-logo.png",
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            "assets/images/openimis-logo.png",
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: Text(
                    '${insuree.otherNames} ${insuree.lastName}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                    maxLines: 3,
                  ),
                )
              ],
            ),
          ),
          VerticalDivider(
            thickness: 1.5,
            color: Colors.black,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(
                  AppTranslations.of(context).text('current_balance'),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 8.0),
                Text(
                  "${env.Currency} $balance",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 4.0),
                Divider(
                  indent: 20.0,
                  thickness: 1.5,
                  color: Colors.black,
                ),
                SizedBox(height: 8.0),
                Text(
                  AppTranslations.of(context).text('first_service_point'),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 8.0),
                Expanded(
                  child: Text(
                    '${insuree.healthFacility.name ?? "N/A"}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  )
                )
              ],
            ),
          ),
        ],
      )
    );
  }
}
