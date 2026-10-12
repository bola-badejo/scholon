import 'dart:convert';

import 'package:isapp/Screens/tests/controllers/quiz_controller.dart';
import 'package:isapp/Utils/library/course_logic.dart';

class CourseCategories {
  String code;
  String title;
  String image;
  String banner;
  List<Course> courses;

  CourseCategories({
    required this.code,
    required this.title,
    required this.image,
    required this.banner,
    required this.courses,
  });

  factory CourseCategories.fromJson(Map<String, dynamic> json) {
    List<dynamic> coursesJson = json['courses'] ?? [];
    List<Course> courses = coursesJson.map((course) => Course.fromJson(course)).toList();

    return CourseCategories(
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      image: json['image'] as String? ?? '',
      banner: json['banner'] as String? ?? '',
      courses: courses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'title': title,
      'image': image,
      'banner': banner,
      'courses': courses.map((course) => course.toJson()).toList(),
    };
  }
}

class Course {
  String title;
  String code;
  String image; // Added missing field
  List<Topic> topics;

  Course({
    required this.title,
    required this.code,
    required this.image, // Added
    required this.topics,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    List<dynamic> topicsJson = json['topics'] ?? [];
    List<Topic> topics = topicsJson.map((topic) => Topic.fromJson(topic)).toList();
    
    // Filter out invalid topics
    topics = topics.where((topic) => 
      topic.title.isNotEmpty && topic.code.isNotEmpty
    ).toList();

    return Course(
      title: json['title'] as String? ?? 'Untitled Course',
      code: json['code'] as String? ?? 'UNKNOWN_001',
      image: json['image'] as String? ?? '', // Added
      topics: topics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'code': code,
      'image': image, // Added
      'topics': topics.map((topic) => topic.toJson()).toList(),
    };
  }
}

class Topic {
  String title;
  String code;
  String image;
  Materials materials;

  Topic({
    required this.title,
    required this.code,
    required this.image,
    required this.materials,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    Materials materials;
    
    if (json['materials'] != null) {
      try {
        materials = Materials.fromJson(json['materials']);
      } catch (e) {
        materials = Materials(
          notes: [],
          videos: [],
          audios: [],
          tests: [],
        );
      }
    } else {
      materials = Materials(
        notes: [],
        videos: [],
        audios: [],
        tests: [],
      );
    }
    
    return Topic(
      title: json['title'] as String? ?? 'Untitled Topic',
      code: json['code'] as String? ?? 'TOPIC_001',
      image: json['image'] as String? ?? '',
      materials: materials,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'code': code,
      'image': image,
      'materials': materials.toJson(),
    };
  }
}

class Materials {
  List<Note> notes;
  List<Video> videos;
  List<Audio> audios;
  List<Test> tests;

  Materials({
    required this.notes,
    required this.videos,
    required this.audios,
    required this.tests,
  });

  factory Materials.fromJson(Map<String, dynamic> json) {
    List<dynamic> notesJson = json['notes'] ?? [];
    List<Note> notes = notesJson.map((note) => Note.fromJson(note)).toList();

    List<dynamic> videosJson = json['videos'] ?? [];
    List<Video> videos = videosJson.map((video) => Video.fromJson(video)).toList();

    List<dynamic> audiosJson = json['audios'] ?? [];
    List<Audio> audios = audiosJson.map((audio) => Audio.fromJson(audio)).toList();

    List<dynamic> testsJson = json['tests'] ?? [];
    List<Test> tests = testsJson.map((test) => Test.fromJson(test)).toList();

    return Materials(
      notes: notes,
      videos: videos,
      audios: audios,
      tests: tests,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notes': notes.map((note) => note.toJson()).toList(),
      'videos': videos.map((video) => video.toJson()).toList(),
      'audios': audios.map((audio) => audio.toJson()).toList(),
      'tests': tests.map((test) => test.toJson()).toList(),
    };
  }
}

class Note {
  String code;
  String content;
  int duration;
  String title;
  String image;

  Note({
    required this.code,
    required this.content,
    required this.duration,
    required this.title,
    required this.image,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      code: json['code'] as String? ?? '',
      content: json['content'] as String? ?? '',
      duration: (json['duration'] as int?) ?? 0,
      title: json['title'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'content': content,
      'duration': duration,
      'title': title,
      'image': image,
    };
  }
}

class Video {
  String code;
  String content;
  int duration;
  String title;

  Video({
    required this.code,
    required this.content,
    required this.duration,
    required this.title,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      code: json['code'] as String? ?? '',
      content: json['content'] as String? ?? '',
      duration: (json['duration'] as int?) ?? 0,
      title: json['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'content': content,
      'duration': duration,
      'title': title,
    };
  }
}

class Audio {
  String code;
  String content;
  int duration;
  String title;

  Audio({
    required this.code,
    required this.content,
    required this.duration,
    required this.title,
  });

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
      code: json['code'] as String? ?? '',
      content: json['content'] as String? ?? '',
      duration: (json['duration'] as int?) ?? 0,
      title: json['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'content': content,
      'duration': duration,
      'title': title,
    };
  }
}

class Test {
  int duration; // Added from JSON
  String code;
  int noOfQuestions; // Added from JSON
  String title;
  List<Question> questions;

  Test({
    required this.duration,
    required this.code,
    required this.noOfQuestions,
    required this.title,
    required this.questions,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    List<dynamic> questionsJson = json['questions'] ?? [];
    List<Question> questions = questionsJson.map((x) => Question.fromJson(x)).toList();
    
    return Test(
      duration: (json['duration'] as int?) ?? 0,
      code: json['code'] as String? ?? '',
      noOfQuestions: (json['noOfQuestions'] as int?) ?? 0,
      title: json['title'] as String? ?? '',
      questions: questions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'code': code,
      'noOfQuestions': noOfQuestions,
      'title': title,
      'questions': questions.map((x) => x.toJson()).toList(),
    };
  }
}

class Question {
  String question;
  String correctAnswer;
  List<String> options;
  String instruction;
  String passage;
  String example;
  String image;
  String code;

  Question({
    required this.question,
    required this.correctAnswer,
    required this.options,
    required this.instruction,
    required this.passage,
    required this.example,
    required this.image,
    required this.code,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<dynamic> optionsJson = json['options'] ?? [];
    List<String> options = optionsJson.map((opt) => opt.toString()).toList();
    
    return Question(
      question: json['question'] as String? ?? '',
      correctAnswer: json['correctAnswer'] as String? ?? '',
      options: options,
      instruction: json['instruction'] as String? ?? '',
      passage: json['passage'] as String? ?? '', // This might be missing in JSON
      example: json['example'] as String? ?? '', // This might be missing in JSON
      image: json['image'] as String? ?? '', // This might be missing in JSON
      code: json['code'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'correctAnswer': correctAnswer,
      'options': options,
      'instruction': instruction,
      'passage': passage,
      'example': example,
      'image': image,
      'code': code,
    };
  }
}

List<CourseCategories> parseExamCategoriesJson([String? jsonData]) {
  try {
    final jsonString = jsonData ?? Constants.examCategoriesJson;
    final decoded = jsonDecode(jsonString);
    
    if (decoded is! List) {
      throw FormatException('Expected a JSON array');
    }
    
    List<CourseCategories> categories = [];
    
    for (var item in decoded) {
      try {
        final category = CourseCategories.fromJson(item);
        categories.add(category);
      } catch (e) {
        print('Error parsing category: $e');
        // Continue with next category
      }
    }
    
    return categories;
  } catch (e) {
    print('Error parsing exam categories: $e');
    return [];
  }
}

class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int score;
  final double percentage;
  final List<AttemptedQuestion> attemptedQuestions;
  final DateTime completedAt;
  final int totalTimeSpent;

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.percentage,
    required this.attemptedQuestions,
    required this.completedAt,
    required this.totalTimeSpent,
  });
}

enum QuizStatus { notStarted, inProgress, completed }