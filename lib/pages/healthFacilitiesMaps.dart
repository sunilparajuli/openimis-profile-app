import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
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
  Position? _userPosition;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    await _loadProviderData();
    await _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userPosition = position;
        });
      }
    } catch (e) {
      print("Location Error: $e");
    }
  }

  Future<void> _loadProviderData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(milliseconds: 500));
    _providers.addAll([
      ServiceProviderNode(id: "1", name: "Patan Hospital", code: "KTM-PH", latitude: 27.6684, longitude: 85.3201),
      ServiceProviderNode(id: "2", name: "Bir Hospital", code: "H99999", latitude: 27.7061, longitude: 85.3148),
      ServiceProviderNode(id: "3", name: "Teaching Hospital", code: "TUTH", latitude: 27.7351, longitude: 85.3301),
      ServiceProviderNode(id: "4", name: "Civil Service Hospital", code: "CH04", latitude: 27.6841, longitude: 85.3401),
      ServiceProviderNode(id: "5", name: "B&B Hospital", code: "BB05", latitude: 27.6661, longitude: 85.3341),
      ServiceProviderNode(id: "6", name: "Ilam District Hospital", code: "H0301547", latitude: 26.9110, longitude: 87.9230),
      ServiceProviderNode(id: "7", name: "Bheri Hospital", code: "H5700351", latitude: 28.0500, longitude: 81.6166),
      ServiceProviderNode(id: "8", name: "Seti Provincial Hospital", code: "H7101796", latitude: 28.6833, longitude: 80.6000),
      ServiceProviderNode(id: "9", name: "Bharatpur Hospital", code: "CHI-BH", latitude: 27.6833, longitude: 84.4333),
      ServiceProviderNode(id: "10", name: "Lumbini Provincial Hospital", code: "L.P.H", latitude: 27.7000, longitude: 83.4500),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _drawRouteToNearest() async {
    if (_userPosition == null) {
      await _determinePosition();
      if (_userPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not get your location.")));
        return;
      }
    }

    ServiceProviderNode? nearest;
    double minDistance = double.infinity;

    for (var provider in _providers) {
      if (provider.latitude != null && provider.longitude != null) {
        double distance = Geolocator.distanceBetween(
          _userPosition!.latitude, _userPosition!.longitude,
          provider.latitude!, provider.longitude!
        );
        if (distance < minDistance) {
          minDistance = distance;
          nearest = provider;
        }
      }
    }

    if (nearest != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Drawing route to ${nearest.name}...")));
      
      // Fetch route from OSRM (Open Source Routing Machine) - Free service
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${_userPosition!.longitude},${_userPosition!.latitude};'
          '${nearest.longitude},${nearest.latitude}?overview=full&geometries=geojson';

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List coords = data['routes'][0]['geometry']['coordinates'];
          
          setState(() {
            _routePoints = coords.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList();
          });

          _mapController.move(LatLng(nearest.latitude!, nearest.longitude!), 14.0);
          _showProviderDetails(nearest);
        }
      } catch (e) {
        print("Routing error: $e");
        // Fallback: just show the line directly if API fails
        setState(() {
          _routePoints = [
            LatLng(_userPosition!.latitude, _userPosition!.longitude),
            LatLng(nearest?.latitude ?? 0.0, nearest?.longitude ?? 0.0),
          ];
        });
      }
    }
  }

  void _showProviderDetails(ServiceProviderNode provider) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(provider.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CustomTheme.lightTheme.primaryColor)),
            SizedBox(height: 10),
            Row(children: [Icon(Icons.code, size: 18, color: Colors.grey), SizedBox(width: 8), Text("Code: ${provider.code}", style: TextStyle(fontSize: 16))]),
            SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: CustomTheme.lightTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text("Close", style: TextStyle(color: Colors.white)),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Facility Map'),
        backgroundColor: CustomTheme.lightTheme.primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(27.7172, 85.3240),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'np.gov.hib.hibprofile',
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(points: _routePoints, strokeWidth: 4, color: Colors.blue.shade700),
                    ],
                  ),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 45,
                    size: Size(40, 40),
                    alignment: Alignment.center,
                    markers: [
                      if (_userPosition != null)
                        Marker(
                          width: 40, height: 40,
                          point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
                          child: Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                        ),
                      ..._providers.map((provider) => Marker(
                        width: 120.0, height: 80.0,
                        point: LatLng(provider.latitude!, provider.longitude!),
                        child: GestureDetector(
                          onTap: () => _showProviderDetails(provider),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(4), border: Border.all(color: CustomTheme.lightTheme.primaryColor, width: 0.5)),
                                child: Text(provider.name, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                              Icon(Icons.local_hospital, size: 32.0, color: CustomTheme.lightTheme.primaryColor),
                            ],
                          ),
                        ),
                      )).toList(),
                    ],
                    builder: (context, markers) => Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: CustomTheme.lightTheme.primaryColor),
                      child: Center(child: Text(markers.length.toString(), style: TextStyle(color: Colors.white))),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton.icon(
            onPressed: _drawRouteToNearest,
            icon: Icon(Icons.directions, color: Colors.white),
            label: Text("Draw Route to Nearest Provider", style: TextStyle(color: Colors.white, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomTheme.lightTheme.primaryColor,
              minimumSize: Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}
