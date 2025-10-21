import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _chunkTimer;
  bool _isRecording = false;
  String? _currentFilePath;
  int _chunkCount = 0;
  
  bool get isRecording => _isRecording;
  
  // Request microphone permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
  
  // Start recording with 5-second chunks
  Future<void> startRecording({
    required Function(Uint8List) onChunk,
    int chunkDurationSeconds = 5,
  }) async {
    if (_isRecording) {
      print('Already recording');
      return;
    }
    
    try {
      // Check permission
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        throw Exception('Microphone permission denied');
      }
      
      // Check if recording is supported
      if (!await _recorder.hasPermission()) {
        throw Exception('Recording permission not granted');
      }
      
      _isRecording = true;
      _chunkCount = 0;
      
      // Start recording in chunks
      await _startChunkRecording(onChunk, chunkDurationSeconds);
      
      print('Recording started with ${chunkDurationSeconds}s chunks');
    } catch (e) {
      print('Error starting recording: $e');
      _isRecording = false;
      rethrow;
    }
  }
  
  // Start chunk-based recording
  Future<void> _startChunkRecording(
    Function(Uint8List) onChunk,
    int chunkDurationSeconds,
  ) async {
    _chunkTimer = Timer.periodic(
      Duration(seconds: chunkDurationSeconds),
      (timer) async {
        if (!_isRecording) {
          timer.cancel();
          return;
        }
        
        try {
          // Stop current recording
          final path = await _recorder.stop();
          
          if (path != null) {
            // Read the audio file
            final file = File(path);
            final bytes = await file.readAsBytes();
            
            // Send chunk via callback
            onChunk(Uint8List.fromList(bytes));
            
            // Delete temporary file
            await file.delete();
            
            _chunkCount++;
            print('Sent audio chunk $_chunkCount (${bytes.length} bytes)');
          }
          
          // Start next chunk if still recording
          if (_isRecording) {
            await _startNextChunk();
          }
        } catch (e) {
          print('Error processing audio chunk: $e');
        }
      },
    );
    
    // Start first chunk
    await _startNextChunk();
  }
  
  // Start recording next chunk
  Future<void> _startNextChunk() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentFilePath = '${tempDir.path}/audio_chunk_$timestamp.flac';
      
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.flac,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _currentFilePath!,
      );
    } catch (e) {
      print('Error starting next chunk: $e');
      rethrow;
    }
  }
  
  // Stop recording
  Future<void> stopRecording() async {
    if (!_isRecording) {
      print('Not currently recording');
      return;
    }
    
    try {
      _isRecording = false;
      _chunkTimer?.cancel();
      _chunkTimer = null;
      
      // Stop current recording
      final path = await _recorder.stop();
      
      // Clean up last file if exists
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      print('Recording stopped after $_chunkCount chunks');
      _chunkCount = 0;
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }
  
  // Dispose resources
  Future<void> dispose() async {
    await stopRecording();
    await _recorder.dispose();
  }
}