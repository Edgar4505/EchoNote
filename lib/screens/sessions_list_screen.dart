import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';
import 'env_config.dart';
import 'bottom_nav_widget.dart';

class SessionsListScreen extends StatefulWidget {
  @override
  _SessionsListScreenState createState() => _SessionsListScreenState();
}

class _SessionsListScreenState extends State<SessionsListScreen> {
  List<dynamic> sessions = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    try {
      final response = await http.get(Uri.parse('${envConfig.apiBaseUrl}/session/get_last_transcripts?number_sessions=10'), headers: {
        'Authorization': 'Bearer ${envConfig.bearerToken}',
      });

      if (response.statusCode == 200) {
        setState(() {
          sessions = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sessions List')), 
      body: isLoading ? Center(child: CircularProgressIndicator()) : hasError ? Center(child: Text('Error loading sessions')) : ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return ListTile(
            leading: Icon(Icons.mic), 
            title: Text(session['name']),
            subtitle: Text(session['original_text']),
            onTap: () {
              Navigator.pushNamed(context, '/session-playback', arguments: session['id']);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchSessions,
        child: Icon(Icons.refresh),
      ),
    );
  }
}