import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRecorder extends StatefulWidget {
  @override
  _VoiceRecorderState createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder> {
  FlutterSoundRecorder? _recorder;
  String? _voicePath;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
  }

  Future<String> _getDownloadPath() async {
    final directory = await getExternalStorageDirectory();
    return directory!.path;
  }

  Future<void> _startRecording() async {
    try {
      await _recorder!.openAudioSession();
      await _recorder!.startRecorder(
        toFile: await _getDownloadPath() + '/voicePrompt.mp3',
        codec: Codec.mp3,
      );
    } catch (e) {
      print('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder!.stopRecorder();
      await _recorder!.closeAudioSession();
      setState(() {
        _voicePath = _recorder!.lastSavedFilePath;
      });
    } catch (e) {
      print('Failed to stop recording: $e');
    }
  }

  @override
  void dispose() {
    _recorder!.closeAudioSession();
    _recorder = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _startRecording,
              child: Text('Start Recording'),
            ),
            ElevatedButton(
              onPressed: _stopRecording,
              child: Text('Stop Recording'),
            ),
            SizedBox(height: 20),
            Text(
              'Voice Path: $_voicePath',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
