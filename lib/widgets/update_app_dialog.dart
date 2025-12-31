import 'package:eatezy/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateAppDialog extends StatelessWidget {
  final String latestVersion;
  final String? updateUrl;

  const UpdateAppDialog({
    super.key,
    required this.latestVersion,
    this.updateUrl,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent dismissing by back button
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.system_update,
                  size: 48,
                  color: AppColor.primary,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Update Available',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                'A new version ($latestVersion) is available. Please update to continue using the app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),

              // Update Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await _launchUpdateUrl(context);
                  },
                  child: const Text(
                    'Update Now',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUpdateUrl(BuildContext context) async {
    try {
      String url = updateUrl ?? _getDefaultStoreUrl();

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open update link'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
      }
    }
  }

  String _getDefaultStoreUrl() {
    // Default URLs - you can customize these
    // For Android
    return 'https://play.google.com/store/apps/details?id=com.eatezy.app';
    // For iOS, you would use:
    // return 'https://apps.apple.com/app/idYOUR_APP_ID';
  }
}

/// Helper function to show update dialog
Future<void> showUpdateDialog(
  BuildContext context, {
  required String latestVersion,
  String? updateUrl,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (context) => UpdateAppDialog(
      latestVersion: latestVersion,
      updateUrl: updateUrl,
    ),
  );
}
