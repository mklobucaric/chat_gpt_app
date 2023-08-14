import 'package:flutter/material.dart'; // Import the flutter material package
import 'package:permission_handler/permission_handler.dart'; // Import the permission_handler package
import 'dart:io'; // Import the dart file package
import 'package:record/record.dart'; // Import the record package
import 'package:audioplayers/audioplayers.dart'; // Import the audioplayers package
import 'package:path_provider/path_provider.dart'; // Import the path_provider package

class VoiceRecorder extends StatefulWidget {
  const VoiceRecorder({Key? key}) : super(key: key);

  @override
  _VoiceRecorderState createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder> {
  bool _isRecording = false; // Track if recording is in progress
  bool _isRecordingMic =
      false; // Track if microphone is being used for recording
  String _voicePath = ''; // Path to saved voice recording
  bool _playAudio = false; // Track if audio playback is in progress
  String _pathToAudio = ''; // Path to audio file

  final record = Record(); // Create an instance of Record
  final player = AudioPlayer(); // Create an instance of AudioPlayer

  @override
  void initState() {
    super.initState();
    initVoiceRecorder(); // Initialize the voice recorder
  }

  Future<void> _startRecording() async {
    try {
      if (await record.hasPermission()) {
        // Check if permission to record is granted
        // Start recording
        await record.start(
          path: _pathToAudio,
          encoder: AudioEncoder.aacLc, // Set the audio encoder to aacLc
          bitRate: 128000, // Set the bitrate to 128000
          samplingRate: 44100, // Set the sampling rate to 44100
        );
        _isRecordingMic =
            await record.isRecording(); // Check if recording is in progress
        setState(() {
          _isRecordingMic = true;
        });
      }
    } catch (e) {
      throw Exception('Exception: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await record.stop(); // Stop recording
      setState(() {
        _isRecordingMic = false;
        _voicePath = _pathToAudio;
        record.dispose(); // Dispose of the record instance
      });
      Navigator.pop(
          context, _voicePath); // Return the voice path to the previous screen
    } catch (e) {
      throw Exception('Exception: $e');
    }
  }

  Future<void> playFunc() async {
    try {
      await player.play(DeviceFileSource(_pathToAudio)); // Play the audio file
    } catch (e) {
      throw Exception('Exception: $e');
    }
  }

  Future<void> stopPlayFunc() async {
    await player.stop(); // Stop audio playback
  }

  Future initVoiceRecorder() async {
    // Check the platform
    var statusMic = await Permission
        .microphone.status; // Check the status of microphone permission
    if (!statusMic.isGranted) {
      await Permission.microphone
          .request(); // Request microphone permission if not granted
    }

    if (Platform.isAndroid) {
      // Check if the platform is Android
      String directory =
          "/storage/emulated/0/Download/"; // Set the default directory for Android
      bool dirDownloadExists = await Directory(directory).exists();

      if (dirDownloadExists) {
        directory = "/storage/emulated/0/Download/";
      } else {
        directory = "/storage/emulated/0/Downloads/";
      }

      _pathToAudio =
          '${directory}voicePrompt.m4a'; // Set the path to audio file
    } else if (Platform.isWindows) {
      // Check if the platform is Windows
      // For Windows, use the Downloads folder
      final Directory? directory = await getDownloadsDirectory();
      _pathToAudio =
          '${directory!.path}\\voicePrompt.m4a'; // Set the path to audio file
    }
  }

  @override
  void dispose() {
    record.dispose(); // Dispose of the record instance
    player.dispose(); // Dispose of the player instance
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recorder'), // Set the title of the app bar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_isRecordingMic
                ? 'Recording'
                : 'Not Recording'), // Display the recording status
//            Text('Voice Path: $_voicePath'),
            const SizedBox(height: 16), // Empty space with height of 16 pixels
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isRecording = !_isRecording;
                });
                if (_isRecording) {
                  _startRecording(); // Start or stop recording based on the current state
                } else {
                  _stopRecording();
//                  Navigator.pop(context, _voicePath);
                }
              },
              child: Icon(
                _isRecording
                    ? Icons.stop
                    : Icons
                        .mic, // Display a stop icon or a mic icon based on the current state
                size: 50,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _playAudio = !_playAudio;
                });
                if (_playAudio)
                  playFunc(); // Start or stop audio playback based on the current state
                if (!_playAudio) stopPlayFunc();
              },
              child: Icon(
                _playAudio
                    ? Icons.stop
                    : Icons
                        .play_arrow, // Display a stop icon or a play arrow icon based on the current state
                size: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
