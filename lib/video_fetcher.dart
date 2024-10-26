// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// class VideoListScreen extends StatefulWidget {
//   final int minutes; // Time period in minutes

//   const VideoListScreen({required this.minutes, Key? key}) : super(key: key);

//   @override
//   _VideoListScreenState createState() => _VideoListScreenState();
// }

// class _VideoListScreenState extends State<VideoListScreen> {
//   List<File> _fetchedVideos = []; // List of fetched videos
//   List<String> _deletedVideos = []; // List of deleted video names
//   bool _isFetching = true; // Fetching state

//   @override
//   void initState() {
//     super.initState();
//     _checkAndRequestPermissions(); // Start permission check when screen loads
//   }

//   // Check and request storage permissions
//   Future<void> _checkAndRequestPermissions() async {
//     if (await Permission.storage.isGranted ||
//         await _requestManageExternalStorage()) {
//       _fetchAndDeleteNewVideos(); // Fetch and delete videos if permission is granted
//     } else {
//       PermissionStatus status = await Permission.storage.request();

//       if (status.isGranted || await _requestManageExternalStorage()) {
//         _fetchAndDeleteNewVideos(); // Fetch and delete videos if permission is granted
//       } else if (status.isPermanentlyDenied) {
//         await openAppSettings(); // Open app settings if permission is permanently denied
//       } else {
//         _showPermissionDeniedMessage(); // Show a message if permission is denied
//       }
//     }
//   }

//   // Request MANAGE_EXTERNAL_STORAGE permission for Android 11+
//   Future<bool> _requestManageExternalStorage() async {
//     if (await Permission.manageExternalStorage.isGranted) return true;

//     if (Platform.isAndroid &&
//         await Permission.manageExternalStorage.request().isGranted) {
//       return true;
//     }
//     return false;
//   }

//   // Show a message if permission is denied
//   void _showPermissionDeniedMessage() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//           content: Text('Storage permission is required to access videos.')),
//     );
//   }

//   // Fetch and delete videos created during the specified time period
//   Future<void> _fetchAndDeleteNewVideos() async {
//     setState(() {
//       _isFetching = true;
//     });

//     // Calculate the start time based on the entered minutes
//     DateTime startTime =
//         DateTime.now().subtract(Duration(minutes: widget.minutes));

//     List<String> videoDirs = [
//       '/storage/emulated/0/DCIM',
//       '/storage/emulated/0/Movies',
//       '/storage/emulated/0/Video',
//     ];

//     for (String dirPath in videoDirs) {
//       Directory dir = Directory(dirPath);
//       if (dir.existsSync()) {
//         await _scanAndDeleteDirectory(
//             dir, startTime); // Scan and delete videos in each directory
//       }
//     }

//     setState(() {
//       _isFetching = false;
//     });
//   }

//   // Recursive function to scan directories for new videos and delete them
//   Future<void> _scanAndDeleteDirectory(
//       Directory directory, DateTime startTime) async {
//     try {
//       List<FileSystemEntity> files = directory.listSync();

//       for (FileSystemEntity file in files) {
//         if (file is File && _isVideoFile(file.path)) {
//           // Check if the file still exists
//           if (file.existsSync()) {
//             try {
//               DateTime lastModified = file.lastModifiedSync();
//               // Check if the video was created/modified after the start time
//               if (lastModified.isAfter(startTime)) {
//                 setState(() {
//                   _fetchedVideos.add(file); // Add the video to the fetched list
//                 });

//                 // Attempt to delete the video file
//                 bool isDeleted = await _deleteFile(file);
//                 if (isDeleted) {
//                   setState(() {
//                     _deletedVideos.add(file.path
//                         .split('/')
//                         .last); // Add video name to deleted list
//                   });
//                 }
//               }
//             } catch (e) {
//               print('Error retrieving file info: $e');
//             }
//           }
//         } else if (file is Directory) {
//           await _scanAndDeleteDirectory(
//               file, startTime); // Recursively scan subdirectories
//         }
//       }
//     } catch (e) {
//       print('Error while scanning directory: $e');
//     }
//   }

//   // Helper function to delete a file and return deletion status
//   Future<bool> _deleteFile(File file) async {
//     try {
//       await file.delete();
//       print('Deleted: ${file.path}');
//       return true; // File successfully deleted
//     } catch (e) {
//       print('Failed to delete ${file.path}: $e');
//       return false; // File deletion failed
//     }
//   }

//   // Helper function to check if a file is a video
//   bool _isVideoFile(String path) {
//     return path.endsWith('.mp4') ||
//         path.endsWith('.avi') ||
//         path.endsWith('.mov') ||
//         path.endsWith('.mkv');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Fetched Videos')),
//       body: _isFetching
//           ? const Center(child: CircularProgressIndicator())
//           : _buildResult(),
//     );
//   }

//   // Build the UI for fetched and deleted videos
//   Widget _buildResult() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (_deletedVideos.isNotEmpty) ...[
//           const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Text('Deleted Videos:',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: _deletedVideos.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(_deletedVideos[index]),
//                 );
//               },
//             ),
//           ),
//         ] else ...[
//           const Center(child: Text('No videos deleted.')),
//         ],
//       ],
//     );
//   }
// }


//2nd
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:video_compress/video_compress.dart';

// class VideoListScreen extends StatefulWidget {
//   final int minutes; // Time period in minutes

//   const VideoListScreen({required this.minutes, Key? key}) : super(key: key);

//   @override
//   _VideoListScreenState createState() => _VideoListScreenState();
// }

// class _VideoListScreenState extends State<VideoListScreen> {
//   List<File> _fetchedVideos = []; // List of fetched videos
//   List<String> _blurredVideos = []; // List of blurred video names
//   bool _isFetching = true; // Fetching state

//   @override
//   void initState() {
//     super.initState();
//     _checkAndRequestPermissions(); // Start permission check when screen loads
//   }

//   @override
//   void dispose() {
//     VideoCompress.dispose(); // Dispose video compressor
//     super.dispose();
//   }

//   // Check and request storage permissions
//   Future<void> _checkAndRequestPermissions() async {
//     if (await Permission.storage.isGranted ||
//         await _requestManageExternalStorage()) {
//       _fetchAndBlurVideos(); // Fetch and blur videos if permission is granted
//     } else {
//       PermissionStatus status = await Permission.storage.request();

//       if (status.isGranted || await _requestManageExternalStorage()) {
//         _fetchAndBlurVideos(); // Fetch and blur videos if permission is granted
//       } else if (status.isPermanentlyDenied) {
//         await openAppSettings(); // Open app settings if permission is permanently denied
//       } else {
//         _showPermissionDeniedMessage(); // Show a message if permission is denied
//       }
//     }
//   }

//   // Request MANAGE_EXTERNAL_STORAGE permission for Android 11+
//   Future<bool> _requestManageExternalStorage() async {
//     if (await Permission.manageExternalStorage.isGranted) return true;

//     if (Platform.isAndroid &&
//         await Permission.manageExternalStorage.request().isGranted) {
//       return true;
//     }
//     return false;
//   }

//   // Show a message if permission is denied
//   void _showPermissionDeniedMessage() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//           content: Text('Storage permission is required to access videos.')),
//     );
//   }

//   // Fetch and blur videos created during the specified time period
//   Future<void> _fetchAndBlurVideos() async {
//     setState(() {
//       _isFetching = true;
//     });

//     // Calculate the start time based on the entered minutes
//     DateTime startTime =
//         DateTime.now().subtract(Duration(minutes: widget.minutes));

//     List<String> videoDirs = [
//       '/storage/emulated/0/DCIM',
//       '/storage/emulated/0/Movies',
//       '/storage/emulated/0/Video',
//     ];

//     for (String dirPath in videoDirs) {
//       Directory dir = Directory(dirPath);
//       if (dir.existsSync()) {
//         await _scanAndBlurDirectory(dir, startTime); // Scan and blur videos
//       }
//     }

//     setState(() {
//       _isFetching = false;
//     });
//   }

//   // Recursive function to scan directories for new videos and blur them
//   Future<void> _scanAndBlurDirectory(
//       Directory directory, DateTime startTime) async {
//     try {
//       List<FileSystemEntity> files = directory.listSync();

//       for (FileSystemEntity file in files) {
//         if (file is File && _isVideoFile(file.path)) {
//           // Check if the file still exists
//           if (file.existsSync()) {
//             try {
//               DateTime lastModified = file.lastModifiedSync();
//               // Check if the video was created/modified after the start time
//               if (lastModified.isAfter(startTime)) {
//                 setState(() {
//                   _fetchedVideos.add(file); // Add the video to the fetched list
//                 });

//                 // Blur the video by compressing it
//                 bool isBlurred = await _blurVideo(file);
//                 if (isBlurred) {
//                   setState(() {
//                     _blurredVideos
//                         .add(file.path.split('/').last); // Add to blurred list
//                   });
//                 }
//               }
//             } catch (e) {
//               print('Error retrieving file info: $e');
//             }
//           }
//         } else if (file is Directory) {
//           await _scanAndBlurDirectory(
//               file, startTime); // Recursively scan subdirectories
//         }
//       }
//     } catch (e) {
//       print('Error while scanning directory: $e');
//     }
//   }

//   // Helper function to blur video by compressing it
//   Future<bool> _blurVideo(File file) async {
//     try {
//       final info = await VideoCompress.compressVideo(
//         file.path,
//         quality: VideoQuality.LowQuality, // Simulate blurring with low quality
//         deleteOrigin: false, // Keep the original video
//       );

//       if (info != null && info.file != null) {
//         print('Blurred: ${info.file!.path}');
//         return true; // Video successfully blurred
//       }
//     } catch (e) {
//       print('Failed to blur ${file.path}: $e');
//     }
//     return false; // Video blurring failed
//   }

//   // Helper function to check if a file is a video
//   bool _isVideoFile(String path) {
//     return path.endsWith('.mp4') ||
//         path.endsWith('.avi') ||
//         path.endsWith('.mov') ||
//         path.endsWith('.mkv');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Fetched Videos')),
//       body: _isFetching
//           ? const Center(child: CircularProgressIndicator())
//           : _buildResult(),
//     );
//   }

//   // Build the UI for fetched and blurred videos
//   Widget _buildResult() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (_blurredVideos.isNotEmpty) ...[
//           const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Text('Blurred Videos:',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: _blurredVideos.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(_blurredVideos[index]),
//                 );
//               },
//             ),
//           ),
//         ] else ...[
//           const Center(child: Text('No videos blurred.')),
//         ],
//       ],
//     );
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class VideoListScreen extends StatefulWidget {
  final int minutes;

  const VideoListScreen({required this.minutes, Key? key}) : super(key: key);

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List<File> _fetchedVideos = [];
  bool _isFetching = true;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
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
      const SnackBar(
          content: Text('Storage permission is required to access videos.')),
    );
  }

  Future<void> _fetchAndProcessVideos() async {
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
        if (file is File && _isVideoFile(file.path)) {
          if (file.existsSync()) {
            try {
              DateTime lastModified = file.lastModifiedSync();
              if (lastModified.isAfter(startTime)) {
                setState(() {
                  _fetchedVideos.add(file);
                });

                await _blurAndPlayVideo(file);
              }
            } catch (e) {
              print('Error retrieving file info: $e');
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

  Future<void> _blurAndPlayVideo(File file) async {
    try {
      // Use the app's temporary directory to store the blurred video
      final Directory tempDir = await getTemporaryDirectory();
      final String outputPath =
          '${tempDir.path}/blurred_${file.path.split('/').last}';

      // FFmpeg command to blur the video
      final String ffmpegCommand =
          '-i "${file.path}" -vf "boxblur=10:1" -preset ultrafast "$outputPath"';

      // Execute the FFmpeg command using ffmpeg_kit_flutter
      final session = await FFmpegKit.execute(ffmpegCommand);

      // Retrieve the return code
      final ReturnCode? returnCode = await session.getReturnCode();

      if (returnCode != null && returnCode.isValueSuccess()) {
        print('FFmpeg executed successfully.');
        File blurredVideo = File(outputPath);

        // Initialize the video player with the blurred video
        if (blurredVideo.existsSync()) {
          _initializeVideoPlayer(blurredVideo);
        } else {
          print('Blurred video file not found at $outputPath');
        }
      } else {
        print('FFmpeg failed with return code: $returnCode');
        final String? failureLogs = await session.getFailStackTrace();
        if (failureLogs != null) {
          print('FFmpeg Failure: $failureLogs');
        }
      }
    } catch (e) {
      print('Failed to process ${file.path}: $e');
    }
  }

  void _initializeVideoPlayer(File videoFile) {
    _videoPlayerController?.dispose(); // Dispose the previous controller if any
    _videoPlayerController = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController?.play();
      }).catchError((e) {
        print('Error initializing video player: $e');
      });
  }

  bool _isVideoFile(String path) {
    return path.endsWith('.mp4') ||
        path.endsWith('.avi') ||
        path.endsWith('.mov') ||
        path.endsWith('.mkv');
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fetched Videos')),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : _buildVideoPlayer(),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        child: VideoPlayer(_videoPlayerController!),
      );
    } else {
      return const Center(
          child: Text('No videos processed or ready for playback.'));
    }
  }
}
