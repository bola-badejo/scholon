// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:isapp/Screens/games/logic/spelling_bee/spelling_bee_controller.dart';

// import 'package:isapp/core/theme/colors.dart';

// class ScoreScreen extends StatelessWidget {
//   final SpellingBeeController controller = Get.find<SpellingBeeController>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.amber,
//       appBar: AppBar(title: Text("Score Summary"), backgroundColor: Colors.transparent,),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Center(
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 48.0),
//                     child: Image.asset('assets/score.gif',
//                     ),
//                   ),
//                   Text(
//                     "${controller.score.value}",
//                     style: TextStyle(
//                       color: primaryColor,
//                       fontSize: 100.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Text("Final Score: ${controller.score.value} of 10", style: TextStyle(fontSize: 14)),
//             SizedBox(height: 20),

//             if (controller.missedWords.isNotEmpty) ...[ // Hide if no missed words
//               Text("Missed Words:", style: TextStyle(fontSize: 12)),
//               SizedBox(height: 10),
//               ...controller.missedWords.map((e) => Text(e, style: TextStyle(fontSize: 16, color: Colors.red))),
//             ],

//             SizedBox(height: 20),
//             ElevatedButton(onPressed: () => Get.offAllNamed('/home'), child: Text("Play Again")),
//           ],
//         ),
//       ),
//     );
//   }
// }
