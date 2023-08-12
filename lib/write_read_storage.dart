import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestStoragePermission() async {
  PermissionStatus status = await Permission.storage.request();
  if (status.isDenied) {
    // Handle permission denied
  }
}

Future<void> saveMapToFile(Map<String, dynamic> map) async {
  await requestStoragePermission();

  final directory = await getDownloadsDirectory();
  final file = File('${directory?.path}/map_data.json');
  final encodedMap = jsonEncode(map);

  await file.writeAsString(encodedMap);
}

Future<Map<String, dynamic>> loadMapFromFile() async {
  await requestStoragePermission();

  final directory = await getDownloadsDirectory();
  final file = File('${directory?.path}/map_data.json');

  if (await file.exists()) {
    final encodedMap = await file.readAsString();
    final decodedMap = jsonDecode(encodedMap) as Map<String, dynamic>;
    return decodedMap;
  } else {
    return {
      'mode': 'education',
      'creativity': '1',
      'model': 'gpt-3.5-turbo-16k-0613'
    };
  }
}
