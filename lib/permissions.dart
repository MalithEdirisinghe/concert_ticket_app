import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isDenied || status.isRestricted) {
      // Request permission
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }
}
