import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import 'package:isapp/features/learning/models/course_models.dart';
import 'package:isapp/core/constants/app_constants.dart';
import 'package:isapp/features/home/screens/details/quiz/topic_details/detail_page.dart';

class DetailBody extends StatelessWidget {
  final List<Course> course;
  final CourseCategories courseCategory;
  DetailBody({super.key, required this.course, required this.courseCategory});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            images(),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                courseCategory.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 24
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Text(
                courseCategory.code,
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:15.0),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _buildStarRating(5),
                    Text(
                      'free',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                  ]
              ),
            ),
            courseDuration(context),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: course.length,
              itemBuilder: (context, index) {
                // final topic = course.topics[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context)=> TopicDetailScreen(course: courseCategory.courses[index], index: index, topic: course[index].topics,)));
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
                            "assets/svg/book.svg",
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
                                  course[index].title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  'Chapters: ${course[index].topics.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ))
                      ],
                    ),
                  ),
                );
              },
            )
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
          return Icon(Icons.star, color: Colors.amber);
        } else if (index == fullStars && hasHalfStar) {
          return Icon(Icons.star_half, color: Colors.amber);
        } else {
          return Icon(Icons.star_border, color: Colors.amber);
        }
      }),
    );
  }

  Padding courseDuration(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Course Outline",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: () {
            },
            child: Container(
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
                    "45mins",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  )
                ],
              ),
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