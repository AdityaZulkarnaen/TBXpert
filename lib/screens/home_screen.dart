import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../services/api_service.dart';
import '../widgets/result_sheet.dart';

enum RecordingPhase { idle, recording, analyzing }

/// Main screen: mic button to record a cough, then show the prediction.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _maxSeconds = 10;

  final AudioRecorder _recorder = AudioRecorder();
  final ApiService _api = ApiService();

  RecordingPhase _phase = RecordingPhase.idle;
  int _elapsedSeconds = 0;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _onMicTap() async {
    switch (_phase) {
      case RecordingPhase.idle:
        await _startRecording();
      case RecordingPhase.recording:
        await _stopAndAnalyze();
      case RecordingPhase.analyzing:
        break; // button is disabled in this phase
    }
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Microphone permission is required to record a cough sample.',
          ),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: openAppSettings,
          ),
        ),
      );
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/cough_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      if (!mounted) return;
      setState(() {
        _phase = RecordingPhase.recording;
        _elapsedSeconds = 0;
      });

      // 1s ticker drives the visible timer and auto-stops at the cap.
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _elapsedSeconds++);
        if (_elapsedSeconds >= _maxSeconds) {
          _stopAndAnalyze();
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not start recording.')),
      );
      setState(() => _phase = RecordingPhase.idle);
    }
  }

  Future<void> _stopAndAnalyze() async {
    if (_phase != RecordingPhase.recording) return;
    _ticker?.cancel();
    _ticker = null;

    String? path;
    try {
      path = await _recorder.stop();
    } catch (_) {
      path = null;
    }

    if (path == null) {
      if (!mounted) return;
      setState(() {
        _phase = RecordingPhase.idle;
        _elapsedSeconds = 0;
      });
      return;
    }

    setState(() => _phase = RecordingPhase.analyzing);

    try {
      final result = await _api.uploadCoughAudio(path);
      if (!mounted) return;
      _showResult(result);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to analyze. Check your connection and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _phase = RecordingPhase.idle;
          _elapsedSeconds = 0;
        });
      }
    }
  }

  void _showResult(PredictionResult result) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ResultSheet(
        result: result,
        onTryAgain: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isRecording = _phase == RecordingPhase.recording;
    final bool isAnalyzing = _phase == RecordingPhase.analyzing;

    final Color micColor =
        isRecording ? Colors.red.shade600 : const Color(0xFF00897B);
    final IconData micIcon = isRecording ? Icons.stop : Icons.mic;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text(
                'Cough-based TB Screening',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: isAnalyzing ? null : _onMicTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: micColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: micColor.withValues(alpha: 0.3),
                        blurRadius: isRecording ? 28 : 16,
                        spreadRadius: isRecording ? 6 : 0,
                      ),
                    ],
                  ),
                  child: Icon(micIcon, color: Colors.white, size: 72),
                ),
              ),
              const SizedBox(height: 32),
              _StatusText(
                phase: _phase,
                elapsedSeconds: _elapsedSeconds,
                maxSeconds: _maxSeconds,
              ),
              const Spacer(),
              Text(
                'For screening only — not a medical diagnosis.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  final RecordingPhase phase;
  final int elapsedSeconds;
  final int maxSeconds;

  const _StatusText({
    required this.phase,
    required this.elapsedSeconds,
    required this.maxSeconds,
  });

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case RecordingPhase.idle:
        return Text(
          'Tap to record your cough (max ${maxSeconds}s)',
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        );
      case RecordingPhase.recording:
        return Text(
          '$elapsedSeconds / ${maxSeconds}s',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade600,
          ),
        );
      case RecordingPhase.analyzing:
        return const Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(
              'Analyzing cough sound...',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        );
    }
  }
}
