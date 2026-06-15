import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

class RecordingService {
  static final AudioRecorder _recorder = AudioRecorder();
  static String? _currentRecordingPath;

  static Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  static Future<void> startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    final id = const Uuid().v4();
    final path = '${dir.path}/recordings/$id.m4a';

    final recordingsDir = Directory('${dir.path}/recordings');
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }

    _currentRecordingPath = path;

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );
  }

  static Future<String?> stopRecording() async {
    final path = await _recorder.stop();
    _currentRecordingPath = null;
    return path;
  }

  static Future<void> cancelRecording() async {
    await _recorder.cancel();
    if (_currentRecordingPath != null) {
      final file = File(_currentRecordingPath!);
      if (await file.exists()) await file.delete();
    }
    _currentRecordingPath = null;
  }

  static bool get isRecording => _currentRecordingPath != null;

  static Stream<RecordState> get stateStream => _recorder.onStateChanged();

  static Stream<Amplitude> get amplitudeStream =>
      _recorder.onAmplitudeChanged(const Duration(milliseconds: 100));

  static Future<void> deleteRecordingFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  static Future<String> copyFileToAppStorage(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final id = const Uuid().v4();
    final ext = sourcePath.split('.').last;
    final destPath = '${dir.path}/recordings/$id.$ext';

    final recordingsDir = Directory('${dir.path}/recordings');
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }

    final sourceFile = File(sourcePath);
    await sourceFile.copy(destPath);
    return destPath;
  }

  static void dispose() {
    _recorder.dispose();
  }
}
