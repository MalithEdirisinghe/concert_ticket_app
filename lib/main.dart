import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'video_fetcher.dart'; // Your existing VideoListScreen import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Fetcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TimePeriodInputScreen(),
    );
  }
}

class TimePeriodInputScreen extends StatefulWidget {
  @override
  _TimePeriodInputScreenState createState() => _TimePeriodInputScreenState();
}

class _TimePeriodInputScreenState extends State<TimePeriodInputScreen> {
  int _remainingTime = 0;
  bool _isCountingDown = false;
  bool _isQRCodeVisible = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions(); // Check permissions on app launch
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Time Period'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.lightBlue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display QR code if visible
              if (_isQRCodeVisible)
                QrImageView(
                  data: '5', // QR Code data set to '5' for 5 minutes
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              const SizedBox(height: 30),
              // Display countdown timer text
              if (_isCountingDown)
                Text(
                  'Time Remaining: ${_remainingTime ~/ 60}m ${_remainingTime % 60}s',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black26,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Check and request storage permissions
  Future<void> _checkPermissions() async {
    if (await Permission.storage.isGranted ||
        await Permission.manageExternalStorage.isGranted) {
      _generateAndShowQRCode(); // If already granted, show QR code
    } else {
      _showPermissionRequestDialog(); // Otherwise, request permission
    }
  }

  // Show a dialog to request permissions
  void _showPermissionRequestDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
            'This app needs access to your storage to fetch videos and apply effects.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog
                // Request permissions
                Map<Permission, PermissionStatus> statuses = await [
                  Permission.storage,
                  Permission.manageExternalStorage,
                ].request();

                // Check if the permissions are granted
                if (statuses[Permission.storage]?.isGranted == true ||
                    statuses[Permission.manageExternalStorage]?.isGranted ==
                        true) {
                  _generateAndShowQRCode(); // Proceed if permissions are granted
                } else {
                  // Show message if permissions are denied
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Storage permission is required to access videos.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Allow'),
            ),
          ],
        );
      },
    );
  }

  // Generate QR Code and show it for 5 seconds
  void _generateAndShowQRCode() {
    setState(() {
      _isQRCodeVisible = true;
    });

    // Set the countdown time to 5 minutes
    _remainingTime = 5 * 60;

    // Show QR code for 5 seconds, then start countdown and navigate
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isQRCodeVisible = false;
      });

      // Navigate to VideoListScreen
      _navigateToVideoListScreen();
    });
  }

  // Navigate to VideoListScreen
  void _navigateToVideoListScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VideoListScreen(
          minutes: 5, // Pass 5 minutes to the VideoListScreen
          onCountdownEnd: _endCountdown,
        ),
      ),
    );
  }

  // Run the countdown timer
  void _runCountdownTimer() {
    Future.doWhile(() async {
      if (_remainingTime > 0) {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _remainingTime--;
        });
        return true;
      } else {
        return false;
      }
    });
  }

  // End the countdown
  void _endCountdown() {
    setState(() {
      _isCountingDown = false; // Stop countdown state
    });
  }
}
