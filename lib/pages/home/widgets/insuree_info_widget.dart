import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:openimis_web_app/langlang/app_translation.dart';
import 'package:openimis_web_app/screen_size_reducers.dart';
import 'package:openimis_web_app/helper/shared_preferences_helper.dart';

class InsureeInfoWidget extends StatelessWidget {
  final dynamic profile;
  final double balance;

  const InsureeInfoWidget({Key? key, required this.profile, required this.balance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final insuree = profile.insuree;
    return Container(
      height: screenHeight(context, dividedBy: 3.5),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: FutureBuilder<String?>(
                      future: SessionManager().getBase64Image(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                          // --- SHOW LOCAL BASE64 PHOTO ---
                          return Image.memory(
                            base64Decode(snapshot.data!),
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          );
                        }
                        
                        // --- FALLBACK TO NETWORK PHOTO ---
                        if (profile.photo != null && profile.photo.toString().trim().isNotEmpty) {
                          return FadeInImage.assetNetwork(
                            image: profile.photo.replaceAll('192.168.15.22', 'imistest.hib.gov.np'),
                            placeholder: "assets/images/hib-logo.png",
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            imageErrorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                "assets/images/hib-logo.png",
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              );
                            },
                          );
                        }
                        
                        return Image.asset(
                          "assets/images/hib-logo.png",
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${insuree.otherNames} ${insuree.lastName}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                )
              ],
            ),
          ),
          const VerticalDivider(
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
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 8.0),
                Text(
                  "${env.Currency} $balance",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 4.0),
                const Divider(
                  indent: 20.0,
                  thickness: 1.5,
                  color: Colors.black,
                ),
                const SizedBox(height: 8.0),
                Text(
                  AppTranslations.of(context).text('first_service_point'),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: Text(
                    '${insuree.healthFacility.name ?? "N/A"}',
                    style: const TextStyle(
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
