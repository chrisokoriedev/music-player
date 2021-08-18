import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';

class MainMusicSection extends StatefulWidget {
  SongInfo songInfo;
  Function changeTrack;
  final GlobalKey<MainMusicSectionState> key;

  MainMusicSection({this.songInfo, this.changeTrack, this.key})
      : super(key: key);

  @override
  MainMusicSectionState createState() => MainMusicSectionState();
}

class MainMusicSectionState extends State<MainMusicSection> {
  double minSongLevel = 0.0;
  double maxSongLevel = 0.0;
  double currentSongLevel = 0.0;
  String currentTime = '', maxTime = '';
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    setSong(widget.songInfo);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setSong(SongInfo songInfo) async {
    widget.songInfo = songInfo;
    await player.setUrl(widget.songInfo.uri);
    currentSongLevel = minSongLevel;
    maxSongLevel = player.duration.inMilliseconds.toDouble();
    setState(() {
      currentTime = getTimePeriod(currentSongLevel);
      maxTime = getTimePeriod(maxSongLevel);
    });
    isPlaying = false;
    changeStats();
    player.positionStream.listen((duration) {
      currentSongLevel = duration.inMilliseconds.toDouble();
      setState(() {
        currentTime = getTimePeriod(currentSongLevel);
      });
    });
  }


  void changeStats() {
    setState(() {
      isPlaying = !isPlaying;
    });

    if (isPlaying) {
      player.play();
    } else {
      player.pause();
    }
  }

  String getTimePeriod(double value) {
    Duration duration = Duration(milliseconds: value.round());
    return [duration.inMinutes, duration.inSeconds]
        .map((element) => element.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff000e24),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color(0xff000e24),
        title: Text('Now Playing'),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              height: 280,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/placeholder.png'))),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Color(0xff041c4a),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    )),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Text(
                        widget.songInfo.title,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text(
                        widget.songInfo.artist,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            currentTime,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xff000e24),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Slider(
                              autofocus: true,
                              inactiveColor: Colors.grey,
                              activeColor: Colors.white,
                              min: minSongLevel,
                              max: maxSongLevel,
                              value: currentSongLevel,
                              onChanged: (value) {
                                currentSongLevel = value;
                                if (value >= maxSongLevel) {
                                  setState(() {
                                    player.stop();
                                    // widget.changeTrack(true);
                                  });
                                }
                                player.seek(Duration(
                                    milliseconds: currentSongLevel.round()));
                              },
                            ),
                          ),
                          Text(
                            maxTime,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: ()async {
                               await player.setShuffleModeEnabled(true);
                                },
                                child: Icon(
                                  Icons.shuffle,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.repeat,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            child: Icon(
                              Icons.skip_previous_outlined,
                              color: Colors.white,
                              size: 50,
                            ),
                            behavior: HitTestBehavior.translucent,
                            onTap: () => widget.changeTrack(false),
                          ),
                          GestureDetector(
                            child: Icon(
                              isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill_outlined,
                              color: Colors.white,
                              size: 70,
                            ),
                            behavior: HitTestBehavior.translucent,
                            onTap: () => changeStats(),
                          ),
                          GestureDetector(
                            child: Icon(
                              Icons.skip_next_outlined,
                              color: Colors.white,
                              size: 50,
                            ),
                            behavior: HitTestBehavior.translucent,
                            onTap: () => widget.changeTrack(true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
