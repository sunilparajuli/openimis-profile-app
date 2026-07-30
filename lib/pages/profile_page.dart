import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:openimis_web_app/langlang/app_translation.dart';
import 'package:openimis_web_app/langlang/application.dart';
import 'package:openimis_web_app/models/insuree_info.dart';
import 'package:openimis_web_app/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:provider/provider.dart';
import 'package:openimis_web_app/services/api_graphql_services.dart';

import 'package:openimis_web_app/helper/shared_preferences_helper.dart' as helper;

class ProfileInfo extends StatefulWidget {
	@override
	_ProfileInfoState createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
	// 1. Changed from 'late File _image;' to 'File? _image;' to fix LateInitializationError
	File? _image;
	final picker = ImagePicker();

	TextEditingController phoneController = TextEditingController();
	TextEditingController emailController = TextEditingController();

	bool isLoading = false;
	late AuthBlock auth;
	String _cachedImageUrl = "";

	@override
	void initState() {
		super.initState();
		application.onLocaleChanged = onLocaleChange;
		_loadCachedData();
	}

	void _loadCachedData() async {
		String img = await helper.SessionManager().getImage();
		if (mounted) {
			setState(() {
				_cachedImageUrl = img;
			});
		}
	}

	void onLocaleChange(Locale locale) async {
		setState(() {
			AppTranslations.load(locale);
		});
	}

	Future<void> uploadProfile() async {
		setState(() {
			isLoading = !isLoading;
		});

		// 2. SAFE AUTH CHECK for token and chfId
		String token = "";
		String chfId = "";
		try {
			if (auth.user.containsKey('data')) {
				token = auth.user['data']['insureeAuthOtp']['token'] ?? "";
				chfId = auth.user['data']['insureeAuthOtp']['insuree']['chfId'].toString();
			}
		} catch (e) {
			print("Auth user data unavailable: $e");
		}

		String url = env.API_BASE_URL;
		var request = new http.MultipartRequest("POST", Uri.parse(url));

		// Ensure Token and App-Version are sent
		request.headers.addAll({
			"Insuree-Token": token,
			"App-Version": env.APP_VERSION,
		});

		// 3. Safely check if image is picked before uploading
		if (_image != null) {
			request.files.add(new http.MultipartFile.fromBytes(
					'file',
					await File.fromUri(Uri.parse(_image!.path)).readAsBytes(),
					filename: "profile_image.jpg"));
		}

		request.fields['query'] =
		'mutation {updateProfile(file: "file", email:"${emailController.text}", phone: "${phoneController.text}", insureeCHFID:"$chfId"){   ok  }  }';

		request.send().then((response) {
			response.stream.bytesToString().then((value) {
				print(value); // Print the response body
				if (response.statusCode == 200) {
					if (response.reasonPhrase == "OK") {
						// SnackBar()
					} else {
						// Handle other cases
					}
					setState(() {
						isLoading = !isLoading;
						//_scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Profile Picture Uploaded')));
					});
				} else {
					// Handle non-200 status code
					setState(() {
						isLoading = false;
					});
				}
			}).catchError((error) {
				print("Error reading response: $error");
				setState(() {
					isLoading = false;
				});
			});
		}).catchError((error) {
			print("Error sending request: $error");
			setState(() {
				isLoading = false;
			});
		});
	}

	Widget _imageCardWidget() {
		// 4. Safe check before drawing the image file
		if (_image == null) {
			return SizedBox.shrink();
		}
		return Container(
			width: 100.0,
			height: 100.0,
			decoration: BoxDecoration(
				shape: BoxShape.circle,
				image: DecorationImage(
					image: FileImage(_image!),
					fit: BoxFit.cover,
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		auth = Provider.of<AuthBlock>(context);

		// 5. SAFE AUTH CHECKS for the GraphQL query during hot reload
		String token = env.debugToken;
		String chfId = env.debugChfId;
		try {
			if (auth.user.containsKey('data')) {
				token = auth.user['data']['insureeAuthOtp']['token'] ?? env.debugToken;
				chfId = auth.user['data']['insureeAuthOtp']['insuree']['chfId'].toString();
			}
		} catch (e) {
			print("Auth state missing, using fallbacks");
		}

		return Scaffold(
			backgroundColor: Color.fromRGBO(41, 127, 141, 25), //mainColor,
			appBar: AppBar(
				elevation: 0.0,
				title: Text(
					AppTranslations.of(context).text('page_title_profile'),
					style: TextStyle(color: Colors.black), // Explicitly set text color to white
				),
				backgroundColor: Color.fromRGBO(41, 127, 141, 0), // Your transparent color
				iconTheme: IconThemeData(
					color: Colors.black, // This forces the back arrow to be white
				),
			),
			body: isLoading
					? Center(
				child: CircularProgressIndicator(),
			)
					: Column(
				children: <Widget>[
					Expanded(
						child: Container(
							decoration: BoxDecoration(
									color: Colors.white,
									borderRadius: BorderRadius.only(
											topLeft: Radius.circular(30),
											topRight: Radius.circular(30))),
							child: Padding(
								padding: const EdgeInsets.only(
										left: 12.0, right: 12.0, top: 10.0),
								child: FutureBuilder<InsureeData>(
									// Using safely extracted auth variables here
									future: ApiGraphQlServices().InsureeInfoServicesGQL(
											token, chfId, true),
									builder: (context, snapshot) {
										String displayImageUrl = _cachedImageUrl;
										if (snapshot.hasData && snapshot.data!.data.profile.photo != null) {
											displayImageUrl = snapshot.data!.data.profile.photo!;
											// Update cache if new data arrives
											helper.SessionManager().setImage(displayImageUrl);
										}

										return ListView(
											children: [
												SizedBox(height: 20.0),
												// PROFILE IMAGE
												Center(
													child: SizedBox(
														height: 100,
														width: 100,
														child: Stack(
															children: <Widget>[
																Ink(
																	decoration: BoxDecoration(
																		shape: BoxShape.circle,
																		color: Colors.grey[200],
																	),
																	child: CachedNetworkImage(
																			imageUrl: displayImageUrl.replaceAll('192.168.15.22', 'imistest.hib.gov.np'),
																			imageBuilder: (context, imageProvider) => Container(
																				width: 100.0,
																				height: 100.0,
																				decoration: BoxDecoration(
																					shape: BoxShape.circle,
																					image: DecorationImage(
																							image: imageProvider,
																							fit: BoxFit.cover),
																				),
																			),
																			placeholder: (context, url) =>
																			new CircularProgressIndicator(),
																			errorWidget: (context, url, error) =>
																					Icon(Icons.person, size: 50, color: CustomTheme.lightTheme.primaryColor),
																			fit: BoxFit.cover),
																),
																_imageCardWidget(),
															],
														),
													),
												),

												if (snapshot.hasData) ...[
													// FULL NAME
													SizedBox(height: 16.0),
													_buildFullnameWidget(
															snapshot.data!.data.profile.insuree.otherNames,
															snapshot.data!.data.profile.insuree.lastName),

													// DATE OF BIRTH
													SizedBox(height: 16.0),
													_buildDOBWidget(
															snapshot.data!.data.profile.insuree.dob),

													// ADDRESS
													SizedBox(height: 16.0),
													_buildAddressWidget(
															snapshot.data!.data.profile.insuree.currentAddress),

													// PHONE NUMBER
													SizedBox(height: 16.0),
													_buildPhoneWidget(
															snapshot.data!.data.profile.phone),

													// EMAIL
													SizedBox(height: 16.0),
													_buildEmailWidget(
															snapshot.data!.data.profile.email),
												] else ...[
													SizedBox(height: 50),
													Center(child: CircularProgressIndicator()),
												],

												// SUBMIT BUTTON
												SizedBox(height: 16.0),
												//_buildSubmitButton()
											],
										);
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
						// Trigger rebuild to refresh data
					});
				},
				backgroundColor: Colors.white,
				child: Icon(Icons.refresh, color: CustomTheme.lightTheme.primaryColor),
			),
		);
	}

	Widget _buildFullnameWidget(String firstName, String lastName) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: 10.0),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisSize: MainAxisSize.min,
				children: <Widget>[
					Text(
						AppTranslations.of(context).text('full_name'),
						style: TextStyle(
								fontSize: 16,
								fontWeight: FontWeight.w400,
								fontFamily: "Open-sans",
								color: Colors.grey),
					),
					SizedBox(height: 8.0),
					TextFormField(
						keyboardType: TextInputType.text,
						readOnly: true,
						decoration: InputDecoration(
							border: OutlineInputBorder(
									borderRadius: BorderRadius.all(Radius.circular(10.0)),
									borderSide: BorderSide.none,
							),
							fillColor: Colors.grey[100],
							filled: true,
							contentPadding: EdgeInsets.all(16.0),
							prefixIcon: Icon(Icons.person_outline, color: CustomTheme.lightTheme.primaryColor),
							hintText: '${firstName} ${lastName}',
							hintStyle: TextStyle(fontFamily: 'Open-sans', color: Colors.black87),
						),
					),
				],
			),
		);
	}

	Widget _buildDOBWidget(DateTime dob) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: 10.0),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisSize: MainAxisSize.min,
				children: <Widget>[
					Text(
						AppTranslations.of(context).text('date_of_birth'),
						style: TextStyle(
								fontSize: 16,
								fontWeight: FontWeight.w400,
								fontFamily: "Open-sans",
								color: Colors.grey),
					),
					SizedBox(height: 8.0),
					TextFormField(
						keyboardType: TextInputType.text,
						readOnly: true,
						decoration: InputDecoration(
							border: OutlineInputBorder(
									borderRadius: BorderRadius.all(Radius.circular(10.0)),
									borderSide: BorderSide.none,
							),
							fillColor: Colors.grey[100],
							filled: true,
							contentPadding: EdgeInsets.all(16.0),
							prefixIcon: Icon(Icons.calendar_today, color: CustomTheme.lightTheme.primaryColor),
							hintText: '${dob.year}-${dob.month}-${dob.day}',
							hintStyle: TextStyle(fontFamily: 'Open-sans', color: Colors.black87),
						),
					),
				],
			),
		);
	}

	Widget _buildAddressWidget(String? currentAddress) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: 10.0),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisSize: MainAxisSize.min,
				children: <Widget>[
					Text(
						AppTranslations.of(context).text('address'),
						style: TextStyle(
								fontSize: 16,
								fontWeight: FontWeight.w400,
								fontFamily: "Open-sans",
								color: Colors.grey),
					),
					SizedBox(height: 8.0),
					TextFormField(
						keyboardType: TextInputType.text,
						readOnly: true,
						decoration: InputDecoration(
							border: OutlineInputBorder(
									borderRadius: BorderRadius.all(Radius.circular(10.0)),
									borderSide: BorderSide.none,
							),
							fillColor: Colors.grey[100],
							filled: true,
							contentPadding: EdgeInsets.all(16.0),
							prefixIcon: Icon(Icons.location_on, color: CustomTheme.lightTheme.primaryColor),
							hintText: '${currentAddress ?? "Not Available"}',
							hintStyle: TextStyle(fontFamily: 'Open-sans', color: Colors.black87),
						),
					),
				],
			),
		);
	}

	Widget _buildPhoneWidget(String phoneNumber) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: 10.0),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisSize: MainAxisSize.min,
				children: <Widget>[
					Text(
						AppTranslations.of(context).text('mobile_number'),
						style: TextStyle(
								fontSize: 16,
								fontWeight: FontWeight.w400,
								fontFamily: "Open-sans",
								color: Colors.grey),
					),
					SizedBox(height: 8.0),
					TextFormField(
						readOnly: true,
						controller: phoneController,
						keyboardType: TextInputType.number,
						decoration: InputDecoration(
							border: OutlineInputBorder(
									borderRadius: BorderRadius.all(Radius.circular(10.0)),
									borderSide: BorderSide.none,
							),
							fillColor: Colors.grey[100],
							filled: true,
							contentPadding: EdgeInsets.all(16.0),
							prefixIcon: Icon(Icons.phone, color: CustomTheme.lightTheme.primaryColor),
							hintText: '${phoneNumber}',
							hintStyle: TextStyle(fontFamily: 'Open-sans', color: Colors.black87),
						),
					),
				],
			),
		);
	}

	Widget _buildEmailWidget(String? email) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: 10.0),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisSize: MainAxisSize.min,
				children: <Widget>[
					Text(
						AppTranslations.of(context).text('email_address'),
						style: TextStyle(
								fontSize: 16,
								fontWeight: FontWeight.w400,
								fontFamily: "Open-sans",
								color: Colors.grey),
					),
					SizedBox(height: 8.0),
					TextFormField(
						readOnly: true,
						controller: emailController,
						keyboardType: TextInputType.emailAddress,
						decoration: InputDecoration(
							border: OutlineInputBorder(
									borderRadius: BorderRadius.all(Radius.circular(10.0)),
									borderSide: BorderSide.none,
							),
							fillColor: Colors.grey[100],
							filled: true,
							contentPadding: EdgeInsets.all(16.0),
							prefixIcon: Icon(Icons.alternate_email, color: CustomTheme.lightTheme.primaryColor),
							hintText: '${email ?? "Not Available"}',
							hintStyle: TextStyle(fontFamily: 'Open-sans', color: Colors.black87),
						),
					),
				],
			),
		);
	}


}