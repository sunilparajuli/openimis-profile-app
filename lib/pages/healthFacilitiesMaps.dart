import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:openimis_web_app/models/ServiceProviders.dart';
import 'package:openimis_web_app/theme/custom_theme.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final List<ServiceProviderNode> _providers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProviderData();
  }

  // This will be replaced by the actual data provided by the user
  Future<void> _loadProviderData() async {
    setState(() {
      _isLoading = true;
    });

    // Mock data for now based on user's previous example and Nepal coordinates
    await Future.delayed(Duration(seconds: 1));
    _providers.addAll([
      ServiceProviderNode(id: "1", name: "Patan Hospital", code: "PH01", latitude: 27.6684, longitude: 85.3201),
      ServiceProviderNode(id: "2", name: "Bir Hospital", code: "BH02", latitude: 27.7061, longitude: 85.3148),
      ServiceProviderNode(id: "3", name: "Teaching Hospital", code: "TH03", latitude: 27.7351, longitude: 85.3301),
      ServiceProviderNode(id: "4", name: "Civil Service Hospital", code: "CH04", latitude: 27.6841, longitude: 85.3401),
      ServiceProviderNode(id: "5", name: "B&B Hospital", code: "BB05", latitude: 27.6661, longitude: 85.3341),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  void _showProviderDetails(ServiceProviderNode provider) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CustomTheme.lightTheme.primaryColor),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.code, size: 18, color: Colors.grey),
                  SizedBox(width: 8),
                  Text("Code: ${provider.code}", style: TextStyle(fontSize: 16)),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on, size: 18, color: Colors.grey),
                  SizedBox(width: 8),
                  Text("Lat: ${provider.latitude}, Lng: ${provider.longitude}", style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomTheme.lightTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text("Close", style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Providers Map'),
        backgroundColor: CustomTheme.lightTheme.primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(27.7172, 85.3240), // Kathmandu center
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'np.gov.hib.hibprofile',
                ),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 45,
                    size: Size(40, 40),
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(50),
                    markers: _providers.map((provider) {
                      return Marker(
                        width: 40.0,
                        height: 40.0,
                        point: LatLng(provider.latitude!, provider.longitude!),
                        child: GestureDetector(
                          onTap: () => _showProviderDetails(provider),
                          child: Icon(
                            Icons.location_on,
                            size: 40.0,
                            color: CustomTheme.lightTheme.primaryColor,
                          ),
                        ),
                      );
                    }).toList(),
                    builder: (context, markers) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: CustomTheme.lightTheme.primaryColor,
                        ),
                        child: Center(
                          child: Text(
                            markers.length.toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
