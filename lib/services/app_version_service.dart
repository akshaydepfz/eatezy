import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current app version from package info
  Future<String> getCurrentVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return '1.0.0'; // Default fallback
    }
  }

  /// Get latest app version from Firestore
  Future<String?> getLatestVersion() async {
    try {
      final doc =
          await _firestore.collection('app_version').doc('app_version').get();

      if (doc.exists && doc.data() != null) {
        return doc.data()?['app_version'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Compare versions and check if update is needed
  Future<bool> isUpdateRequired() async {
    try {
      final currentVersion = await getCurrentVersion();
      final latestVersion = await getLatestVersion();

      if (latestVersion == null) {
        return false; // If no version in Firestore, don't force update
      }

      return _compareVersions(currentVersion, latestVersion) < 0;
    } catch (e) {
      return false;
    }
  }

  /// Compare two version strings (e.g., "1.0.2" vs "1.0.3")
  /// Returns: -1 if version1 < version2, 0 if equal, 1 if version1 > version2
  int _compareVersions(String version1, String version2) {
    final v1Parts =
        version1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final v2Parts =
        version2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Pad with zeros if lengths differ
    while (v1Parts.length < v2Parts.length) v1Parts.add(0);
    while (v2Parts.length < v1Parts.length) v2Parts.add(0);

    for (int i = 0; i < v1Parts.length; i++) {
      if (v1Parts[i] < v2Parts[i]) return -1;
      if (v1Parts[i] > v2Parts[i]) return 1;
    }
    return 0;
  }

  /// Get update URL from Firestore (optional)
  Future<String?> getUpdateUrl() async {
    try {
      final doc =
          await _firestore.collection('app_version').doc('app_version').get();

      if (doc.exists && doc.data() != null) {
        return doc.data()?['update_url'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
