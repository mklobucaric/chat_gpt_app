import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';

class VoiceRecorder extends StatefulWidget {
  const VoiceRecorder({Key? key}) : super(key: key);

  @override
  _VoiceRecorderState createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder> {
  final _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String _voicePath = '';
  bool _playAudio = false;
  String pathToAudio = 'sdcard/Download/voicePrompt.mp4';

  final recordingPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    initVoiceRecorder();
  }

  Future<void> _startRecording() async {
    try {
      await _recorder.startRecorder(
          //    toFile: 'voicePrompt.mp4',
          toFile: 'sdcard/Download/voicePrompt.mp4',
          //       codec: Codec.aacADTS,
          codec: Codec.aacMP4);
    } catch (e) {
      print('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      //    final voicePath = await _recorder.stopRecorder();
      final voicePath = await _recorder.stopRecorder();
      final audioVoicePath = File(voicePath!);
      setState(() {
        _voicePath = audioVoicePath.path;
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
    await _recorder.openRecorder();
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
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
            StreamBuilder<RecordingDisposition>(
              stream: _recorder.onProgress,
              builder: (context, snapshot) {
                final disposition = snapshot.data;
                return Text(
                    'Recording disposition: ${disposition?.toString() ?? 'Unkown'}');
              },
            ),
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
