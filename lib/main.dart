import 'package:flutter/material.dart';
import 'video_fetcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Fetcher',
      theme: ThemeData(primarySwatch: Colors.blue),
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
  bool _isInputDisabled = false; // Disable input and button

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Time Period')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Disable the text field during countdown
            TextField(
              controller: _minuteController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Minutes',
                border: OutlineInputBorder(),
              ),
              enabled:
                  !_isInputDisabled, // Disable input when countdown is active
            ),
            const SizedBox(height: 24),
            // Disable the button during countdown
            ElevatedButton(
              onPressed: _isInputDisabled ? null : _startCountdown,
              child: const Text('Start Countdown'),
            ),
            const SizedBox(height: 24),
            if (_isCountingDown)
              Text(
                'Time Remaining: ${_remainingTime ~/ 60}m ${_remainingTime % 60}s',
                style: const TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }

  // Start the countdown
  void _startCountdown() {
    final int minutes = int.tryParse(_minuteController.text) ?? 0;
    if (minutes > 0) {
      setState(() {
        _remainingTime = minutes * 60; // Convert minutes to seconds
        _isCountingDown = true;
        _isInputDisabled = true; // Disable input and button
      });

      _runTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid time period')),
      );
    }
  }

  // Run the countdown timer
  void _runTimer() {
    Future.doWhile(() async {
      if (_remainingTime > 0) {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _remainingTime--; // Decrement the remaining time
        });
        return true; // Continue the loop
      } else {
        _endCountdown(); // Countdown finished
        return false; // Stop the loop
      }
    });
  }

  // End the countdown and navigate to the video fetching screen
  void _endCountdown() {
    setState(() {
      _isCountingDown = false; // Stop displaying countdown
      _isInputDisabled = false; // Re-enable input and button
    });

    // Navigate to VideoListScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            VideoListScreen(minutes: int.parse(_minuteController.text)),
      ),
    );
  }
}
