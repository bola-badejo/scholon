import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

import '../../Models/courses.dart';

class ArticlePage extends StatefulWidget {
  final String notes;
  final String title;
  final int index;
  final Course course;
  // final Topic topic;
  final Note note;

  ArticlePage(
      {required this.notes,
      required this.note,
      required this.title,
      required this.course,
      required this.index,
      // required this.topic,
      Key? key})
      : super(key: key);

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage>
    with TickerProviderStateMixin {
  // late VideoPlayerController _videoController;
  late FlutterTts _flutterTts;
  List<String> _sentences = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    String sanitizedNotes = widget.notes.replaceAll(r'\n', '  ');
    _sentences = sanitizedNotes.split(RegExp(r'(?<=[.!?])\s+'));
    _readAndDisplaySentences();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _readAndDisplaySentences() async {
    if (_currentIndex < _sentences.length) {
      String sentenceToRead = _sentences
          .sublist(
              _currentIndex, (_currentIndex + 2).clamp(0, _sentences.length))
          .join(' ');
      await _flutterTts.speak(sentenceToRead);

      _flutterTts.setCompletionHandler(() {
        setState(() {
          _currentIndex += 2;
        });
        _readAndDisplaySentences();
      });
    } else {
      _flutterTts.stop();
    }
  }

  ParticleOptions particleOptions = ParticleOptions(
      image: Image.asset("assets/profile.png",
          cacheHeight: 200, cacheWidth: 200),
      baseColor: Colors.black,
      spawnOpacity: 0.0,
      opacityChangeRate: 0.25,
      minOpacity: 0.1,
      maxOpacity: 0.4,
      spawnMinSpeed: 30.0,
      spawnMaxSpeed: 70.0,
      particleCount: 40);

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: ()async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            }),
        elevation: 0,
        title: const Text(
          'Visualizer',
          style: TextStyle(
            color: Colors.black,
            // shadows: [
            //   Shadow(
            //     offset: Offset(2, 2),
            //     blurRadius: 3,
            //     color: Colors.black,
            //   ),
            // ],
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: AnimatedBackground(
        vsync: this,
        behaviour: RandomParticleBehaviour(
          options: particleOptions,
        ),
        child: Stack(
          children: [
            // Teachly logo
            Positioned(
              bottom: 160,
              left: 0,
              right: 0,
              child: Center(
                  child: Image.asset(
                "assets/arrow.png",
                width: 20,
                height: 20,
                      cacheHeight: 200, cacheWidth: 200
              )),
            ),

            // Chapter
            Positioned(
              top: 40,
              right: 0,
              left: 0,
              child: Padding(
                padding: const EdgeInsets.all(60.0),
                child: Text(
                  "Chapter ${widget.index + 1}:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Course Title
            Positioned(
              top: 60,
              right: 0,
              left: 0,
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Text(
                  widget.course.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Title
            Positioned(
              top: 90,
              right: 0,
              left: 0,
              child: Padding(
                padding: const EdgeInsets.all(60.0),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Footer
            Positioned(
              bottom: 80,
              right: 0,
              left: 0,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text(
                  "iSAPP Note Visualizer | v0.01",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            // Text display
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  _currentIndex < _sentences.length
                      ? _sentences
                          .sublist(_currentIndex,
                              (_currentIndex + 2).clamp(0, _sentences.length))
                          .join(' ')
                      : 'End of note.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
