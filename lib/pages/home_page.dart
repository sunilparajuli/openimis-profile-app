import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:openimis_web_app/helper/shared_preferences_helper.dart' as helper;
import 'package:openimis_web_app/langlang/application.dart';
import 'package:openimis_web_app/models/insuree_claims.dart';
import 'package:openimis_web_app/models/insuree_info.dart';
import 'package:openimis_web_app/hooks/home_page_hooks.dart';
import 'package:openimis_web_app/theme/custom_theme.dart';

import 'home/widgets/insuree_info_widget.dart';
import 'home/widgets/insuree_card_widget.dart';
import 'home/widgets/claim_history_widget.dart';

class Homepage extends StatefulWidget {
	@override
	_HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
	late AuthBlock _auth;
	double _balance = 0.0;
	
	bool _canRefresh = false;
	bool _canRefreshInsureeData = false;

	Future<InsureeData>? _insureeDataFuture;
	Future<Claims>? _claimsFuture;

	@override
	void initState() {
		super.initState();
		application.onLocaleChanged = (locale) => setState(() {});
		
		_initRefreshStates();
		
		if (!env.production) {
			_balance = 123456.00;
		}
	}

	void _initRefreshStates() async {
		final claimsRefresh = await HomePageHooks.canRefreshClaims();
		final insureeRefresh = await HomePageHooks.canRefreshInsureeData();
		if (mounted) {
			setState(() {
				_canRefresh = claimsRefresh;
				_canRefreshInsureeData = insureeRefresh;
			});
		}
	}

	@override
	void didChangeDependencies() {
		super.didChangeDependencies();
		_auth = Provider.of<AuthBlock>(context);
		
		if (_auth.user.containsKey('data')) {
			if (_insureeDataFuture == null) {
				_insureeDataFuture = HomePageHooks.fetchInsureeData(_auth, _canRefreshInsureeData);
				if (env.production) {
					_fetchBalance();
				}
			}
			_claimsFuture ??= HomePageHooks.fetchClaimsData(_auth, _canRefresh);
		}
	}

	Future<void> _fetchBalance() async {
		final balance = await HomePageHooks.fetchBalance(_auth);
		if (mounted && balance != null) {
			setState(() {
				_balance = balance;
			});
		}
	}

	Future<void> _handleRefresh() async {
		await helper.SessionManager().setRefreshApi(true);
		await _fetchBalance();
		setState(() {
			_canRefresh = true;
			_canRefreshInsureeData = true;
			_insureeDataFuture = HomePageHooks.fetchInsureeData(_auth, true);
			_claimsFuture = HomePageHooks.fetchClaimsData(_auth, true);
		});
	}

	@override
	Widget build(BuildContext context) {
		if (!_auth.user.containsKey('data')) {
			return const Scaffold(
				body: Center(child: CircularProgressIndicator()),
			);
		}

		return Scaffold(
			backgroundColor: CustomTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
			body: SingleChildScrollView(
				child: Column(
					children: [
						_buildProfileSection(),
						_buildMapShortcut(),
						ClaimHistoryWidget(claimsFuture: _claimsFuture, auth: _auth),
					],
				),
			),
			floatingActionButton: FloatingActionButton(
				onPressed: _handleRefresh,
				backgroundColor: Colors.white,
				child: Icon(Icons.refresh, color: CustomTheme.lightTheme.primaryColor)
			),
		);
	}

	Widget _buildProfileSection() {
		return FutureBuilder<InsureeData>(
			future: _insureeDataFuture,
			builder: (context, snapshot) {
				if (snapshot.hasData) {
					final profile = snapshot.data!.data.profile;
					
					// Update SharedPreferences in background
					final prefs = helper.SessionManager();
					prefs.setFullname("${profile.insuree.otherNames} ${profile.insuree.lastName}");
					prefs.setImage(profile.photo ?? "");

					return Stack(
						children: [
							InsureeInfoWidget(profile: profile, balance: _balance),
							InsureeCardWidget(profile: profile),
						],
					);
				} else if (snapshot.hasError) {
					return Padding(
						padding: const EdgeInsets.all(20),
						child: Text("Failed to load profile data: ${snapshot.error}"),
					);
				}
				return const Center(
					child: Padding(
						padding: EdgeInsets.all(20.0),
						child: CircularProgressIndicator(),
					)
				);
			}
		);
	}

	Widget _buildMapShortcut() {
		return Container(
			margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
			child: Card(
				elevation: 0,
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(15),
					side: BorderSide(color: CustomTheme.lightTheme.primaryColor.withValues(alpha: 0.1)),
				),
				child: InkWell(
					onTap: () => Navigator.pushNamed(context, '/map-services'),
					borderRadius: BorderRadius.circular(15),
					child: Padding(
						padding: const EdgeInsets.all(16.0),
						child: Row(
							children: [
								Container(
									padding: const EdgeInsets.all(10),
									decoration: BoxDecoration(
										color: CustomTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
										shape: BoxShape.circle,
									),
									child: Icon(Icons.map_outlined, color: CustomTheme.lightTheme.primaryColor, size: 28),
								),
								const SizedBox(width: 16),
								Expanded(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											const Text(
												"Nearest Health Facilities",
												style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
											),
											Text(
												"Find hospitals and clinics near you",
												style: TextStyle(fontSize: 12, color: Colors.grey[600]),
											),
										],
									),
								),
								Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
							],
						),
					),
				),
			),
		);
	}
}
