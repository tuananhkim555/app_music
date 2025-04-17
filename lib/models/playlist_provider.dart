import 'dart:math';
import 'package:app_music/models/song.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlaylistProvider extends ChangeNotifier {
  // Danh sách bài hát
  final List<Song> _playlist = [
    Song(
      songName: "Về đâu mái tóc người thương",
      artistName: "Quang Lê",
      albumArtImagePath: "assets/images/vedaumaitocnguoithuong.webp",
      audioPath: "audio/beat.mp3",
    ),
    Song(
      songName: "Lạc lối",
      artistName: "React",
      albumArtImagePath: "assets/images/anhtuan.jpg",
      audioPath: "audio/lacloi.mp3",
    ),
     Song(
      songName: "Tình đầu quá chén",
      artistName: "Quang Hùng MasterD",
      albumArtImagePath: "assets/images/tinhdauquachen.jpeg",
      audioPath: "audio/tinhdauquachen.mp3",
    )
  ];

  int? _currentSongIndex;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  bool _isPlaying = false;
  bool _isShuffle = false; // Trạng thái phát ngẫu nhiên
  bool _isRepeat = false;  // Trạng thái lặp lại bài hát

  // Khởi tạo và lắng nghe thời lượng
  PlaylistProvider() {
    listenToDuration();
  }

  // Phát bài hát hiện tại
  void play() async {
    final String path = _playlist[_currentSongIndex!].audioPath;
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(path));
    _isPlaying = true;
    notifyListeners();
  }

  // Tạm dừng
  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  // Tiếp tục phát
  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  // Toggle phát/tạm dừng
  void pauseOrResume() {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
    notifyListeners();
  }

  // Tua bài hát
  void seek(Duration position) async {
    await _audioPlayer.seek(position);
    notifyListeners();
  }

  // Phát bài tiếp theo
  void playNextSong() {
    if (_isShuffle) {
      // Chọn bài ngẫu nhiên khác bài hiện tại
      final random = Random();
      int newIndex = _currentSongIndex!;
      while (newIndex == _currentSongIndex && _playlist.length > 1) {
        newIndex = random.nextInt(_playlist.length);
      }
      _currentSongIndex = newIndex;
    } else {
      // Chuyển bài kế tiếp theo thứ tự
      if (_currentSongIndex != null &&
          _currentSongIndex! < _playlist.length - 1) {
        _currentSongIndex = _currentSongIndex! + 1;
      } else {
        _currentSongIndex = 0; // Quay về bài đầu
      }
    }

    play();
    notifyListeners();
  }

  // Quay về bài trước
  void playPreviousSong() {
    if (_currentDuration.inSeconds > 2) {
      // Nếu mới phát <2s thì reset thời lượng
      seek(Duration.zero);
    } else {
      // Chuyển bài lùi
      if (_currentSongIndex! > 0) {
        currentSongIndex = _currentSongIndex! - 1;
      } else {
        currentSongIndex = _playlist.length - 1; // Quay về bài cuối
      }
    }
  }

  // Lắng nghe thời lượng
  void listenToDuration() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });

    // Khi bài hát kết thúc
    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isRepeat) {
        // Nếu repeat, phát lại từ đầu
        seek(Duration.zero);
        play();
      } else {
        // Ngược lại, phát bài kế
        playNextSong();
      }
    });
  }

  // ====== GETTERS ======
  List<Song> get playlist => _playlist;
  int get currentSongIndex => _currentSongIndex ?? 0;
  bool get isPlaying => _isPlaying;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;
  bool get isShuffle => _isShuffle;
  bool get isRepeat => _isRepeat;

  // ====== SETTERS ======
  set currentSongIndex(int newIndex) {
    _currentSongIndex = newIndex;
    play();
    notifyListeners();
  }

  // Bật/tắt shuffle
  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  // Bật/tắt repeat
  void toggleRepeat() {
    _isRepeat = !_isRepeat;
    notifyListeners();
  }
}
