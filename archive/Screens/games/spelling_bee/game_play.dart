// import 'package:animated_background/animated_background.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:isapp/Screens/games/logic/spelling_bee/spelling_bee_controller.dart';

// class SpellingBeeScreenScreen extends StatefulWidget {
//   @override
//   State<SpellingBeeScreenScreen> createState() => _SpellingBeeScreenScreenState();
// }

// class _SpellingBeeScreenScreenState extends State<SpellingBeeScreenScreen>
//     with TickerProviderStateMixin {
//   final SpellingBeeController controller = Get.put(SpellingBeeController());

//   final TextEditingController textController = TextEditingController();
//   ParticleOptions particleOptions = ParticleOptions(
//       image: Image.asset("assets/bee.png",
//           cacheHeight: 200, cacheWidth: 200),
//       baseColor: Colors.black,
//       spawnOpacity: 0.0,
//       opacityChangeRate: 0.25,
//       minOpacity: 0.1,
//       maxOpacity: 0.4,
//       spawnMinSpeed: 30.0,
//       spawnMaxSpeed: 70.0,
//       particleCount: 40);


//   Color getProgressColor(int timeLeft) {
//     if (timeLeft > 40 ) {
//       return Colors.blue;
//     } else if (timeLeft > 20) {
//       return Colors.green;
//     } else if (timeLeft > 10) {
//       return Colors.orange;
//     } else {
//       return Colors.red;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     String level = Get.arguments;
//     controller.loadWords(level);

//     return Scaffold(
//       backgroundColor: Colors.amberAccent,
//       appBar: AppBar(title: const Text("Spell the Word"), backgroundColor: Colors.transparent,),
//       body: Obx(() => AnimatedBackground(
//         vsync: this,
//         behaviour: RandomParticleBehaviour(
//           options: particleOptions,
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//           Stack(
//           alignment: Alignment.center,
//           children: [
//             SizedBox(
//               width: 80,
//               height: 80,
//               child: CircularProgressIndicator(
//                 value: controller.timeLeft.value / 60,
//                 strokeWidth: 8,
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                     getProgressColor(controller.timeLeft.value)),
//                 backgroundColor: Colors.grey.shade300,
//               ),
//             ),
//             Text("${controller.timeLeft.value}s", style: const TextStyle(fontSize: 30)),
//             ]
//           ),
//             SizedBox(height: 15,),
//             ElevatedButton(onPressed: controller.speakWord, child: const Text("🔊 Hear Word")),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 "Meaning: \n${controller.words[controller.currentIndex.value]['meaning']}",
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 12),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: TextField(
//                 controller: textController, // Use the controller
//                 onChanged: (value) => controller.userAnswer.value = value,
//                 decoration: const InputDecoration(labelText: "Type the word", border: OutlineInputBorder()),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 controller.checkAnswer();
//                 textController.clear(); // Clear text input after submission
//               },
//               child: const Text("Submit"),
//             ),
//           ],
//         ),
//       )),
//     );
//   }
// }
