import 'package:web_socket_channel/io.dart';

class WebSocketService {
  final String _clientId;
  final String sourceLanguage;
  final String targetLanguage;

  WebSocketService(this._clientId, this.sourceLanguage, this.targetLanguage);

  void connect(String token) {
    final url = '${EnvConfig.wsBaseUrl}/ws/$_clientId?source=
$sourceLanguage&target=$targetLanguage';
    final channel = IOWebSocketChannel.connect(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    // Other connection logic...
  }
}