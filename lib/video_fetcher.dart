import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class VideoListScreen extends StatefulWidget {
  final int minutes;
  final VoidCallback? onCountdownEnd;

  const VideoListScreen({
    required this.minutes,
    this.onCountdownEnd,
    Key? key,
  }) : super(key: key);

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List<File> _fetchedVideos = [];
  bool _isFetching = false;
  VideoPlayerController? _videoPlayerController;
  int _remainingTime = 0;
  Timer? _mainTimer;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.minutes * 60; // Convert minutes to seconds
    _startMainTimer();
    _checkAndRequestPermissions();
  }

  @override
  void dispose() {
    _mainTimer?.cancel(); // Cancel the main timer
    _videoPlayerController?.dispose(); // Dispose video player
    super.dispose();
  }

  void _startMainTimer() {
    // Periodic timer to handle both countdown and fetching
    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--; // Decrement countdown
        });
        if (_remainingTime % 5 == 0) {
          // Fetch every 5 seconds
          await _fetchAndProcessVideos();
        }
      } else {
        timer.cancel();
        if (widget.onCountdownEnd != null) {
          widget.onCountdownEnd!(); // Trigger countdown end callback
        }
        _showEndAlert(context); // Show alert when countdown ends
      }
    });
  }

  // Show alert when countdown ends
  void _showEndAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Concert has ended'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Button color
              ),
              onPressed: () {
                Navigator.of(context)
                  ..pop() // Close alert
                  ..pop(); // Navigate back to main screen
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkAndRequestPermissions() async {
    if (await Permission.storage.isGranted ||
        await _requestManageExternalStorage()) {
      _fetchAndProcessVideos();
    } else {
      PermissionStatus status = await Permission.storage.request();
      if (status.isGranted || await _requestManageExternalStorage()) {
        _fetchAndProcessVideos();
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      } else {
        _showPermissionDeniedMessage();
      }
    }
  }

  Future<bool> _requestManageExternalStorage() async {
    if (await Permission.manageExternalStorage.isGranted) return true;
    if (Platform.isAndroid &&
        await Permission.manageExternalStorage.request().isGranted) {
      return true;
    }
    return false;
  }

  void _showPermissionDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Storage permission is required to access videos.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _fetchAndProcessVideos() async {
    if (_isFetching) return; // Prevent overlapping fetch calls

    setState(() {
      _isFetching = true;
    });

    DateTime startTime =
        DateTime.now().subtract(Duration(minutes: widget.minutes));
    List<String> videoDirs = [
      '/storage/emulated/0/DCIM',
      '/storage/emulated/0/Movies',
      '/storage/emulated/0/Video',
    ];

    for (String dirPath in videoDirs) {
      Directory dir = Directory(dirPath);
      if (dir.existsSync()) {
        await _scanAndProcessDirectory(dir, startTime);
      }
    }

    setState(() {
      _isFetching = false;
    });
  }

  Future<void> _scanAndProcessDirectory(
      Directory directory, DateTime startTime) async {
    try {
      List<FileSystemEntity> files = directory.listSync();

      for (FileSystemEntity file in files) {
        if (_remainingTime <= 0) break; // Stop if countdown ends

        if (file is File && _isVideoFile(file.path)) {
          if (file.existsSync()) {
            DateTime lastModified = file.lastModifiedSync();
            if (lastModified.isAfter(startTime)) {
              setState(() {
                _fetchedVideos.add(file);
              });
              await _blurAndReplaceVideo(file);
            }
          }
        } else if (file is Directory) {
          await _scanAndProcessDirectory(file, startTime);
        }
      }
    } catch (e) {
      print('Error while scanning directory: $e');
    }
  }

  Future<void> _blurAndReplaceVideo(File file) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String outputPath =
          '${tempDir.path}/blurred_${file.path.split('/').last}';

      // FFmpeg command to blur the video
      final String ffmpegCommand =
          '-i "${file.path}" -vf "boxblur=10:1" -preset ultrafast "$outputPath"';

      final session = await FFmpegKit.execute(ffmpegCommand);
      final ReturnCode? returnCode = await session.getReturnCode();

      if (returnCode != null && returnCode.isValueSuccess()) {
        File blurredVideo = File(outputPath);

        if (blurredVideo.existsSync()) {
          await blurredVideo.copy(file.path); // Replace original video
        } else {
          print('Blurred video file not found at $outputPath');
        }
      } else {
        print('FFmpeg failed with return code: $returnCode');
      }
    } catch (e) {
      print('Failed to process ${file.path}: $e');
    }
  }

  bool _isVideoFile(String path) {
    return path.endsWith('.mp4') ||
        path.endsWith('.avi') ||
        path.endsWith('.mov') ||
        path.endsWith('.mkv');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fetched Videos'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[100]!, Colors.blue[200]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center contents vertically
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center contents horizontally
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Concert will end in: ${_remainingTime ~/ 60}m ${_remainingTime % 60}s',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black38,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center, // Center the text
              ),
            ),
            Expanded(
              child: Center(
                // Center video player
                child: _videoPlayerController != null &&
                        _videoPlayerController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoPlayerController!.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController!),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
