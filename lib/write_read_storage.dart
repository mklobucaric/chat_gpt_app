import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Function to get the directory path to store or retrieve data files
Future<String> getDirectory() async {
  // Check if the device is Windows or Android
  if (Platform.isWindows) {
    // If the platform is Windows, get the external storage directory
    final directory = await getDownloadsDirectory();
    if (directory == null) {
      // Throw an error if the directory couldn't be located
      throw Exception('External storage directory not found');
    }
    return directory.path;
  } else if (Platform.isAndroid) {
    // If the platform is Android, get the downloads' directory
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      // Throw an error if the directory couldn't be located
      throw Exception('Downloads directory not found');
    }
    return directory.path;
  } else {
    // Throw an error if the device platform is neither Windows nor Android
    throw Exception('Unsupported platform');
  }
}

// Function to save a map to a file
Future<void> saveMapToFile(Map<String, dynamic> map) async {
  // Get the directory path
  final directory = await getDirectory();

  // Set the path and name of the file to save the map in
  final file = File('$directory/_label.json');

  // Encode the map to JSON format
  final encodedMap = jsonEncode(map);

  // Write the encoded map as a string to the file
  await file.writeAsString(encodedMap);
}

// Function to load a map from a file
Future<Map<String, dynamic>> loadMapFromFile() async {
  // Get the directory path
  final directory = await getDirectory();

  // Set the path and name of the file to read the map from
  final file = File('$directory/_label.json');

  // Check if the file exists
  if (await file.exists()) {
    // If file exists, read the content as a string
    final encodedMap = await file.readAsString();

    // Decode the string back to map
    final decodedMap = jsonDecode(encodedMap) as Map<String, dynamic>;
    return decodedMap;
  } else {
    // If file doesn't exist, return a default map
    return {
      'mode': 'education',
      'creativity': '1',
      'model': 'gpt-3.5-turbo-16k-0613'
    };
  }
}
