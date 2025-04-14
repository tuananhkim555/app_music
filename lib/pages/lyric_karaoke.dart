import 'package:app_music/models/lyric_model.dart';
import 'package:app_music/models/playlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class LyricKaraokePage extends StatefulWidget {
  const LyricKaraokePage({super.key});

  @override
  State<LyricKaraokePage> createState() => _LyricKaraokePageState();
}

class _LyricKaraokePageState extends State<LyricKaraokePage> {
  Lyric? _lyric;
  String? _currentSongName;
  final ScrollController _scrollController = ScrollController();

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

  TextSpan _buildWordSpan(LyricWord word, double currentTime) {
    List<TextSpan> characterSpans = [];
    String text = word.text;

    for (int i = 0; i < text.length; i++) {
      // Tính toán thời gian hiển thị cho từng ký tự
      double charDuration = word.timestamp + (i * 0.1); // Giảm tốc độ chạy chữ
      bool isVisible = currentTime >= charDuration;

      characterSpans.add(
        TextSpan(
          text: text[i],
          style: TextStyle(
            color: isVisible ? Colors.red : Colors.grey.shade700,
            fontWeight: isVisible ? FontWeight.bold : FontWeight.w400,
            fontSize: 18, // Kích thước chữ nhỏ hơn
          ),
        ),
      );
    }

    // Thêm khoảng trắng giữa các từ
    characterSpans.add(TextSpan(text: ''));
    return TextSpan(children: characterSpans);
  }

  Widget _buildLyricList(PlaylistProvider provider) {
    if (_lyric == null) {
      return const Center(
        child: Text(
          'Lyrics không khả dụng',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final currentTime = provider.currentDuration.inMilliseconds / 1000.0;
    final allLines = _lyric!.lines;
    final currentLineIndex = allLines.indexWhere(
        (line) => line.startTime <= currentTime && line.endTime > currentTime);

    // Cuộn lên khi dòng hoàn thành
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentLineIndex > 0 &&
          _scrollController.hasClients &&
          _scrollController.position.maxScrollExtent >
              _scrollController.offset) {
        final targetOffset = (currentLineIndex - 1) * 40.0; // Chiều cao dòng ước tính
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: allLines.length,
      itemBuilder: (context, index) {
        final line = allLines[index];
        final isCurrentLine =
            line.startTime <= currentTime && line.endTime > currentTime;
        final isPastLine = line.endTime < currentTime;

        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width, // Giới hạn chiều rộng
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isPastLine ? 0.7 : 1.0,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 18, // Kích thước chữ cố định
                    height: 1.3,
                    color: isCurrentLine ? Colors.red : Colors.grey,
                  ),
                  children: line.words
                      .map((word) => _buildWordSpan(word, currentTime))
                      .toList(),
                ),
              ),
            ),
          ),
        );
      },
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
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: _buildLyricList(value),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                                  color:
                                      isDarkMode ? Colors.white : Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                formatTime(value.totalDuration),
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black87,
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
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                                onPressed: value.playPreviousSong,
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 35,
                                ),
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                                onPressed: value.pauseOrResume,
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.skip_next, size: 30),
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                                onPressed: value.playNextSong,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
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