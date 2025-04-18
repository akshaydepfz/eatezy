import 'dart:async';
import 'dart:convert';
import 'package:eatezy/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class OSMTrackingScreen extends StatefulWidget {
  const OSMTrackingScreen({super.key});

  @override
  State<OSMTrackingScreen> createState() => _OSMTrackingScreenState();
}

class _OSMTrackingScreenState extends State<OSMTrackingScreen> {
  LatLng? currentLocation;
  LatLng destination = LatLng(11.2537, 75.7764); // Bangalore
  double? distance;
  final mapController = MapController();
  StreamSubscription<Position>? _positionStream;
  List<LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();
    _initLocationTracking();
  }

  Future<void> _initLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied")),
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    LatLng start = LatLng(position.latitude, position.longitude);

    setState(() {
      currentLocation = start;
      distance = Geolocator.distanceBetween(
            start.latitude,
            start.longitude,
            destination.latitude,
            destination.longitude,
          ) /
          1000;
    });

    await _getRoute(start, destination);

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    ).listen((Position pos) async {
      LatLng newLoc = LatLng(pos.latitude, pos.longitude);
      setState(() {
        currentLocation = newLoc;
        distance = Geolocator.distanceBetween(
              pos.latitude,
              pos.longitude,
              destination.latitude,
              destination.longitude,
            ) /
            1000;
      });
      mapController.move(newLoc, 16);
      await _getRoute(newLoc, destination);
    });
  }

  Future<void> _getRoute(LatLng start, LatLng end) async {
    final url =
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coords = data['routes'][0]['geometry']['coordinates'];

      setState(() {
        routePoints =
            coords.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList();
      });
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: currentLocation!,
                    initialZoom: 16,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: 'com.example.app',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,
                          color: Colors.blue,
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: currentLocation!,
                          child: const Icon(Icons.place,
                              size: 40, color: AppColor.primary),
                        ),
                        Marker(
                          point: destination,
                          child: const Icon(Icons.place,
                              size: 40, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
      bottomSheet: Container(
        padding: EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * .20,
        child: Column(
          children: [
            if (distance != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Distance: ${distance!.toStringAsFixed(2)} km",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
