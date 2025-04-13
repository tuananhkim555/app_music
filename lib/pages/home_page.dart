// ignore_for_file: deprecated_member_use

import 'package:app_music/components/my_drawer.dart';
import 'package:app_music/models/playlist_provider.dart';
import 'package:app_music/models/song.dart';
import 'package:app_music/pages/song_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // get the playlist provider
  late final dynamic playlistProvider;

  @override
  void initState() {
    super.initState();

    // get the playlist provider
    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
  }

  // go to song
  void goToSong(int songIndex) {
    // update the current song index
   playlistProvider.currentSongIndex = songIndex;
    
    // navigate to the song page
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => SongPage(),
      ));
    }
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Text("P L A Y L I S T"),
        ),
        
        drawer: MyDrawer(),
        
        body: Consumer<PlaylistProvider>(builder: (context, value, child) {
          // get playlist
          final List<Song> playlist = value.playlist;

          // return List View UI
          return ListView.builder(
            itemCount: playlist.length,
            itemBuilder: (context, index) {
              // get individual song
              final Song song = playlist[index];


              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ListTile(
                  // get list title UI
                  title: Text(
                    song.songName,
                    style: const TextStyle(fontSize: 17),
                  ),
                  subtitle: Text(
                    song.artistName,
                    style: const TextStyle(fontSize: 14),
                  ),
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(song.albumArtImagePath),
                    radius: 30,
                  ),
                  onTap: () => goToSong(index),
                ),
              );
            },
          );
        }),
      );
    }
  }

