// ignore_for_file: deprecated_member_use
import 'dart:async';

import 'package:app_music/components/my_drawer.dart';
import 'package:app_music/components/neu_box.dart';
import 'package:app_music/models/lyric_model.dart';
import 'package:app_music/models/playlist_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

class _SongPageState extends State<SongPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Lyric _lyric;
  late AudioPlayer _audioPlayer;
  late Timer _timer;
  int _currentLineIndex = 0;
  double _currentTime = 0.0;


  

  @override
  void initState() {
    super.initState();
    // Khởi tạo hiệu ứng quay album
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(); // Quay liên tục
  }

  @override
  void dispose() {
    _controller.dispose(); // Hủy animation
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, value, child) {
        final playList = value.playlist;
        final currentSong = playList[value.currentSongIndex];

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  // Header điều hướng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
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
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          // Mở menu hoặc drawer nếu cần
                           Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const MyDrawer(),
                           ));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tên bài hát + ca sĩ
                  Column(
                    children: [
                      Text(
                        currentSong.songName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currentSong.artistName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Ảnh album quay tròn
                  NeuBox(
                    child: RotationTransition(
                      turns: _controller,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(180),
                        child: Image.asset(
                          currentSong.albumArtImagePath,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Thời lượng + nút shuffle + repeat
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Thời gian hiện tại (cố định chiều rộng)
                            SizedBox(
                              width: 40, // đủ chứa "00:00"
                              child: Text(formatTime(value.currentDuration)),
                            ),

                            // Nút shuffle
                            IconButton(
                              icon: Icon(
                                Icons.shuffle,
                                color:
                                    value.isShuffle ? Colors.deepOrange : Colors.grey,
                              ),
                              onPressed: value.toggleShuffle,
                            ),

                            // Nút repeat
                            IconButton(
                              icon: Icon(
                                Icons.repeat,
                                color:
                                    value.isRepeat ? Colors.deepOrange : Colors.grey,
                              ),
                              onPressed: value.toggleRepeat,
                            ),

                            // Tổng thời lượng (cố định chiều rộng)
                            SizedBox(
                              width: 40, // đủ chứa "00:00"
                              child: Text(
                                formatTime(value.totalDuration),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Slider tiến trình
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 0,
                          ),
                        ),
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
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Nút điều khiển phát nhạc
                  Row(
                    children: [
                      // Trước
                      Expanded(
                        child: GestureDetector(
                          onTap: value.playPreviousSong,
                          child: NeuBox(
                            child: Icon(Icons.skip_previous),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Phát / dừng
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: value.pauseOrResume,
                          child: NeuBox(
                            child: Icon(value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Sau
                      Expanded(
                        child: GestureDetector(
                          onTap: value.playNextSong,
                          child: NeuBox(
                            child: Icon(Icons.skip_next),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
