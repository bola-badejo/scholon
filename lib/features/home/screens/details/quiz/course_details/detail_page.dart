import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import 'package:isapp/features/learning/models/course_models.dart';
import 'package:isapp/core/theme/colors.dart';
import 'package:isapp/features/home/screens/details/quiz/course_details/detail_body.dart';

class QuizDetailScreen extends StatelessWidget {
  final CourseCategories courseCategory;
  const QuizDetailScreen({super.key, required this.courseCategory});

  @override
  Widget build(BuildContext context) {
    // List<String> chapters = CourseCategories.courses.map((topic) => topic.title).toList();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            displayImage(context),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 140,
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(
                      courseCategory.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 12,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width - 150,
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        "${courseCategory.code}  ",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      )),
                  const Text(
                    "free",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildStarRating(4.5),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                courseCategory.banner,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DetailBody(course: courseCategory.courses, courseCategory:courseCategory)));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(colors: [
                          Color.fromARGB(255, 104, 181, 244),
                          Color.fromARGB(255, 116, 69, 245),
                          Color.fromARGB(255, 1216, 65, 243),
                        ])),
                    child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle,
                              color: Colors.white,
                            ),
                            Text(
                              "  View this Quiz Pack",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white),
                            ),
                          ],
                        )),
                  ),
                )),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = rating - fullStars >= 0.5;
    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.amber, size: 11);
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 11);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 11);
        }
      }),
    );
  }

  Container displayImage(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.47,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        // image: DecorationImage(
        //     image: AssetImage(
        //       course.image,
        //     ),
        //     fit: BoxFit.fill),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(60),
          topRight: Radius.circular(60),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
              bottom: 50,
              left: 30,
              child: Container(
                  width: MediaQuery.of(context).size.width / 0.3,
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    courseCategory.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 28,
                    ),
                  ))),
          Positioned(
            bottom: 0,
            left: 0,
            top: 0,
            right: 0,
            child: images()),
          Positioned(
            bottom: 55,
            right: 30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 35,
              width: 105,
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(40)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check,
                    size: 14,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Available",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
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
