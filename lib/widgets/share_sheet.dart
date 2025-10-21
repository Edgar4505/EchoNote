import 'package:flutter/material.dart';

class ShareSheet extends StatefulWidget {
  final Map<String, dynamic> session;

  ShareSheet({required this.session});

  @override
  _ShareSheetState createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  String selectedContent = 'Original';
  String selectedFormat = 'Text';
  bool includeHighlights = false;
  bool includeTimestamps = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Share',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  // TODO: Implement close functionality
                },
              ),
            ],
          ),
          SizedBox(height: 16.0),

          // Session Info Card
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Session: ${widget.session['name']}'),
                  Text('Language Pair: ${widget.session['languagePair']}'),
                  Text('Duration: ${widget.session['duration']}'),
                  Text('Date: ${widget.session['date']}'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.0),

          // Content Selection
          Text('Select Content'),
          ToggleButtons(
            children: [Text('Original'), Text('Translated'), Text('Both')],
            isSelected: [
              selectedContent == 'Original',
              selectedContent == 'Translated',
              selectedContent == 'Both',
            ],
            onPressed: (index) {
              setState(() {
                selectedContent = ['Original', 'Translated', 'Both'][index];
              });
            },
          ),
          SizedBox(height: 16.0),

          // Format Selection
          Text('Select Format'),
          ToggleButtons(
            children: [Text('Text'), Text('Audio'), Text('PDF')],
            isSelected: [
              selectedFormat == 'Text',
              selectedFormat == 'Audio',
              selectedFormat == 'PDF',
            ],
            onPressed: (index) {
              setState(() {
                selectedFormat = ['Text', 'Audio', 'PDF'][index];
              });
            },
          ),
          Text('Plain text', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 16.0),

          // Include Options
          Text('Include Options'),
          Wrap(
            children: [
              ChoiceChip(
                label: Text('Highlights'),
                selected: includeHighlights,
                onSelected: (selected) {
                  setState(() {
                    includeHighlights = selected;
                  });
                },
              ),
              ChoiceChip(
                label: Text('Timestamps'),
                selected: includeTimestamps,
                onSelected: (selected) {
                  setState(() {
                    includeTimestamps = selected;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 16.0),

          // Send To Section
          Text('Send to'),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Card(child: Center(child: Text('System Sheet'))),
              Card(child: Center(child: Text('Copy Link'))),
              Card(child: Center(child: Text('Email'))),
              Card(child: Center(child: Text('Export File'))),
              Card(child: Center(child: Text('Workspace'))),
              Card(child: Center(child: Text('Quick Send'))),
            ],
          ),
          SizedBox(height: 16.0),

          // Bottom Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement back functionality
                },
                child: Text('Back'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement share functionality
                },
                child: Text('Share'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}