import 'package:app_music/models/song.dart';
import 'package:flutter/material.dart';

class PlaylistProvider extends ChangeNotifier {
  // playlist of song
  final List<Song> _playlist = [
    // songs 1
    Song(songName: "Về đâu mái tóc người thương",
     artistName: "Quang Lê", 
     albumArtImagePath: "assets/images/vedaumaitocnguoithuong.webp", 
     audioPath: "assets/audio/beat.mp3", ),

    // songs 2
    Song(songName: "Không phải tại chúng mình",
     artistName: "Quang Lê", 
     albumArtImagePath: "assets/images/vedaumaitocnguoithuong.jpg", 
     audioPath: "assets/audio/beat.mp3", )

  ];

  // current song play index
  int? _currentSongIndex;

  // GETTERS
  List<Song> get playlist => _playlist;
  int get currentSongIndex => _currentSongIndex ?? 0;



  // SETTERS

  set currentSongIndex(int newIndex) {
    _currentSongIndex = newIndex;
    notifyListeners();
  }
}