import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> getDirectory() async {
  // Wait for storage access permission
  // var statusStorage = await Permission.storage.status;
  // if (!statusStorage.isGranted) {
  //   await Permission.storage.request();
  // }

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

// Future initStorage() async {
//   // Check the platform

//   if (Platform.isAndroid) {
//     var statusStorage = await Permission.storage.status;
//     if (!statusStorage.isGranted) {
//       await Permission.storage.request();
//     }

//     //   String directory = "/storage/emulated/0/Download/";
//     final directoryPath = await getExternalStorageDirectory();
//     // bool dirDownloadExists = await Directory(directory!.path).exists();

//     // if (dirDownloadExists) {
//     //   directory = "/storage/emulated/0/Download/";
//     // } else {
//     //   directory = "/storage/emulated/0/Downloads/";
//     // }
//     final directory = directoryPath!.path;
//     final file = '$directory\\_label.json';
//     //   _pathToAudio = '${directory}voicePrompt.m4a';
//   } else if (Platform.isWindows) {
//     // For Windows, use the Downloads folder
//     final Directory? directory = await getDownloadsDirectory();
//     _pathToAudio = '${directory!.path}\\voicePrompt.m4a';
//   }
// }

// Future<void> requestStoragePermission() async {
//   if (Platform.isAndroid) {
//     var statusStorage = await Permission.storage.status;
//     if (!statusStorage.isGranted) {
//       await Permission.storage.request();
//     }
//   }
// }

Future<void> saveMapToFile(Map<String, dynamic> map) async {
//  await requestStoragePermission();

  //final directory = await getDownloadsDirectory();
  final directory = await getDirectory();

  final file = File('$directory/_label.json');
  final encodedMap = jsonEncode(map);

  await file.writeAsString(encodedMap);
}

Future<Map<String, dynamic>> loadMapFromFile() async {
  // await requestStoragePermission();

  // final directory = await getDownloadsDirectory();
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
