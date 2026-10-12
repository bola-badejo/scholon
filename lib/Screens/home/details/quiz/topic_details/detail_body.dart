import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../../Models/courses.dart';
import '../../../../../Utils/constants.dart';
import '../../../../tests/test_page.dart';

class DetailBody extends StatelessWidget {
  final Materials material;
  final List<Topic> topic;
  final Course course;
  const DetailBody(
      {super.key,
        required this.course,
        required this.material,
        required this.topic});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            images(),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                course.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16),
              ),
            ),
            testDuration(),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: material.tests.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TestPage(
                              test: material.tests,
                              index: index,
                              question: material.tests[index].questions,
                            )));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            gradient: const LinearGradient(colors: [
                              Color.fromARGB(255, 182, 26, 255),
                              Color.fromARGB(255, 41, 168, 218),
                              Color.fromARGB(255, 15, 132, 161),
                            ]),
                          ),
                          child: SvgPicture.asset(
                            "assets/svg/more.svg",
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 26,
                        ),
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  material.tests[index].title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  material.tests[index].code,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ))
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Padding courseDuration() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Available Notes",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
                color: subColor, borderRadius: BorderRadius.circular(7)),
            child: Row(
              children: [
                SvgPicture.asset("assets/svg/clock.svg"),
                const SizedBox(width: 5),
                Text(
                  "15mins",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Padding audioDuration() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Available AudioNotes",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
                color: subColor, borderRadius: BorderRadius.circular(7)),
            child: Row(
              children: [
                SvgPicture.asset("assets/svg/clock.svg"),
                const SizedBox(width: 5),
                Text(
                  "30min",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Padding videoDuration() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Available Videos",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
                color: subColor, borderRadius: BorderRadius.circular(7)),
            child: Row(
              children: [
                SvgPicture.asset("assets/svg/clock.svg"),
                const SizedBox(width: 5),
                Text(
                  "50min",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Padding testDuration() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Available Quizzes",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
                color: subColor, borderRadius: BorderRadius.circular(7)),
            child: Row(
              children: [
                SvgPicture.asset("assets/svg/clock.svg"),
                const SizedBox(width: 5),
                Text(
                  "30min",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Padding images() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        width: double.infinity,
        height: 180,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SvgPicture.asset("assets/svg/intro.svg"),
      ),
    );
  }
}