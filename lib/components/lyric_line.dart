import 'package:xml/xml.dart';

class LyricWord {
  final String text;
  final double start;

  LyricWord({required this.text, required this.start});
}

List<List<LyricWord>> parseLyrics(String xmlContent) {
  final document = XmlDocument.parse(xmlContent);
  final lines = <List<LyricWord>>[];

  for (final param in document.findAllElements('param')) {
    final line = <LyricWord>[];
    for (final word in param.findElements('i')) {
      final time = double.tryParse(word.getAttribute('va') ?? '0') ?? 0;
      final text = word.text;
      line.add(LyricWord(text: text, start: time));
    }
    lines.add(line);
  }
  return lines;
}
