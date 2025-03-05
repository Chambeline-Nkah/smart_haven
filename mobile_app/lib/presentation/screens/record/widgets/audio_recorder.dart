// lib/core/utils/audio_recorder.dart
import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class AudioRecorder {
  FlutterSoundRecorder? _recorder;
  bool _isRecorderInitialized = false;
  String? _recordingPath;

  Future<void> init() async {
    _recorder = FlutterSoundRecorder();
    
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    await _recorder!.openRecorder();
    _isRecorderInitialized = true;
  }

  Future<void> startRecording() async {
    if (!_isRecorderInitialized) return;
    
    _recordingPath = 'temp_recording.wav';
    await _recorder!.startRecorder(
      toFile: _recordingPath,
      codec: Codec.pcm16WAV,
    );
  }

  Future<List<int>> stopRecording() async {
    if (!_isRecorderInitialized) return [];
    
    await _recorder!.stopRecorder();
    if (_recordingPath != null) {
      final file = File(_recordingPath!);
      final bytes = await file.readAsBytes();
      await file.delete();
      return bytes;
    }
    return [];
  }

  Future<void> dispose() async {
    if (_isRecorderInitialized) {
      await _recorder!.closeRecorder();
      _isRecorderInitialized = false;
    }
  }
}

class RecordingPermissionException implements Exception {
  final String message;
  RecordingPermissionException(this.message);
  
  @override
  String toString() => message;
}