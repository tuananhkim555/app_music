// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:app_music/components/my_drawer.dart';
import 'package:app_music/components/neu_box.dart';
import 'package:app_music/models/lyric_model.dart';
import 'package:app_music/models/playlist_provider.dart';
import 'package:app_music/pages/lyric_karaoke.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// Hàm format thời gian kiểu mm:ss
String formatTime(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

class SongPage extends StatefulWidget {
  const SongPage({super.key});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Lyric? _lyric;
  String? _currentSongName; // Biến để lưu tên bài hát hiện tại

  Future<void> _loadLyrics(String songName) async {
    try {
      print('Attempting to load lyrics for song: $songName');
      final fileName = Lyric.getLyricFileName(songName);
      print('Generated filename: $fileName');
      final lyricFile = await rootBundle.loadString('assets/lyrics/$fileName');
      setState(() {
        _lyric = Lyric.fromXml(lyricFile);
      });
    } catch (e) {
      print('Error loading lyrics: $e');
      print('Song name was: $songName');
      print('Mapped file name was: ${Lyric.getLyricFileName(songName)}');
    }
  }

  // Hiệu ứng lyrics
  Widget _buildLyricSection(PlaylistProvider provider) {
  if (_lyric == null || _lyric!.lines.isEmpty) {
    return const Center(child: Text("Không có lời bài hát"));
  }

  final currentTime = provider.currentDuration.inMilliseconds / 1000.0;
  final currentLine = _lyric!.getLineAtTime(currentTime);
  final nextLines = _lyric!.getNextTwoLines(currentTime);
  final nextLine = nextLines.isNotEmpty ? nextLines.firstOrNull : null;

  // Lấy chiều rộng màn hình
  final screenWidth = MediaQuery.of(context).size.width;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Dòng lyric hiện tại
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
        child: SizedBox(
          width: screenWidth * 0.9, // Chiếm 90% chiều rộng màn hình
          child: Text(
            currentLine?.words.map((w) => w.text).join('') ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      // Dòng lyric tiếp theo
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
        child: SizedBox(
          width: screenWidth * 0.9, // Chiếm 90% chiều rộng màn hình
          child: Text(
            nextLine?.words.map((w) => w.text).join('') ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onBackground
                  .withOpacity(0.5),
              fontSize: 16,
            ),
          ),
        ),
      ),
    ],
  );
}
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, value, child) {
        final playList = value.playlist;
        final currentSong = playList[value.currentSongIndex];

        // Kiểm tra nếu bài hát hiện tại khác với bài hát trước đó
        if (_currentSongName != currentSong.songName) {
          _currentSongName = currentSong.songName; // Cập nhật tên bài hát hiện tại
          _loadLyrics(currentSong.songName); // Tải lại lyrics
        }

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 10, 25, 25),
              child: Column(
                children: [
                  // Header section with reduced vertical spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.arrow_back, size: 24),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        "P L A Y L I S T",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.menu, size: 24),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MyDrawer()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Song info with reduced spacing
                  Column(
                    children: [
                      Text(
                        currentSong.songName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentSong.artistName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Album art with adjusted size
                  NeuBox(
                    child: RotationTransition(
                      turns: _controller,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(160),
                        child: Image.asset(
                          currentSong.albumArtImagePath,
                          width: 240,
                          height: 240,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Expanded lyrics section
                  Expanded(
                    flex: 2,
                    child: _buildLyricSection(value),
                  ),
                  // Player controls with reduced spacing
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Time and controls row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 35,
                              child: Text(
                                formatTime(value.currentDuration),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    Icons.shuffle,
                                    size: 24,
                                    color: value.isShuffle ? Colors.deepOrange : Colors.grey,
                                  ),
                                  onPressed: value.toggleShuffle,
                                ),
                                const SizedBox(width: 15),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    Icons.repeat,
                                    size: 24,
                                    color: value.isRepeat ? Colors.deepOrange : Colors.grey,
                                  ),
                                  onPressed: value.toggleRepeat,
                                ),
                                const SizedBox(width: 15),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.queue_music,
                                    size: 24,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LyricKaraokePage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 35,
                              child: Text(
                                formatTime(value.totalDuration),
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Progress slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                        ),
                        child: Slider(
                          min: 0,
                          max: value.totalDuration.inSeconds.toDouble(),
                          value: value.currentDuration.inSeconds.clamp(0, value.totalDuration.inSeconds).toDouble(),
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: (_) {},
                          onChangeEnd: (double seconds) {
                            value.seek(Duration(seconds: seconds.toInt()));
                          },
                        ),
                      ),
                      // Playback controls
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: value.playPreviousSong,
                                child: const NeuBox(
                                  child: Icon(Icons.skip_previous, size: 24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: value.pauseOrResume,
                                child: NeuBox(
                                  child: Icon(
                                    value.isPlaying ? Icons.pause : Icons.play_arrow,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: GestureDetector(
                                onTap: value.playNextSong,
                                child: const NeuBox(
                                  child: Icon(Icons.skip_next, size: 24),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}