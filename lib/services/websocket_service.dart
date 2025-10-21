import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../config/env_config.dart';
import 'api_service.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  String? _clientId;
  
  Stream<Map<String, dynamic>> get messages => _messageController!.stream;
  bool get isConnected => _channel != null;
  
  // Connect to WebSocket with authentication
  Future<void> connect({
    String sourceLanguage = 'fr',
    String targetLanguage = 'en',
  }) async {
    try {
      // Get auth token
      final token = await ApiService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      // Generate client ID
      _clientId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Build WebSocket URL with query parameters (without token)
      final wsUrl = '${EnvConfig.wsBaseUrl}/ws/$_clientId?source=$sourceLanguage&target=$targetLanguage';
      
      print('Connecting to WebSocket: $wsUrl');
      
      // Create WebSocket connection with Authorization header
      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      // Create message stream controller
      _messageController = StreamController<Map<String, dynamic>>.broadcast();
      
      // Listen to incoming messages
      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            _messageController!.add(data);
          } catch (e) {
            print('Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          _messageController!.addError(error);
        },
        onDone: () {
          print('WebSocket connection closed');
          _messageController!.close();
        },
      );
      
      print('WebSocket connected successfully');
    } catch (e) {
      print('Failed to connect WebSocket: $e');
      throw e;
    }
  }
  
  // Send audio data (FLAC bytes)
  void sendAudio(Uint8List audioData) {
    if (_channel != null && isConnected) {
      try {
        // Send audio bytes directly
        _channel!.sink.add(audioData);
      } catch (e) {
        print('Error sending audio data: $e');
      }
    } else {
      print('WebSocket not connected, cannot send audio');
    }
  }
  
  // Disconnect WebSocket
  Future<void> disconnect() async {
    try {
      await _channel?.sink.close();
      await _messageController?.close();
      _channel = null;
      _messageController = null;
      _clientId = null;
      print('WebSocket disconnected');
    } catch (e) {
      print('Error disconnecting WebSocket: $e');
    }
  }
  
  // Dispose resources
  void dispose() {
    disconnect();
  }
}