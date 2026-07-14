// lib/services/call_service.dart

import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/communication_model.dart';

class CallService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _recordingPath;

  Future<bool> checkCallPermission() async {
    final status = await Permission.phone.request();
    return status.isGranted;
  }

  Future<bool> checkRecordingPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> makeCall(String phoneNumber) async {
    try {
      final hasPermission = await checkCallPermission();
      if (!hasPermission) {
        return false;
      }

      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Make call error: $e');
      return false;
    }
  }

  Future<void> startRecording() async {
    try {
      final hasPermission = await checkRecordingPermission();
      if (!hasPermission) {
        print('❌ No recording permission');
        return;
      }

      if (await _recorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        _recordingPath = '${directory.path}/call_recording_$timestamp.m4a';
        
        await _recorder.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            sampleRate: 44100,
            numChannels: 1,
          ),
          path: _recordingPath!,
        );
        print('🎙️ Recording started: $_recordingPath');
      }
    } catch (e) {
      print('❌ Start recording error: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await _recorder.stop();
      if (path != null) {
        print('🎙️ Recording stopped: $path');
        _recordingPath = path;
      }
    } catch (e) {
      print('❌ Stop recording error: $e');
    }
  }

  Future<String?> getRecordingPath() async {
    if (_recordingPath == null) return null;
    final file = File(_recordingPath!);
    if (await file.exists()) {
      return _recordingPath;
    }
    return null;
  }

  Future<void> deleteRecording() async {
    try {
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
          print('🗑️ Recording deleted: $_recordingPath');
        }
      }
    } catch (e) {
      print('❌ Delete recording error: $e');
    }
  }

  String suggestBestTime() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 9 && hour < 12) {
      return 'الصباح (9-12) هو أفضل وقت للاتصال';
    } else if (hour >= 16 && hour < 20) {
      return 'المساء (4-8) هو أفضل وقت للاتصال';
    } else if (hour >= 12 && hour < 16) {
      return 'بعد الظهر (12-4) مناسب جداً';
    } else {
      return 'يفضل الاتصال في الأوقات المعتادة (9 صباحاً - 8 مساءً)';
    }
  }

  String analyzeCallTime(DateTime callTime, int duration) {
    final now = DateTime.now();
    final diff = now.difference(callTime);

    if (diff.inDays < 1) {
      return 'مكالمة اليوم';
    } else if (diff.inDays < 7) {
      return 'منذ ${diff.inDays} أيام';
    } else {
      return 'مكالمة قديمة';
    }
  }

  Map<String, dynamic> getCallStats(List<CallInfo> calls) {
    final total = calls.length;
    final completed = calls.where((c) => c.status == CallStatus.completed).length;
    final missed = calls.where((c) => c.status == CallStatus.missed).length;
    final avgDuration = total > 0 
        ? calls.fold<int>(0, (sum, c) => sum + c.duration) ~/ total
        : 0;

    return {
      'total': total,
      'completed': completed,
      'missed': missed,
      'average_duration': avgDuration,
      'success_rate': total > 0 ? (completed / total) * 100 : 0,
    };
  }
}