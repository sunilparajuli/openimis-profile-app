import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';


import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;


class CustomLatLng {
  final double latitude;
  final double longitude;

  CustomLatLng(this.latitude, this.longitude);
}

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late CustomLatLng _currentLocation;
  late CustomLatLng _selectedRestaurant;
  List<Map<String, dynamic>> _places = [
    {'name': 'Patan Hospital', 'coords': CustomLatLng(27.7236, 85.4181)},
    {'name': 'Birat Hospital', 'coords': CustomLatLng(27.6684, 85.4621)},
    // Add more predefined places as needed
  ];
  List<LatLng> _routeCoordinates = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _generateAdditionalPlaces(); // Generate additional places
  }

  Future<void> _getCurrentLocation() async {
    // Simulated current location for demonstration
    setState(() {
      _currentLocation = CustomLatLng(27.7172, 85.3240);
    });
  }

  Future<void> _fetchRoute(CustomLatLng start, CustomLatLng end) async {
    final apiKey = '5b3ce3597851110001cf62484f0e87eea58b4acba647b590aa38a34c';
    final apiUrl =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.latitude},${start.longitude}&end=${end.latitude},${end.longitude}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates =
        List.from(data['features'][0]['geometry']['coordinates']);

        setState(() {
          _routeCoordinates = coordinates
              .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
              .toList();
        });
      } else {
        throw Exception('Failed to load route data');
      }
    } catch (e) {
      // Show Snackbar with error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch route data. Please try again later.'),
        ),
      );
    }
  }

  void _onPlaceSelected(CustomLatLng place) {
    setState(() {
      _selectedRestaurant = place;
      _fetchRoute(_currentLocation, place);
    });
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // Add marker for current location
    if (true) {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(_currentLocation.latitude, _currentLocation.longitude),
          child: Icon(
            Icons.my_location,
            size: 40,
            color: Colors.blue,
          ),
        ),
      );
    }

    // Add markers for predefined places
    markers.addAll(
      _places.map((place) => Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(place['coords'].latitude, place['coords'].longitude),
        child: GestureDetector(
          onTap: () => _onPlaceSelected(place['coords']),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_pin,
                size: 30.0,
                color: _selectedRestaurant == place['coords']
                    ? Colors.red
                    : Colors.blue,
              ),
              Text(
                place['name'],
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      )),
    );

    return markers;
  }

  List<Polyline> _buildPolylines() {
    List<Polyline> polylines = [];

    if (_routeCoordinates.isNotEmpty) {
      polylines.add(
        Polyline(
          points: _routeCoordinates,
          color: Colors.black,
          strokeWidth: 5,
        ),
      );
    }

    return polylines;
  }



  void _generateAdditionalPlaces() {
    final List<Map<String, dynamic>> additionalPlaces = generateNearbyPlaces(_places, 30);
    setState(() {
      _places.addAll(additionalPlaces);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map View'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(_currentLocation.latitude, _currentLocation.longitude),
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          MarkerLayer(
            markers: _buildMarkers(),
          ),
          PolylineLayer(
            polylines: _buildPolylines(),
          ),
        ],
      ),
    );
  }
}

List<Map<String, dynamic>> generateNearbyPlaces(
    List<Map<String, dynamic>> places, int count) {
  final Random random = Random();
  final List<Map<String, dynamic>> generatedPlaces = [];

  for (int i = 0; i < count; i++) {
    final Map<String, dynamic> existingPlace =
    places[random.nextInt(places.length)];
    final double lat = existingPlace['coords'].latitude;
    final double lng = existingPlace['coords'].longitude;

    final double latOffset = (random.nextDouble() - 0.5) / 100;
    final double lngOffset = (random.nextDouble() - 0.5) / 100;

    final double newLat = lat + latOffset;
    final double newLng = lng + lngOffset;

    final Map<String, dynamic> newPlace = {
      'name': 'Near ${existingPlace['name']}',
      'coords': CustomLatLng(newLat, newLng)
    };

    generatedPlaces.add(newPlace);
  }

  return generatedPlaces;
}
