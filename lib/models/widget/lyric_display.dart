import 'package:app_music/models/lyric_line.dart';
import 'package:flutter/material.dart';

class LyricsDisplay extends StatelessWidget {
  final List<List<LyricWord>> lines;
  final double currentTime;

  const LyricsDisplay({super.key, required this.lines, required this.currentTime});

  int getCurrentLineIndex() {
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final start = line.first.start;
      final end = (i < lines.length - 1) ? lines[i + 1].first.start : double.infinity;

      if (currentTime >= start && currentTime < end) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    int currentLine = getCurrentLineIndex();
    int nextLine = (currentLine + 1 < lines.length) ? currentLine + 1 : currentLine;

    return Column(
      children: [
        _buildLine(lines[currentLine]),
        const SizedBox(height: 8),
        _buildLine(lines[nextLine]),
      ],
    );
  }

  Widget _buildLine(List<LyricWord> line) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: line.map((word) {
        final isActive = currentTime >= word.start;
        return Text(
          word.text,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.white70,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 18,
          ),
        );
      }).toList(),
    );
  }
}
