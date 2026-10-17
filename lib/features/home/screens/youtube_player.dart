import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String? title;

  const VideoPlayerPage({super.key, required this.videoUrl, this.title});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  YoutubePlayerController? _controller;
  String? videoId;
  bool hasError = false;

  @override
  void initState() {
    super.initState();

    videoId = YoutubePlayerController.convertUrlToId(widget.videoUrl);

    if (videoId == null) {
      hasError = true;
      return;
    }

    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableCaption: true,
        playsInline: true,
        strictRelatedVideos: true,
        color: 'blue',
      ),
    );

    _controller!.cueVideoById(videoId: videoId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,

      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        title: Text(widget.title ?? "Tutorial Video"),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: hasError
              ? const Text(
                  "Invalid video link",
                  style: TextStyle(color: Colors.white),
                )
              : _controller == null
              ? const CircularProgressIndicator(color: Colors.white)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Video Player
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: YoutubePlayerScaffold(
                        controller: _controller!,
                        aspectRatio: 16 / 9,
                        builder: (context, player) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: player,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Control buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _controller?.playVideo();
                          },
                        ),

                        IconButton(
                          icon: const Icon(Icons.pause, color: Colors.white),
                          onPressed: () {
                            _controller?.pauseVideo();
                          },
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.replay_10,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            final current = await _controller!.currentTime;
                            _controller!.seekTo(
                              seconds: current - 10,
                              allowSeekAhead: true,
                            );
                          },
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.forward_10,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            final current = await _controller!.currentTime;
                            _controller!.seekTo(
                              seconds: current + 10,
                              allowSeekAhead: true,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }
}
