import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import '../services/api_service.dart';
import '../config/env_config.dart';
import '../widgets/bottom_nav_widget.dart';

class SessionPlaybackScreen extends StatefulWidget {
  final String sessionId;

  SessionPlaybackScreen({required this.sessionId});

  @override
  _SessionPlaybackScreenState createState() => _SessionPlaybackScreenState();
}

class _SessionPlaybackScreenState extends State<SessionPlaybackScreen> {
  late Future<String> transcript;
  late AudioPlayer audioPlayer;
  bool isOriginalText = true;

  @override
  void initState() {
    super.initState();
    transcript = fetchTranscript(widget.sessionId);
    audioPlayer = AudioPlayer();
  }

  Future<String> fetchTranscript(String sessionId) async {
    final response = await http.get(Uri.parse('https://api.example.com/session/get_transcript?session_id=
$sessionId'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['transcript'];
    } else {
      throw Exception('Failed to load transcript');
    }
  }

  void toggleText() {
    setState(() {
      isOriginalText = !isOriginalText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Session Playback')), 
      body: Column(
        children: <Widget>[
          // Display session information
          _buildSessionInfo(),
          // Transcript display with toggle
          _buildTranscriptDisplay(),
          // Audio controls
          _buildAudioControls(),
          // Action buttons
          _buildActionButtons(),
          // Bottom navigation
          BottomNavWidget(),
        ],
      ),
    );
  }

  Widget _buildSessionInfo() {
    // Placeholder for session info
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Text('Session Title, Language Pair, Duration, Date'),
    );
  }

  Widget _buildTranscriptDisplay() {
    return FutureBuilder<String>(
      future: transcript,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return GestureDetector(
            onHorizontalDragEnd: (details) => toggleText(),
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(isOriginalText ? snapshot.data! : 'Translated Text'),
            ),
          );
        }
      },
    );
  }

  Widget _buildAudioControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(icon: Icon(Icons.play_arrow), onPressed: () {}),
        IconButton(icon: Icon(Icons.pause), onPressed: () {}),
        // Add progress bar and time display here
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ElevatedButton(onPressed: () {}, child: Text('Highlight')), 
        ElevatedButton(onPressed: () {}, child: Text('Edit')), 
        ElevatedButton(onPressed: () {}, child: Text('Translate')), 
        ElevatedButton(onPressed: () {}, child: Text('Share')), 
        // Add Star and Move buttons here
        IconButton(icon: Icon(Icons.star), onPressed: () {}),
        IconButton(icon: Icon(Icons.move_to_inbox), onPressed: () {}),
      ],
    );
  }
}