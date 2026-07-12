import 'dart:async';
import 'package:openimis_web_app/langlang/app_translation.dart';
import 'package:openimis_web_app/langlang/application.dart';
import 'package:openimis_web_app/models/ServiceProviders.dart';
import 'package:openimis_web_app/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:openimis_web_app/services/api_graphql_services.dart';

class ServiceProviderPage extends StatefulWidget {
	@override
	_ServiceProviderPageState createState() => _ServiceProviderPageState();
}

class _ServiceProviderPageState extends State<ServiceProviderPage> {
	late Future<dynamic> _serviceProvidersFuture;
	bool _isLoad = false;

	// 1. Added Search Controller and Query State
	TextEditingController _searchController = TextEditingController();
	String _searchQuery = "";

	@override
	void initState() {
		super.initState();
		application.onLocaleChanged = onLocaleChange;
	}

	@override
	void dispose() {
		_searchController.dispose();
		super.dispose();
	}

	void onLocaleChange(Locale locale) async {
		setState(() {
			AppTranslations.load(locale);
		});
	}

	@override
	Widget build(BuildContext context) {
		if (!_isLoad) {
			_serviceProvidersFuture = ApiGraphQlServices().service_providers();
			_isLoad = true;
		}

		return Scaffold(
			backgroundColor: CustomTheme.lightTheme.primaryColor,
			appBar: AppBar(
				elevation: 0.0,
				title: Text(
					AppTranslations.of(context).text('service_provider_list'),
					style: const TextStyle(color: Colors.white),
				),
				backgroundColor: CustomTheme.lightTheme.primaryColor,
			),
			body: Container(
				decoration: const BoxDecoration(
					color: Colors.white,
					borderRadius: BorderRadius.only(
							topLeft: Radius.circular(30),
							topRight: Radius.circular(30)),
				),
				child: Column(
					children: [
						// 2. The Search Bar UI
						Padding(
							padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
							child: TextField(
								controller: _searchController,
								decoration: InputDecoration(
									hintText: 'Search by Name or Code...',
									prefixIcon: const Icon(Icons.search),
									suffixIcon: _searchQuery.isNotEmpty
											? IconButton(
										icon: const Icon(Icons.clear),
										onPressed: () {
											_searchController.clear();
											setState(() {
												_searchQuery = "";
											});
										},
									)
											: null,
									filled: true,
									fillColor: Colors.grey[200],
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(12.0),
										borderSide: BorderSide.none,
									),
									contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
								),
								onChanged: (value) {
									setState(() {
										_searchQuery = value;
									});
								},
							),
						),

						// 3. The Scrollable List
						Expanded(
							child: _HealthFacilities(),
						),
					],
				),
			),
		);
	}

	Widget _HealthFacilities() {
		return FutureBuilder<dynamic>(
			future: _serviceProvidersFuture,
			builder: (context, snapshot) {
				if (snapshot.connectionState == ConnectionState.waiting) {
					return const Center(child: CircularProgressIndicator());
				} else if (snapshot.hasError) {
					return Center(child: Text('Error: ${snapshot.error}'));
				} else if (snapshot.hasData && snapshot.data?.data != null) {

					// Get the base list of edges
					var edges = snapshot.data!.data!.serviceProviders?.edges ?? [];

					// 4. Filter the edges based on the search query
					if (_searchQuery.isNotEmpty) {
						edges = edges.where((edge) {
							final name = (edge.node?.name ?? '').toLowerCase();
							final code = (edge.node?.code ?? '').toLowerCase();
							final query = _searchQuery.toLowerCase();

							return name.contains(query) || code.contains(query);
						}).toList();
					}

					if (edges.isEmpty) {
						return Center(
								child: Text(
									_searchQuery.isNotEmpty
											? 'No facilities match "$_searchQuery"'
											: 'No Health Facilities available',
									style: const TextStyle(fontSize: 16.0, color: Colors.grey),
								)
						);
					}

					return ListView.builder(
							padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
							itemCount: edges.length,
							itemBuilder: (BuildContext context, int index) {
								var node = edges[index].node;

								return Padding(
									padding: const EdgeInsets.only(bottom: 8.0),
									child: Card(
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(8.0),
										),
										elevation: 2,
										child: Padding(
											padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
											child: ListTile(
													contentPadding: EdgeInsets.zero,
													title: Text(
														node?.name ?? 'Unknown Facility',
														style: const TextStyle(
																fontSize: 16.0,
																fontWeight: FontWeight.bold),
													),
													// subtitle: Padding(
													// 	padding: const EdgeInsets.only(top: 8.0),
													// 	child: Text(
													// 		'Code: ${node?.code ?? 'N/A'}',
													// 		style: TextStyle(
													// 				fontSize: 14.0,
													// 				fontWeight: FontWeight.w500,
													// 				color: Colors.grey[700]
													// 		),
													// 	),
													// )
											),
										),
									),
								);
							}
					);
				} else {
					return const Center(child: Text('No data available'));
				}
			},
		);
	}
}