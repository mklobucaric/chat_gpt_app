import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> getDirectory() async {
  // Check if device is Windows or Android
  if (Platform.isWindows) {
    // Get the external storage directory
    final directory = await getDownloadsDirectory();
    if (directory == null) {
      throw Exception('External storage directory not found');
    }
    return directory.path;
  } else if (Platform.isAndroid) {
    // Get the downloads directory
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      throw Exception('Downloads directory not found');
    }
    return directory.path;
  } else {
    throw Exception('Unsupported platform');
  }
}

Future<void> saveMapToFile(Map<String, dynamic> map) async {
  final directory = await getDirectory();

  final file = File('$directory/_label.json');
  final encodedMap = jsonEncode(map);

  await file.writeAsString(encodedMap);
}

Future<Map<String, dynamic>> loadMapFromFile() async {
  final directory = await getDirectory();
  final file = File('$directory/_label.json');

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
