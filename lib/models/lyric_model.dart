import 'package:xml/xml.dart';

class Lyric {
  final List<LyricLine> lines;

  Lyric({required this.lines});

  factory Lyric.fromXml(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final lines = document.findAllElements('param').map((param) {
      final lyrics = param.findElements('i').map((i) {
        final time = double.parse(i.getAttribute('va')!);
        final text = i.text;
        return LyricLine(time: time, text: text);
      }).toList();
      return lyrics;
    }).expand((x) => x).toList();

    return Lyric(lines: lines);
  }
}

class LyricLine {
  final double time;
  final String text;

  LyricLine({required this.time, required this.text});
}
