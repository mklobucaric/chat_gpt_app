import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class VoiceRecorder extends StatefulWidget {
  const VoiceRecorder({Key? key}) : super(key: key);

  @override
  _VoiceRecorderState createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder> {
  bool _isRecording = false;
  bool _isRecordingMic = false;
  String _voicePath = '';
  bool _playAudio = false;
  String _pathToAudio = '';

  final record = Record();
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    initVoiceRecorder();
  }

  Future<void> _startRecording() async {
    try {
      if (await record.hasPermission()) {
        // Start recording
        await record.start(
          path: _pathToAudio,
          encoder: AudioEncoder.aacLc, // by default
          bitRate: 128000, // by default
          samplingRate: 44100, // by default
        );
        _isRecordingMic = await record.isRecording();
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
      await record.stop();
      setState(() {
        _isRecordingMic = false;
        _voicePath = _pathToAudio;
        record.dispose();
      });
      Navigator.pop(context, _voicePath);
    } catch (e) {
      throw Exception('Exception: $e');
      // print('Failed to stop recording: $e');
    }
  }

  Future<void> playFunc() async {
    try {
      await player.play(DeviceFileSource(_pathToAudio));
    } catch (e) {
      throw Exception('Exception: $e');
    }
  }

  Future<void> stopPlayFunc() async {
    await player.stop();
  }

  Future initVoiceRecorder() async {
    //await Permission.microphone.request();

    var statusMic = await Permission.microphone.status;
    if (!statusMic.isGranted) {
      await Permission.microphone.request();
    }

    var statusStorage = await Permission.storage.status;
    if (!statusStorage.isGranted) {
      await Permission.storage.request();
    }

    String directory = "/storage/emulated/0/Download/";
    bool dirDownloadExists = await Directory(directory).exists();

    if (dirDownloadExists) {
      directory = "/storage/emulated/0/Download/";
    } else {
      directory = "/storage/emulated/0/Downloads/";
    }

    _pathToAudio = '${directory}voicePrompt.m4a';
  }

  @override
  void dispose() {
    record.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_isRecordingMic ? 'Recording' : 'Not Recording'),
//            Text('Voice Path: $_voicePath'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isRecording = !_isRecording;
                });
                if (_isRecording) {
                  _startRecording();
                } else {
                  _stopRecording();
//                  Navigator.pop(context, _voicePath);
                }
              },
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                size: 50,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _playAudio = !_playAudio;
                });
                if (_playAudio) playFunc();
                if (!_playAudio) stopPlayFunc();
              },
              child: Icon(
                _playAudio ? Icons.stop : Icons.play_arrow,
                size: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
