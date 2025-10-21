import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart'; // Add dependency for speech recognition
import 'package:translator/translator.dart'; // Add dependency for translation

class LiveTranslateRecordingScreen extends StatefulWidget {
  @override
  _LiveTranslateRecordingScreenState createState() => _LiveTranslateRecordingScreenState();
}

class _LiveTranslateRecordingScreenState extends State<LiveTranslateRecordingScreen> {
  SpeechToText _speech;  
  bool _isRecording = false;  
  String _originalText = '';  
  String _translatedText = '';  
  final translator = GoogleTranslator();

  @override  
  void initState() {
    super.initState();
    _speech = SpeechToText();
  }

  void _startRecording() async {
    _isRecording = true;
    await _speech.initialize();
    _speech.listen(onResult: (result) {
      setState(() {
        _originalText = result.recognizedWords;
      });
      _translateText(_originalText);
    });
  }

  void _stopRecording() async {
    _isRecording = false;
    await _speech.stop();
    setState(() {});
  }

  void _translateText(String text) async {
    var translation = await translator.translate(text, to: 'es'); // Example: translating to Spanish
    setState(() {
      _translatedText = translation.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Translate Recording')), 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text('Recording Status: ${_isRecording ? 'Recording...' : 'Stopped'}'),
            SizedBox(height: 20),
            Text('Original Text:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: SingleChildScrollView(child: Text(_originalText))),
            SizedBox(height: 20),
            Text('Translated Text:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: SingleChildScrollView(child: Text(_translatedText))),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
          ],
        ),
      ),
    );
  }
}