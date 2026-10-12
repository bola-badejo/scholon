import 'package:flutter/material.dart';

class welcomeText extends StatelessWidget {
  const welcomeText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Hi Bola",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Image.asset(
                    "assets/hand.png",
                    height: 30,
                    width: 30,
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                "Today is a good day\nto learn something new!",
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Image.asset(
            "assets/profile.png",
            height: 110,
            width: 110,
          )
        ],
      ),
    );
  }
}