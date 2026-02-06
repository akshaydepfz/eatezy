import 'dart:async';
import 'dart:convert';
import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/chat/chat_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class OSMTrackingScreen extends StatefulWidget {
  final double lat;
  final double long;
  final bool isOrder;
  final String vendorName;
  final String vendorImage;
  final String vendorPhone;
  final String chatId;
  final String vendorId;
  final String orderID;
  final String vendorToken;
  final String customerImage;
  final String customerName;
  final String orderStatus;

  const OSMTrackingScreen({
    super.key,
    required this.lat,
    required this.long,
    required this.isOrder,
    required this.vendorName,
    required this.vendorImage,
    required this.vendorPhone,
    required this.chatId,
    required this.vendorId,
    required this.orderID,
    required this.vendorToken,
    required this.customerImage,
    required this.customerName,
    required this.orderStatus,
  });

  @override
  State<OSMTrackingScreen> createState() => _OSMTrackingScreenState();
}

class _OSMTrackingScreenState extends State<OSMTrackingScreen> {
  LatLng? currentLocation;

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
            widget.lat,
            widget.long,
          ) /
          1000;
    });

    await _getRoute(start, LatLng(widget.lat, widget.long));

    // Center map to show both locations
    if (mounted) {
      _centerMapOnBothLocations();
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position pos) async {
      if (mounted) {
        LatLng newLoc = LatLng(pos.latitude, pos.longitude);
        setState(() {
          currentLocation = newLoc;
          distance = Geolocator.distanceBetween(
                pos.latitude,
                pos.longitude,
                widget.lat,
                widget.long,
              ) /
              1000;
        });
        mapController.move(newLoc, mapController.camera.zoom);
        await _getRoute(newLoc, LatLng(widget.lat, widget.long));
      }
    });
  }

  Future<void> _getRoute(LatLng start, LatLng end) async {
    try {
      // Use HTTPS for OSRM API
      final url =
          'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Route request timed out');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null &&
            data['routes'].isNotEmpty &&
            data['routes'][0]['geometry'] != null) {
          final coords = data['routes'][0]['geometry']['coordinates'];

          if (mounted) {
            setState(() {
              routePoints = coords
                  .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
                  .toList();
            });
          }
        }
      } else {
        // If route API fails, just show markers without route
        if (mounted) {
          setState(() {
            routePoints = [];
          });
        }
      }
    } catch (e) {
      // If route calculation fails, continue without route line
      if (mounted) {
        setState(() {
          routePoints = [];
        });
      }
      // Silently fail - map will still work without route
    }
  }

  void _centerMapOnBothLocations() {
    if (currentLocation == null) return;

    final start = currentLocation!;
    final end = LatLng(widget.lat, widget.long);

    // Calculate center point
    final centerLat = (start.latitude + end.latitude) / 2;
    final centerLng = (start.longitude + end.longitude) / 2;

    // Calculate distance to determine zoom level
    final distance = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );

    // Adjust zoom based on distance
    double zoom = 16;
    if (distance > 10000) {
      zoom = 12;
    } else if (distance > 5000) {
      zoom = 13;
    } else if (distance > 2000) {
      zoom = 14;
    } else if (distance > 1000) {
      zoom = 15;
    }

    mapController.move(LatLng(centerLat, centerLng), zoom);
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : SizedBox.expand(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: currentLocation!,
                  initialZoom: 16,
                  minZoom: 5,
                  maxZoom: 18,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.eatezy.app',
                    tileProvider: NetworkTileProvider(
                      headers: {
                        'User-Agent': 'EatezyApp/1.0 (contact@eatezy.com)',
                        'Referer': 'https://eatezy.com',
                      },
                    ),
                    maxZoom: 19,
                  ),
                  if (routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,
                          color: AppColor.primary,
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: currentLocation!,
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.my_location,
                          size: 40,
                          color: AppColor.primary,
                        ),
                      ),
                      Marker(
                        point: LatLng(widget.lat, widget.long),
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.location_on,
                          size: 40,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      bottomSheet: widget.isOrder
          ? Container(
              decoration: BoxDecoration(color: AppColor.primary),
              padding: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * .20,
              child: Column(
                mainAxisSize: MainAxisSize.min, // ✅ Fix for unbounded height
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                              height: 60,
                              width: 60,
                              child: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(widget.vendorImage),
                              )),
                          AppSpacing.w10,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .5,
                                child: Text(
                                  widget.vendorName,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                              Text(
                                "+91 ${widget.vendorPhone}",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              if (distance != null)
                                Text(
                                  "Distance: ${distance!.toStringAsFixed(2)} km",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          launchUrl(Uri.parse('tel:+91${widget.vendorPhone}'));
                        },
                        child: CircleAvatar(
                          child: Icon(Icons.call),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatViewScreen(
                                        customerImage: widget.customerImage,
                                        customerName: widget.customerName,
                                        vendorToken: widget.vendorToken,
                                        orderId: widget.orderID,
                                        chatId: widget.chatId,
                                        vendorId: widget.vendorId,
                                      )));
                        },
                        child: CircleAvatar(
                          child: Icon(Icons.chat),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.h15,
                  Container(
                    padding: EdgeInsets.all(10),
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order Status:'),
                        Text(widget.orderStatus),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
