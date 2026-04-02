// lib/services/sos_service.dart
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/emergency_popup.dart';

class SosService {
  static final SosService _instance = SosService._internal();
  factory SosService() => _instance;
  SosService._internal();

  ShakeDetector? _shakeDetector;
  bool _isShakeEnabled = true;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Initialize the SOS service and start shake detection if enabled
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isShakeEnabled = prefs.getBool('shake_detection_enabled') ?? true;

    if (_isShakeEnabled) {
      startListening();
    }
  }

  /// Start listening for shake events
  void startListening() {
    _shakeDetector?.stopListening();
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (event) {
        _showEmergencyPopup();
      },
      shakeThresholdGravity: 2.7,
    );
  }

  /// Stop listening for shake events
  void stopListening() {
    _shakeDetector?.stopListening();
    _shakeDetector = null;
  }

  /// Update shake detection preference
  Future<void> setShakeEnabled(bool enabled) async {
    _isShakeEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shake_detection_enabled', enabled);

    if (enabled) {
      startListening();
    } else {
      stopListening();
    }
  }

  bool get isShakeEnabled => _isShakeEnabled;

  void _showEmergencyPopup() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => const EmergencyPopup(),
      );
    }
  }

  /// Execute Full SOS sequence
  Future<void> triggerFullSos(BuildContext context) async {
    // 1. Call Hotline
    final Uri callUri = Uri.parse('tel:1959');
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    }

    // 2. Send Live Location to Firestore
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('emergency_alerts').add({
        'userId': user?.uid ?? 'anonymous',
        'timestamp': FieldValue.serverTimestamp(),
        'location': GeoPoint(position.latitude, position.longitude),
        'status': 'SOS_TRIGGERED',
        'statusHistory': [
          {'status': 'SOS_TRIGGERED', 'timestamp': FieldValue.serverTimestamp(), 'comment': 'Emergency SOS triggered via shake.'}
        ],
        'type': 'SHAKE_DETECTION',
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚨 SOS Alert with location sent to authorities!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error sending SOS location: $e");
    }
  }

  /// Centralized Capture Logic (Photo or Video)
  Future<XFile?> captureEmergencyMedia({required bool isVideo}) async {
    final ImagePicker picker = ImagePicker();
    try {
      if (isVideo) {
        return await picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(seconds: 10),
        );
      } else {
        return await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
      }
    } catch (e) {
      debugPrint("Media capture error: $e");
      return null;
    }
  }
}
