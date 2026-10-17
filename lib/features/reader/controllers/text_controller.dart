// import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class TextController extends GetxController {
  // final FlutterTts flutterTts = FlutterTts();
  var isPlaying = false.obs;
  var progress = 0.0.obs;
  var voices = <dynamic>[].obs;
  var selectedVoice = ''.obs;
  String fullText = '';

  @override
  void onInit() {
    super.onInit();
    fetchVoices();
    setupTtsListeners();
  }

  void fetchVoices() async {
    // var availableVoices = await flutterTts.getVoices;
    // voices.value = availableVoices;
    // if (voices.isNotEmpty) {
    //   selectedVoice.value = voices.first['name'];
    // }
  }

  void setupTtsListeners() {
    // flutterTts.setStartHandler(() {
    //   isPlaying.value = true;
    // });

    // flutterTts.setCompletionHandler(() {
    //   isPlaying.value = false;
    //   progress.value = 0.0;
    // });

    // flutterTts.setProgressHandler((String text, int start, int end, String word) {
    //   progress.value = (end / text.length);
    // });
  }

  void speakText(String part) async {
    // await flutterTts.setVoice({"name": selectedVoice.value});
    // await flutterTts.speak(part);
  }

  void stopText() async {
    // await flutterTts.stop();
  }

  void rewindText() async {
    // await flutterTts.stop();
    progress.value = 0.0;
    speakText(fullText);
  }

  void setVoice(String voice) {
    selectedVoice.value = voice;
  }

  void setFullText(String text) {
    fullText = text;
  }
}

class TTSService {
  // FlutterTts flutterTts = FlutterTts();
  List<dynamic> voices = [];
  dynamic currentVoice;

  void initTTS() async {
    // flutterTts = FlutterTts();
    // voices = await flutterTts.getVoices;
    // voices = voices.where((voice) => voice['name'].contains('en')).toList();
    // currentVoice = voices.first;
    // flutterTts.setVoice(currentVoice);
  }
}

