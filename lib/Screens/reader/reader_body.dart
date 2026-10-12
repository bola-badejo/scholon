import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Models/courses.dart';
import 'controller/text_controller.dart';

class ReaderBody extends StatefulWidget {
  final Note note;
  final Course course;
  // final Topic topic;
  final List<TextSpan> textSpans;
  const ReaderBody(
      {super.key,
      required this.note,
      required this.course,
      // required this.topic,
      required this.textSpans});

  @override
  State<ReaderBody> createState() => _ReaderBodyState();
}

class _ReaderBodyState extends State<ReaderBody> {
  final TextController textController = Get.put(TextController());

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            courseDuration(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Text.rich(
                textAlign: TextAlign.left,
                TextSpan(
                  children: widget.textSpans,
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  String convertNewLine(String content) {
    return content.replaceAll(r'\n', '  ');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // CourseBlueprint(FirebaseAuth.instance.currentUser!.uid)
      //     .markReadNotes(widget.course.code, widget.topic.code);
    }
  }

  Padding courseDuration() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
            child: Text(
              widget.note.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
                color: Colors.grey, borderRadius: BorderRadius.circular(7)),
            child: Row(
              children: [
                Icon(Icons.code),
                const SizedBox(width: 15),
                Text(
                  widget.note.code,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // Padding images() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 30),
  //     child: Container(
  //       width: double.infinity,
  //       height: 250,
  //       decoration: BoxDecoration(
  //         color: primaryColor,
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //       child: ImageLoader(imageUrl: widget.course.image),
  //     ),
  //   );
  // }
}

class AudioController extends GetxController {
  RxBool isPlaying = false.obs;

  void togglePlayback() {
    isPlaying.value = !isPlaying.value;
  }

  void stopPlayback() {
    isPlaying.value = false;
  }
}
