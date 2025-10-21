import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'your_project/api_service.dart'; // Adjust import as necessary
import 'your_project/env_config.dart'; // Adjust import as necessary

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<dynamic> _messageController = StreamController<dynamic>();
  String? _clientId;

  Future<void> connect(String sourceLanguage, String targetLanguage) async {
    final token = await ApiService.getToken(); // Assuming ApiService has a method to get the token
    _clientId = _generateClientId();
    final wsUrl = '${EnvConfig.wsBaseUrl}/ws/$_clientId?source=
$sourceLanguage&target=$targetLanguage';

    _channel = IOWebSocketChannel.connect(
      Uri.parse(wsUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    _channel!.stream.listen((message) {
      _messageController.add(jsonDecode(message));
    });
  }

  Uint8List sendAudio(Uint8List audioBytes) {
    _channel?.sink.add(audioBytes);
  }

  void disconnect() {
    _channel?.sink.close();
  }

  void dispose() {
    _messageController.close();
    disconnect();
  }

  String _generateClientId() {
    // Implement your clientId generation logic here
    return 'client_${DateTime.now().millisecondsSinceEpoch}';
  }

  Stream<dynamic> get messages => _messageController.stream;
}