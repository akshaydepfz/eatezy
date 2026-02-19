import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

/// Reverse geocoding that works on all platforms including web.
/// On mobile: uses geocoding package. On web: uses Nominatim (OpenStreetMap) API.
Future<List<Placemark>> placemarkFromCoordinatesWebSafe(
  double latitude,
  double longitude,
) async {
  if (!kIsWeb) {
    return placemarkFromCoordinates(latitude, longitude);
  }

  // Web: use Nominatim (free, no API key required)
  try {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude',
    );
    final response = await http.get(
      uri,
      headers: {'User-Agent': 'EatezyApp/1.0'},
    );

    if (response.statusCode != 200) {
      return [];
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final address = data['address'] as Map<String, dynamic>? ?? {};
    final displayName = data['display_name'] as String? ?? '';

    final place = Placemark(
      name: address['name'] as String? ?? '',
      street: address['road'] as String? ?? address['footway'] as String? ?? '',
      locality: address['suburb'] as String? ??
          address['village'] as String? ??
          address['town'] as String? ??
          address['city'] as String? ??
          address['municipality'] as String?,
      subLocality: address['neighbourhood'] as String?,
      administrativeArea: address['state'] as String? ?? address['county'] as String?,
      subAdministrativeArea: address['county'] as String?,
      postalCode: address['postcode']?.toString(),
      country: address['country'] as String?,
      isoCountryCode: address['country_code'] as String?,
      subThoroughfare: null,
      thoroughfare: address['road'] as String?,
    );

    // If place is mostly empty, use display_name as fallback
    final hasContent = place.street?.isNotEmpty == true ||
        place.locality?.isNotEmpty == true ||
        place.country?.isNotEmpty == true;
    if (!hasContent && displayName.isNotEmpty) {
      return [
        Placemark(
          name: displayName,
          street: displayName,
          locality: displayName,
          country: null,
          subLocality: null,
          administrativeArea: null,
          subAdministrativeArea: null,
          postalCode: null,
          isoCountryCode: null,
          subThoroughfare: null,
          thoroughfare: null,
        ),
      ];
    }

    return [place];
  } catch (_) {
    return [];
  }
}

/// Forward geocoding (address to coordinates) that works on web.
/// On mobile: uses geocoding package. On web: uses Nominatim.
Future<List<Location>> locationFromAddressWebSafe(String address) async {
  if (!kIsWeb) {
    return locationFromAddress(address);
  }

  try {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(address)}&limit=5',
    );
    final response = await http.get(
      uri,
      headers: {'User-Agent': 'EatezyApp/1.0'},
    );

    if (response.statusCode != 200) {
      return [];
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      final lat = m['lat'] is num ? (m['lat'] as num).toDouble() : double.parse(m['lat'] as String);
      final lon = m['lon'] is num ? (m['lon'] as num).toDouble() : double.parse(m['lon'] as String);
      return Location(
        latitude: lat,
        longitude: lon,
        timestamp: DateTime.now(),
      );
    }).toList();
  } catch (_) {
    return [];
  }
}
