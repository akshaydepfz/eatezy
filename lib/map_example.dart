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

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    ).listen((Position pos) async {
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
      mapController.move(newLoc, 16);
      await _getRoute(newLoc, LatLng(widget.lat, widget.long));
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
                          point: LatLng(widget.lat, widget.long),
                          child: const Icon(Icons.place,
                              size: 40, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
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
                              Text(
                                widget.vendorName,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
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
                      CircleAvatar(
                        child: Icon(Icons.call),
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
                ],
              ),
            )
          : null,
    );
  }
}
