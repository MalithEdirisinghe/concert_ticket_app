import 'package:flutter/material.dart';
import 'video_fetcher.dart'; // Your existing VideoListScreen import
import 'qr_code_scanner_screen.dart'; // Import the QR code scanner

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
  final TextEditingController _minuteController = TextEditingController();
  int _remainingTime = 0; // Countdown time in seconds
  bool _isCountingDown = false; // Countdown state

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // QR Code scanning button
              ElevatedButton(
                onPressed: _isCountingDown ? null : _openQRCodeScanner,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Scan QR Code',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
              // Display scanned time
              TextField(
                controller: _minuteController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Scanned Minutes',
                  labelStyle: const TextStyle(color: Colors.blueAccent),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                ),
                enabled: false, // Disable manual input
              ),
              const SizedBox(height: 30),
              // Start Countdown button
              ElevatedButton(
                onPressed: _isCountingDown ? null : _startCountdown,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Start Countdown',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
              // Countdown timer text
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

  // Open QR Code scanner
  void _openQRCodeScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRCodeScannerScreen(
          onScannedTime: (int scannedTime) {
            setState(() {
              _minuteController.text = scannedTime.toString();
              _remainingTime = scannedTime * 60; // Convert to seconds
            });
          },
        ),
      ),
    );
  }

  // Start the countdown
  void _startCountdown() {
    final int minutes = int.tryParse(_minuteController.text) ?? 0;
    if (minutes > 0) {
      setState(() {
        _remainingTime = minutes * 60; // Convert to seconds
        _isCountingDown = true; // Set countdown state
      });

      // Navigate to VideoListScreen immediately
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoListScreen(
            minutes: minutes,
            onCountdownEnd: _endCountdown,
          ),
        ),
      );

      // Start the timer
      _runCountdownTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid time period')),
      );
    }
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
