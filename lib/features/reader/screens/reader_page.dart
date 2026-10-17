import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:isapp/features/reader/screens/reader_body.dart';
import 'package:isapp/features/reader/screens/reading_room.dart';

import 'package:isapp/features/learning/models/course_models.dart';
import 'package:isapp/core/constants/app_constants.dart';

class ReaderPage extends StatefulWidget {
  final Note note;
  final int index;
  final Course course;
  // final Topic topic;
  const ReaderPage(
      {super.key,
      required this.note,
      required this.index,
      required this.course,
      // required this.topic
      });

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  FlutterTts flutterTts = FlutterTts();
  List<Map> voices = [];
  Map? currentVoice;
  int? currentWordStart = 0;
  int? currentWordEnd = 0;
  int presserValue = 0;

  Key readerKey = UniqueKey();

  @override
  void initState() {
    // print("this is the fooken video url ${widget.video}");
    initTTS();
    super.initState();
  }

  void initTTS() async {
    List<dynamic> voicesData = await flutterTts.getVoices;
    currentWordStart = 0;
    currentWordEnd = 0;

    flutterTts
        .setProgressHandler((String text, int start, int end, String word) {
      setState(() {
        currentWordStart = start;
        currentWordEnd = end;
      });
    });
    voices = List<Map>.from(voicesData)
        .where((voice) => voice['name'].contains('en'))
        .toList();
    setState(() {
      currentVoice = voices.isNotEmpty ? voices.first : null;
      if (currentVoice != null) setVoice(currentVoice!);
    });
  }

  void setVoice(Map voice) {
    flutterTts.setVoice({"name": voice['name'], "locale": voice['locale']});
  }

  void refreshReader() {
    setState(() {
      initTTS();
      readerKey = UniqueKey();
    });
  }

  void _navigateToVisualizer(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ArticlePage(
                  notes: widget.note.content,
                  title: widget.note.title,
                  course: widget.course,
                  index: widget.index,
                  // topic: widget.topic,
                  note: widget.note,
                )));
    setState(() {
      readerKey = UniqueKey();
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    currentWordStart = 0;
    currentWordEnd = 0;
    flutterTts
        .setProgressHandler((String text, int start, int end, String word) {
      setState(() {
        currentWordStart = start;
        currentWordEnd = end;
      });
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "Note Explorer",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
      ),
      body: ReaderBody(
          key: readerKey,
          note: widget.note,
          course: widget.course,
          // topic: widget.topic,
          textSpans:
              _buildTextSpans(convertNewLineDisplay(widget.note.content))),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                if (presserValue == 0) {
                  flutterTts.speak(convertNewLine(widget.note.content));
                  setState(() {
                    presserValue = 1;
                  });
                } else if (presserValue == 1) {
                  flutterTts.stop();
                  setState(() {
                    presserValue = 0;
                  });
                }  else if (presserValue == 2) {
                  setState(() {
                    presserValue = 0;
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context)=> ReaderPage(
                                  note: widget.note,
                                  index: widget.index,
                                  course: widget.course,
                                  // topic: widget.topic,
                                ))
                  );
                } else {}
              },
              mini: true,
              heroTag: "fab1",
              child: presserValue == 0
                  ? const Icon(Icons.speaker_phone)
                  : presserValue == 1 ? const Icon(Icons.stop)
                  : const Icon(Icons.refresh),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                    presserValue = 2;
                  });
                _navigateToVisualizer(context);
              },
              heroTag: "fab2",
              mini: true,
              child: const Icon(Icons.live_tv_sharp),
            ),
          ),
        ],
      ),
    );
  }

  String convertNewLine(String content) {
    return content.replaceAll(r'\n', ' ');
  }

  String convertNewLineDisplay(String content) {
    return content.replaceAll(r'\n', '\n');
  }

  List<TextSpan> _buildTextSpans(String text) {
    List<TextSpan> spans = [];
    if (currentWordStart != null && currentWordEnd != null) {
      spans.add(
        TextSpan(
          text: text.substring(0, currentWordStart),
          style: const TextStyle(color: Colors.black),
        ),
      );
      spans.add(
        TextSpan(
          text: text.substring(currentWordStart!, currentWordEnd),
          style: const TextStyle(
              color: Colors.white, backgroundColor: Colors.blueAccent),
        ),
      );
      spans.add(
        TextSpan(
          text: text.substring(currentWordEnd!),
          style: const TextStyle(color: Colors.black),
        ),
      );
    } else {
      spans.add(
          TextSpan(text: text, style: const TextStyle(color: Colors.black)));
    }
    return spans;
  }

  Widget speakerSelector() {
    return DropdownButton(
      value: currentVoice,
      items: voices.map((voice) {
        return DropdownMenuItem(
          value: voice,
          child: Text(voice['name']),
        );
      }).toList(),
      onChanged: (newVoice) {
        setVoice({"name": newVoice!['name'], "locale": newVoice['locale']});
      },
    );
  }
}
