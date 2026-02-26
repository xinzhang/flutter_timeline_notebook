import 'package:flutter/material.dart';
import 'screens/timeline_screen.dart';

void main() {
  runApp(const TimelineNotebookApp());
}

class TimelineNotebookApp extends StatelessWidget {
  const TimelineNotebookApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timeline Notebook',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const TimelineScreen(),
    );
  }
}
