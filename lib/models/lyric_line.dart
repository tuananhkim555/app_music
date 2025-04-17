import 'package:xml/xml.dart';

class LyricWord {
  final String text;
  final double start;
  
  double duration = 0.5; // sẽ được ghi đè sau nếu có

  LyricWord({required this.text, required this.start});

  double get startTime => start;
  double get endTime => start + duration;
}

class LyricLine {
  final List<LyricWord> words;

  LyricLine({required this.words});

  double get startTime => words.first.startTime;
  double get endTime => words.last.endTime;
}

class Lyric {
  final List<LyricLine> lines;

  Lyric({required this.lines});

  static String getLyricFileName(String songName) {
    return '${songName.toLowerCase().replaceAll(' ', '_')}.xml';
  }

  static Lyric fromXml(String xmlContent) {
    final document = XmlDocument.parse(xmlContent);
    final lines = <LyricLine>[];

    for (final param in document.findAllElements('param')) {
      final words = param.findElements('i').toList();
      final lyricWords = <LyricWord>[];

      for (int i = 0; i < words.length; i++) {
        final wordElement = words[i];
        final nextElement = (i + 1 < words.length) ? words[i + 1] : null;

        final start = double.tryParse(wordElement.getAttribute('va') ?? '0') ?? 0;
        final text = wordElement.text.trim();

        final word = LyricWord(text: text, start: start);
        if (nextElement != null) {
          final nextStart = double.tryParse(nextElement.getAttribute('va') ?? '0') ?? (start + 0.5);
          word.duration = nextStart - start;
        } else {
          word.duration = 0.8; // chữ cuối cùng
        }

        lyricWords.add(word);
      }

      if (lyricWords.isNotEmpty) {
        lines.add(LyricLine(words: lyricWords));
      }
    }

    return Lyric(lines: lines);
  }
}
