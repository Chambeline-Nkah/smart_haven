// lib/presentation/screens/record/record_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_haven/core/theme/theme.provider.dart';
import 'package:smart_haven/presentation/navigation/app_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({Key? key}) : super(key: key);

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen>
    with SingleTickerProviderStateMixin {
  final Record _recorder = Record();
  final ApiService _apiService = ApiService();
  RecorderController? _recorderController;
  late AnimationController _animationController;
  bool _showInitialText = true;
  String? _recordingPath;
  bool _isRecording = false;
  bool _hasRecording = false;
  bool _isSending = false;
  int _selectedIndex = 1;
  bool _isPlaying = false;
  String? _sendError;

  String? _error;
  List<MessageItem> _messages = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    try {
      if (await Permission.microphone.request().isGranted) {
        _recorderController = RecorderController()
          ..androidEncoder = AndroidEncoder.aac
          ..androidOutputFormat = AndroidOutputFormat.mpeg4
          ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
          ..sampleRate = 44100;
      } else {
        setState(() => _error = 'Microphone permission denied');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _startRecording() async {
    setState(() => _showInitialText = false);
    _animationController.repeat(reverse: true);
    try {
      final directory = await getTemporaryDirectory();
      _recordingPath = '${directory.path}/${const Uuid().v4()}.m4a';

      await _recorder.start(
        path: _recordingPath!,
        encoder: Platform.isIOS ? AudioEncoder.aacLc : AudioEncoder.aacHe,
        bitRate: 128000,
        samplingRate: 44100,
      );

      setState(() => _isRecording = true);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _stopRecording() async {
    _animationController.stop();
    try {
      await _recorder.stop();
      setState(() {
        _isRecording = false;
        _hasRecording = true;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _sendRecording() async {
    if (_recordingPath == null) return;

    setState(() => _isSending = true);

    try {
      final file = File(_recordingPath!);
      final bytes = await file.readAsBytes();

      // Upload recording
      final processedId =
          await _apiService.uploadAudioRecording(bytes.toList());

      // Add user message
      final userMessage = MessageItem(
        content: 'Audio recording sent',
        timestamp: DateTime.now(),
        isUser: true,
        isDelivered: true,
      );
      setState(() => _messages.add(userMessage));

      // Get AI analysis
      final analysis = await _apiService.getAiAnalysis(processedId);

      // Add AI response
      final aiMessage = MessageItem(
        content: analysis,
        timestamp: DateTime.now(),
        isUser: false,
      );
      setState(() => _messages.add(aiMessage));

      // Save to history
      await _apiService.saveToHistory(processedId, analysis);

      // Clean up
      await file.delete();
      setState(() {
        _hasRecording = false;
        _isSending = false;
        _recordingPath = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSending = false;
      });
    }
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _recorderController?.stop();
    } else {
      await _recorderController?.record();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _onNavItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRouter.record);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRouter.history);
        break;
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    _animationController.dispose();
    _recorderController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Platform.isIOS
            ? CupertinoPageScaffold(
                backgroundColor: Colors.transparent,
                child: _buildContent(themeProvider),
              )
            : Scaffold(
                body: _buildContent(themeProvider),
                bottomNavigationBar: _buildNavigationBar(),
              );
      },
    );
  }

  Widget _buildContent(ThemeProvider themeProvider) {
    return Stack(
      children: [
        _buildBackground(themeProvider.isDarkMode),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildHeader(themeProvider),
              ),
              if (_error != null)
                _buildError()
              else
                Expanded(
                  child: _messages.isEmpty
                      ? _buildEmptyState()
                      : _buildMessagesList(),
                ),
              _buildBottomSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackground(bool isDark) {
    final size = MediaQuery.of(context).size;
     final brightness = MediaQuery.platformBrightnessOf(context);
    final systemIsDark = brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          systemIsDark
              ? 'lib/assets/images/bg_dark_mode.png'
              : 'lib/assets/images/bg_light_mode.png',
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 0,
          right: 0,
          width: size.width * 0.3,
          child: Image.asset(
            'lib/assets/images/top_onboard.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Image.asset(
                     ThemeProvider().isDarkMode
                        ? 'lib/assets/images/logo_dark.png'
                        : 'lib/assets/images/logo_light.png',
                      height: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SmartHaven',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              // Change this based on screen
              'Recording', // or 'Record' or 'History'
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              'Record a live feed and get feedback', // Change subtitle based on screen
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w100,
                  ),
            ),
          ],
        ),
        // Top decoration - positioned behind the theme toggle
        // Positioned(
        //   top: -20, // Adjust based on your needs
        //   right: 0,
        //   width: size.width * 0.3,
        //   child: Image.asset(
        //     'lib/assets/images/top_onboard.png',
        //     fit: BoxFit.contain,
        //   ),
        // ),
        // Theme toggle - positioned on top
        // Positioned(
        //   top: size.height * 0.1, // Adjust based on your needs
        //   right: 16,
        //   child: IconButton(
        //     icon: Icon(
        //       themeProvider.isDarkMode
        //           ? Icons.wb_sunny
        //           : Icons.nightlight_round,
        //     ),
        //     onPressed: themeProvider.toggleTheme,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return AnimatedOpacity(
      opacity: _showInitialText ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Record Audio',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Press and hold to start recording',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.red.withOpacity(_animationController.value),
              width: 4,
            ),
          ),
          child: const Icon(Icons.mic, size: 48, color: Colors.red),
        );
      },
    );
  }

  Widget _buildRecordButton() {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        color: _isRecording ? Colors.red : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.mic,
        size: 32,
        color: _isRecording ? Colors.white : AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeRecorder,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return MessageBubble(message: message);
      },
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_hasRecording)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: _togglePlayback,
                  ),
                  Expanded(
                    child: AudioWaveforms(
                      enableGesture: true,
                      size: const Size(double.infinity, 50),
                      waveStyle: WaveStyle(
                        waveColor: AppTheme.primaryColor,
                        showMiddleLine: false,
                      ),
                      recorderController: _recorderController!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (_isSending)
                    const CircularProgressIndicator()
                  else
                    Row(
                      children: [
                        if (_sendError != null)
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _sendRecording,
                          ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sendRecording,
                        ),
                      ],
                    ),
                ],
              ),
            )
          else
            GestureDetector(
              onLongPressStart: (_) => _startRecording(),
              onLongPressEnd: (_) => _stopRecording(),
              child: _isRecording
                  ? _buildRecordingIndicator()
                  : _buildRecordButton(),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.dashboard, 'Dashboard'),
              _buildNavItem(1, Icons.mic, 'Record'),
              _buildNavItem(2, Icons.history, 'History'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = index == _selectedIndex;

    return InkWell(
      onTap: () => _onNavItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageItem {
  final String content;
  final DateTime timestamp;
  final bool isUser;
  final bool isDelivered;

  MessageItem({
    required this.content,
    required this.timestamp,
    required this.isUser,
    this.isDelivered = false,
  });
}

class MessageBubble extends StatelessWidget {
  final MessageItem message;

  const MessageBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser
              ? AppTheme.primaryColor
              : (isDark ? Colors.white12 : Colors.white),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: message.isUser
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: message.isUser
                        ? Colors.white70
                        : (isDark ? Colors.white54 : Colors.black54),
                  ),
                ),
                if (message.isUser && message.isDelivered) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 16,
                    color: Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
