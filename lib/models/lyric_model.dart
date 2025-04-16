import 'package:xml/xml.dart';

// Map song names to their lyric file names
const Map<String, String> songLyricMap = {
  'Về đâu mái tóc người thương': 'song1',
  'Lạc Lối': 'lacloi',
  // Add more mappings here as needed
};

class LyricWord {
  final String text;
  final double timestamp;
  double duration; // 👈 thêm duration

  LyricWord(this.text, this.timestamp, {this.duration = 0.5});

  double get startTime => timestamp; // 👈 alias getter để tránh lỗi
}

class LyricLine {
  final List<LyricWord> words;

  LyricLine(this.words);

  double get startTime => words.first.timestamp;
  double get endTime {
    if (words.isEmpty) return startTime;
    final last = words.last;
    return last.timestamp + last.duration; // 👈 cộng thêm duration
  }

  String getFullText() => words.map((word) => word.text).join('');
}

class Lyric {
  final List<LyricLine> lines;

  Lyric({required this.lines});

  static String getLyricFileName(String songName) {
    if (songLyricMap.containsKey(songName)) {
      return '${songLyricMap[songName]}.xml';
    }
    final lowerSongName = songName.toLowerCase();
    for (var entry in songLyricMap.entries) {
      if (entry.key.toLowerCase() == lowerSongName) {
        return '${entry.value}.xml';
      }
    }
    return '${songName.toLowerCase().replaceAll(' ', '_')}.xml';
  }

  factory Lyric.fromXml(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final lines = <LyricLine>[];

    for (var param in document.findAllElements('param')) {
      final wordElements = param.findElements('i').toList();
      final words = <LyricWord>[];

      for (int i = 0; i < wordElements.length; i++) {
        final current = wordElements[i];
        final text = current.text;
        final time = double.parse(current.getAttribute('va') ?? '0');

        // 👇 tính duration từ thời điểm của từ tiếp theo
        double duration = 0.5;
        if (i + 1 < wordElements.length) {
          final nextTime = double.tryParse(wordElements[i + 1].getAttribute('va') ?? '') ?? (time + 0.5);
          duration = nextTime - time;
        }

        words.add(LyricWord(text, time, duration: duration));
      }

      if (words.isNotEmpty) {
        lines.add(LyricLine(words));
      }
    }

    return Lyric(lines: lines);
  }

  List<LyricLine> getNextTwoLines(double currentTime) {
    final result = <LyricLine>[];

    for (var line in lines) {
      if (line.startTime > currentTime && result.length < 2) {
        result.add(line);
      }
    }

    while (result.length < 2) {
      result.add(LyricLine([]));
    }

    return result;
  }

  LyricLine? getLineAtTime(double timestamp) {
    for (var line in lines) {
      if (timestamp >= line.startTime && timestamp <= line.endTime) {
        return line;
      }
    }
    return null;
  }

  List<LyricLine> getAllLines() {
    final allLines = List<LyricLine>.from(lines);
    allLines.sort((a, b) => a.startTime.compareTo(b.startTime));
    return allLines;
  }
}
