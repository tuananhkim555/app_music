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

  LyricWord(this.text, this.timestamp);
}

class LyricLine {
  final List<LyricWord> words;

  LyricLine(this.words);

  double get startTime => words.first.timestamp;
  double get endTime => words.last.timestamp;


  String getFullText() => words.map((word) => word.text).join('');
}

class Lyric {
  final List<LyricLine> lines;

  Lyric({required this.lines});

  static String getLyricFileName(String songName) {
    // First try exact match
    if (songLyricMap.containsKey(songName)) {
      return '${songLyricMap[songName]}.xml';
    }
    // If no exact match, try case-insensitive match
    final lowerSongName = songName.toLowerCase();
    for (var entry in songLyricMap.entries) {
      if (entry.key.toLowerCase() == lowerSongName) {
        return '${entry.value}.xml';
      }
    }
    // Fallback to the default naming convention
    return '${songName.toLowerCase().replaceAll(' ', '_')}.xml';
  }

  factory Lyric.fromXml(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final lines = <LyricLine>[];

    for (var param in document.findAllElements('param')) {
      final words = <LyricWord>[];
      for (var word in param.findElements('i')) {
        final time = double.parse(word.getAttribute('va')!);
        final text = word.text;
        words.add(LyricWord(text, time));
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

  // Thêm method để lấy tất cả các dòng lyrics
  List<LyricLine> getAllLines() {
    List<LyricLine> allLines = [];
    // Sắp xếp các dòng theo thời gian
    for (var line in lines) {
      allLines.add(line);
    }
    allLines.sort((a, b) => a.startTime.compareTo(b.startTime));
    return allLines;
  }
}


