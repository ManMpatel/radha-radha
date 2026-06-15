import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  PermissionHelper._();

  static Future<bool> requestMicrophone(BuildContext context) async {
    final status = await Permission.microphone.request();
    if (status.isPermanentlyDenied && context.mounted) {
      _showSettingsDialog(context, 'Microphone permission is needed to record audio');
      return false;
    }
    return status.isGranted;
  }

  static Future<bool> requestStorage(BuildContext context) async {
    PermissionStatus status;
    if (await _isAndroid13OrAbove()) {
      status = await Permission.audio.request();
    } else {
      status = await Permission.storage.request();
    }
    if (status.isPermanentlyDenied && context.mounted) {
      _showSettingsDialog(context, 'Storage permission is needed to access audio files');
      return false;
    }
    return status.isGranted;
  }

  static Future<bool> requestPhoneState(BuildContext context) async {
    final status = await Permission.phone.request();
    return status.isGranted;
  }

  static Future<bool> checkMicrophone() async {
    return (await Permission.microphone.status).isGranted;
  }

  static Future<bool> checkStorage() async {
    if (await _isAndroid13OrAbove()) {
      return (await Permission.audio.status).isGranted;
    }
    return (await Permission.storage.status).isGranted;
  }

  static Future<bool> _isAndroid13OrAbove() async {
    // Permission.audio exists on Android 13+ (API 33+)
    return true;
  }

  static void _showSettingsDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
