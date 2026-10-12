import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class SpellingHome extends StatefulWidget {
  const SpellingHome({super.key});

  @override
  State<SpellingHome> createState() => _SpellingHomeState();
}

class _SpellingHomeState extends State<SpellingHome> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true); // Makes the animation loop back and forth

    _animation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 12,
              child: Container(
                  decoration: const BoxDecoration(color: Colors.amberAccent),
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, -_animation.value), // Moves image up and down
                            child: child,
                          );
                        },
                        child: Image.asset(
                          "assets/bee.png",
                          width: 180,
                          height: 180,
                        ),
                      ),
                      SizedBox(height: 10,),
                      const Text("Select Difficulty Level",
                          style: TextStyle(fontSize: 15)),

                      SizedBox(height: 40,),

                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, -_animation.value), // Moves image up and down
                            child: child,
                          );
                        },
                        child: Image.asset(
                          "assets/arrow.png",
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ],
                  ))),
            ),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () => Get.toNamed('/quiz', arguments: 'beginner'),
                child: buildShimmerContainer(Colors.lightGreen, "Beginner"),
              ),
            ),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () => Get.toNamed('/quiz', arguments: 'intermediate'),
                child: buildShimmerContainer(Colors.deepOrangeAccent, "Intermediate"),
              ),
            ),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () => Get.toNamed('/quiz', arguments: 'champion'),
                child: buildShimmerContainer(Colors.purpleAccent, "Champion"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShimmerContainer(Color baseColor, String text) {
    return Stack(
      children: [
        Shimmer.fromColors(
          baseColor: baseColor.withOpacity(1.0),
          highlightColor: baseColor.withOpacity(0.8),
          child: Container(
            color: baseColor, // Background color
          ),
        ),
        Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
