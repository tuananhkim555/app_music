import 'dart:math';

import 'package:app_music/components/neu_box.dart';
import 'package:app_music/models/playlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SongPage extends StatefulWidget {
  const SongPage({super.key});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Lặp vô hạn và thời gian xoay 10s/lần
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
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
              child: Column(
                children: [
                  // App bar
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
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Song title & artist
                  Column(
                    children: [
                      Text(
                        value.playlist[value.currentSongIndex].songName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        value.playlist[value.currentSongIndex].artistName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Album Art with Rotation
                  NeuBox(
                    child: RotationTransition(
                      turns: _controller,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(180),
                        child: Image.asset(
                          value.playlist[value.currentSongIndex].albumArtImagePath,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                
                // song duration progress
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // start and time
                            Text(
                              "0:00",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                        
                            // shufle icon
                             Icon(
                              Icons.shuffle,
                            ),
                        
                            // repeat icon
                             Icon(
                              Icons.repeat,
                            ),
                        
                        
                            // end time
                             Text(
                              "0:0",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                              
                          ],
                        ),
                      ),

                       SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: 
                          const RoundSliderThumbShape(enabledThumbRadius: 0),
                        ),
          
                         child: Slider(
                          min: 0,
                          max: 100,
                          value: 50, 
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: (value) {},
                          ),
                       ),
                  
                    ],
                  ),
                   const SizedBox(height: 25),

                  // play back control
                 Row(
                  children: [

                    // skip previous
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          
                        },
                        child: NeuBox(child: 
                              Icon(Icons.skip_previous,)),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // play/pause button
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          
                        },
                        child: NeuBox(child: 
                              Icon(Icons.play_arrow,)),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // skip forward
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          
                        },
                        child: NeuBox(child: 
                              Icon(Icons.skip_next,)),
                      ),
                    )

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
