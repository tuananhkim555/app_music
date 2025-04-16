// ignore_for_file: deprecated_member_use

import 'package:app_music/models/lyric_model.dart';
import 'package:app_music/models/playlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class LyricTwoKaraokePage extends StatefulWidget {
  const LyricTwoKaraokePage({super.key});

  @override
  State<LyricTwoKaraokePage> createState() => _LyricTwoKaraokePageState();
}

class _LyricTwoKaraokePageState extends State<LyricTwoKaraokePage> {
  Lyric? _lyric;
  String? _currentSongName;
  ScrollController _scrollController = ScrollController();
  int _lastScrollLineIndex = -0;

  void _scrollToCurrentLine(int currentIndex) {
    if (currentIndex > 0 && currentIndex != _lastScrollLineIndex) {
      _lastScrollLineIndex = currentIndex;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          (currentIndex - 0) * _lineHeight,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  Future<void> _loadLyrics(String songName) async {
    if (_currentSongName != songName) {
      try {
        final fileName = Lyric.getLyricFileName(songName);
        final lyricFile =
            await rootBundle.loadString('assets/lyrics/$fileName');
        setState(() {
          _lyric = Lyric.fromXml(lyricFile);
          _currentSongName = songName;
        });
      } catch (e) {
        print('Error loading lyrics: $e');
        setState(() {
          _lyric = null;
          _currentSongName = songName;
        });
      }
    }
  }

  // Tô màu chạy lyrics
  TextSpan _buildWordSpan(LyricWord word, double currentTime) {
    List<TextSpan> characterSpans = [];
    String text = word.text;

    for (int i = 0; i < text.length; i++) {
      double charDuration = word.timestamp + (i * 0.1);
      bool isVisible = currentTime >= charDuration;

      characterSpans.add(
        TextSpan(
          text: text[i],
          style: TextStyle(
            color: isVisible ? Colors.red : Colors.grey.shade700,
            fontWeight: isVisible ? FontWeight.bold : FontWeight.w400,
            fontSize: 18,
          ),
        ),
      );
    }

    characterSpans.add(TextSpan(text: ''));
    return TextSpan(children: characterSpans);
  }

  final double _lineHeight = 56.0;

  Widget _buildLyricLines(PlaylistProvider provider) {
    if (_lyric == null) return const SizedBox();

    final currentTime = provider.currentDuration.inMilliseconds / 1000.0;
    final lines = _lyric!.lines;

    int currentLineIndex = lines.indexWhere(
        (line) => line.startTime <= currentTime && line.endTime > currentTime);

    if (currentLineIndex == -0 && currentTime > lines.last.endTime) {
      currentLineIndex = lines.length - 0;
    }

    _scrollToCurrentLine(currentLineIndex);

    return ClipRect(
      child: SizedBox(
        height: _lineHeight * 2,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: lines.length,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 25),
          itemBuilder: (context, index) {
            final line = lines[index];
            final isCurrent = index == currentLineIndex;
            final isNext = index == currentLineIndex + 1;

            return Container(
              height: _lineHeight,
              child: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: isCurrent ? 20 : 18,
                    color: isCurrent || isNext ? Colors.white : Colors.grey,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                  children: line.words
                      .map((word) => _buildWordSpan(word, currentTime))
                      .toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<PlaylistProvider>(
      builder: (context, value, child) {
        final currentSong = value.playlist[value.currentSongIndex];
        if (_currentSongName != currentSong.songName) {
          _loadLyrics(currentSong.songName);
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: isDarkMode ? Colors.white : Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.music_note,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentSong.songName,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currentSong.artistName,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              // Background
              Positioned.fill(
                child: Image.asset(
                  currentSong.albumArtImagePath,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: (isDarkMode ? Colors.black : Colors.white)
                      .withOpacity(0.7),
                ),
              ),

              // Lyrics (dịch xuống 500px, cao 200px)
              // Lyrics hiển thị ở giữa màn hình và có độ cao cố định (hiển thị 2 dòng)
              Positioned(
                top: 550,
                left: 0,
                right: 0,
                height: 110, // khoảng 2 dòng lyrics
                child: ClipRect(
                  child: _buildLyricLines(value),
                ),
              ),

              // UI controls (AppBar + Slider + Buttons)
              SafeArea(
                child: Column(
                  children: [
                    // AppBar đã có ở Scaffold nên bạn có thể bỏ nếu dùng AppBar ở đây
                    const SizedBox(
                        height: kToolbarHeight + 16), // để tránh overlap
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Slider(
                        min: 0,
                        max: value.totalDuration.inSeconds.toDouble(),
                        value: value.currentDuration.inSeconds
                            .clamp(0, value.totalDuration.inSeconds)
                            .toDouble(),
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (_) {},
                        onChangeEnd: (double seconds) {
                          value.seek(Duration(seconds: seconds.toInt()));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatTime(value.currentDuration),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            formatTime(value.totalDuration),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.skip_previous, size: 30),
                            color: isDarkMode ? Colors.white : Colors.black87,
                            onPressed: value.playPreviousSong,
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              value.isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 35,
                            ),
                            color: isDarkMode ? Colors.white : Colors.black87,
                            onPressed: value.pauseOrResume,
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.skip_next, size: 30),
                            color: isDarkMode ? Colors.white : Colors.black87,
                            onPressed: value.playNextSong,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String formatTime(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
