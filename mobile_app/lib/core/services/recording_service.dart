import 'package:flutter/widgets.dart';

class RecordingProvider extends ChangeNotifier {
  String? recordingPath;
  bool hasRecording = false;
  
  void setRecording(String path) {
    recordingPath = path;
    hasRecording = true;
    notifyListeners();
  }
  
  void clearRecording() {
    recordingPath = null;
    hasRecording = false;
    notifyListeners();
  }
}