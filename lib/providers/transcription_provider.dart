import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/websocket_service.dart';
import '../services/audio_service.dart';

class TranscriptionProvider extends ChangeNotifier {
  final WebSocketService _wsService = WebSocketService();
  final AudioService _audioService = AudioService();
  
  bool _isRecording = false;
  bool _isConnected = false;
  String _sourceLanguage = 'fr';
  String _targetLanguage = 'en';
  
  String _transcription = '';
  String _translation = '';
  
  List<Map<String, String>> _transcriptionHistory = [];
  
  bool get isRecording => _isRecording;
  bool get isConnected => _isConnected;
  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  String get transcription => _transcription;
  String get translation => _translation;
  List<Map<String, String>> get transcriptionHistory => _transcriptionHistory;
  
  // Set languages
  void setLanguages(String source, String target) {
    _sourceLanguage = source;
    _targetLanguage = target;
    notifyListeners();
  }
  
  // Start recording and transcription
  Future<void> startRecording() async {
    try {
      // Connect to WebSocket
      await _wsService.connect(
        sourceLanguage: _sourceLanguage,
        targetLanguage: _targetLanguage,
      );
      
      _isConnected = true;
      notifyListeners();
      
      // Listen to WebSocket messages
      _wsService.messages.listen((message) {
        _handleWebSocketMessage(message);
      });
      
      // Start audio recording with chunk callback
      await _audioService.startRecording(
        onChunk: (Uint8List audioData) {
          // Send audio chunk to WebSocket
          _wsService.sendAudio(audioData);
        },
        chunkDurationSeconds: 5,
      );
      
      _isRecording = true;
      notifyListeners();
      
      print('Recording and transcription started');
    } catch (e) {
      print('Error starting recording: $e');
      _isRecording = false;
      _isConnected = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // Handle WebSocket messages
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    try {
      if (message['type'] == 'transcription') {
        _transcription = message['text'] ?? '';
        notifyListeners();
      } else if (message['type'] == 'translation') {
        _translation = message['text'] ?? '';
        
        // Add to history when both transcription and translation are complete
        if (_transcription.isNotEmpty && _translation.isNotEmpty) {
          _transcriptionHistory.add({
            'transcription': _transcription,
            'translation': _translation,
          });
        }
        
        notifyListeners();
      } else if (message['type'] == 'error') {
        print('WebSocket error: ${message['message']}');
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }
  
  // Stop recording and transcription
  Future<void> stopRecording() async {
    try {
      await _audioService.stopRecording();
      await _wsService.disconnect();
      
      _isRecording = false;
      _isConnected = false;
      
      notifyListeners();
      
      print('Recording and transcription stopped');
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }
  
  // Clear current transcription and translation
  void clearCurrent() {
    _transcription = '';
    _translation = '';
    notifyListeners();
  }
  
  // Clear history
  void clearHistory() {
    _transcriptionHistory.clear();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _audioService.dispose();
    _wsService.dispose();
    super.dispose();
  }
}