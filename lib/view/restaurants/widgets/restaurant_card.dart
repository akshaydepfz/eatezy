import 'package:eatezy/model/vendor_model.dart';
import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

const double kRestaurantCardRadius = 16;

/// Computes distance from user's current location to restaurant.
String _computeDistance(HomeProvider homeProvider, VendorModel vendor) {
  final userLat = homeProvider.latitude;
  final userLng = homeProvider.longitude;
  if (userLat == null || userLng == null) return vendor.estimateDistance;

  final vendorLat = double.tryParse(vendor.lat);
  final vendorLng = double.tryParse(vendor.long);
  if (vendorLat == null || vendorLng == null) return vendor.estimateDistance;

  final distanceInMeters = Geolocator.distanceBetween(
    userLat,
    userLng,
    vendorLat,
    vendorLng,
  );
  final distanceInKm = distanceInMeters / 1000;

  if (distanceInKm < 1) {
    return '${distanceInMeters.round()} m';
  } else {
    return '${distanceInKm.toStringAsFixed(2)} km';
  }
}

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.vendor,
    required this.onTap,
  });

  final VendorModel vendor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = vendor.isActive;
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, _) {
        final distance = _computeDistance(homeProvider, vendor);
        final estimatedTime = homeProvider.computeEstimatedTimeToVendor(vendor);
        return Opacity(
      opacity: isActive ? 1 : 0.7,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(kRestaurantCardRadius),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(kRestaurantCardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(kRestaurantCardRadius),
                      ),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Image.network(
                          vendor.shopImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.restaurant_rounded,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vendor.shopName,
                              style: GoogleFonts.rubik(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade900,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    distance.isNotEmpty
                                        ? '$distance away${estimatedTime.isNotEmpty ? ' · $estimatedTime' : ''}'
                                        : vendor.shopAddress.isNotEmpty
                                            ? vendor.shopAddress
                                            : '—',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (estimatedTime.isEmpty && vendor.estimateTime.isNotEmpty && isActive) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '~${vendor.estimateTime}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (!isActive) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule_outlined,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Closed · ${vendor.openingTime} – ${vendor.closingTime}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Opens ${vendor.openingTime}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12, top: 38),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: isActive ? Colors.grey.shade400 : Colors.grey.shade300,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                if (!isActive)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(kRestaurantCardRadius),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Closed',
                        style: GoogleFonts.rubik(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }
}
