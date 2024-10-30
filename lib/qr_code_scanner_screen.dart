// import 'package:flutter/material.dart';
// import 'package:qrscan/qrscan.dart' as scanner;

// class QRCodeScannerScreen extends StatelessWidget {
//   final Function(int) onScannedTime;

//   const QRCodeScannerScreen({required this.onScannedTime, Key? key})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan QR Code'),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.lightBlue.shade100, Colors.lightBlue.shade200],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Center(
//           child: ElevatedButton(
//             onPressed: () => _scanQRCode(context), // Pass context here
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12.0),
//               ),
//               shadowColor: Colors.greenAccent,
//               elevation: 5,
//             ),
//             child: const Text(
//               'Start QR Scan',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _scanQRCode(BuildContext context) async {
//     String? scannedCode = await scanner.scan();
//     if (scannedCode != null && int.tryParse(scannedCode) != null) {
//       int scannedTime = int.parse(scannedCode);
//       if (scannedTime > 0) {
//         onScannedTime(scannedTime); // Pass the scanned time back
//         Navigator.pop(context); // Use the context to pop the screen
//       }
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class QRCodeScannerScreen extends StatelessWidget {
  final Function(int) onScannedTime;

  const QRCodeScannerScreen({required this.onScannedTime, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _scanQRCode(context),
          child: const Text('Start QR Scan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Background color
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  Future<void> _scanQRCode(BuildContext context) async {
    String? scannedCode = await scanner.scan();
    if (scannedCode != null && int.tryParse(scannedCode) != null) {
      int scannedTime = int.parse(scannedCode);
      if (scannedTime > 0) {
        onScannedTime(scannedTime);
        Navigator.pop(context);
      }
    }
  }
}
