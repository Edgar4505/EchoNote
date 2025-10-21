import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'path_to_your_transcription_provider.dart';

class LiveTranslateIdleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Translate'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.mic, size: 100),
            SizedBox(height: 20),
            DropdownButton<String>(
              items: <String>['French', 'English', 'Portuguese']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {},
              hint: Text('Select Language'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Integrate with TranscriptionProvider
                final provider = Provider.of<TranscriptionProvider>(context, listen: false);
                provider.startRecording();
              },
              child: Text('Start Recording'),
            ),
          ],
        ),
      ),
    );
  }
}