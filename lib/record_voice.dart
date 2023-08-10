import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:record/record.dart';

class VoiceRecorder extends StatefulWidget {
  const VoiceRecorder({Key? key}) : super(key: key);

  @override
  _VoiceRecorderState createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder> {
  // final _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  bool _isRecordingMic = false;
  String _voicePath = '';
  bool _playAudio = false;
  //String pathToAudio = 'sdcard/Download/voicePrompt.mp4';
  String pathToAudio = '';

  final recordingPlayer = AssetsAudioPlayer();
  final record = Record();

  @override
  void initState() {
    super.initState();
    initVoiceRecorder();
  }

  Future<void> _startRecording() async {
    try {
      // await _recorder.startRecorder(
      //     toFile: pathToAudio,
      //     codec: Codec.aacMP4);

      if (await record.hasPermission()) {
        // Start recording
        await record.start(
          path: pathToAudio,
          encoder: AudioEncoder.aacLc, // by default
          bitRate: 128000, // by default
          samplingRate: 44100, // by default
        );
        bool _isRecordingMic = await record.isRecording();
        setState(() {
          _isRecordingMic = true;
        });
      }
    } catch (e) {
      print('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      //    final voicePath = await _recorder.stopRecorder();
      //     final voicePath = await _recorder.stopRecorder();
      //     final audioVoicePath = File(voicePath!);
      await record.stop();
      setState(() {
        _isRecordingMic = false;
        //     _voicePath = audioVoicePath.path;
        _voicePath = pathToAudio;
      });
      //     Navigator.pop(context, audioVoicePath.path);
    } catch (e) {
      print('Failed to stop recording: $e');
    }
  }

  Future<void> playFunc() async {
    recordingPlayer.open(
      Audio.file(pathToAudio),
      autoStart: true,
      showNotification: true,
    );
  }

  Future<void> stopPlayFunc() async {
    recordingPlayer.stop();
  }

  Future initVoiceRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
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

    //  pathToAudio = '${directory}voicePrompt.mp4';
    pathToAudio = '${directory}voicePrompt.m4a';

    //   await _recorder.openRecorder();
    //   _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    //  _recorder.closeRecorder();
    record.dispose();
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
            // StreamBuilder<RecordingDisposition>(
            //   stream: _recorder.onProgress,
            //   builder: (context, snapshot) {
            //     final disposition = snapshot.data;
            //     return Text(
            //         'Recording disposition: ${disposition?.toString() ?? 'Unkown'}');
            //   },
            // ),
            Text(_isRecordingMic ? 'Recording' : 'Not Recording'),
            Text('Voice Path: $_voicePath'),
            const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     _startRecording();
            //   },
            //   child: const Icon(
            //     Icons.mic,
            //     size: 50,
            //   ),
            // ),
            // ElevatedButton(
            //   onPressed: () {
            //     _stopRecording();
            //   },
            //   child: const Icon(
            //     Icons.stop,
            //     size: 50,
            //   ),
            // ),

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

            ElevatedButton(
              onPressed: () {
                setState(() {
                  _playAudio = !_playAudio;
                });
                print('play');
                if (_playAudio) playFunc();
                if (!_playAudio) stopPlayFunc();
              },
              child: Icon(
                _playAudio ? Icons.stop : Icons.mic,
                size: 50,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _voicePath);
              },
              child: Icon(Icons.check),
            )
          ],
        ),
      ),
    );
  }
}
