// lib/Kidling/data/data.dart
//
// NEW CURRICULUM: 8 worlds x 6 levels = 48 activities.
// Every world climbs gently: meet a few things -> more things -> mix them ->
// use them in a new way. Content here only lists WHAT to teach; the lesson
// engine decides HOW (Learn -> Try together -> Star challenge).
//
// Usage (once, from a debug button or main): await SeedActivities.seedAllActivities();

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isapp/Kidling/models/kidling_model.dart';

class SeedActivities {
  static Future<void> seedAllActivities({bool override = true}) async {
    final fs = FirebaseFirestore.instance;
    final existing = await fs.collection('activities').limit(1).get();
    if (existing.docs.isNotEmpty && !override) {
      // ignore: avoid_print
      print('Activities already seeded. Skipping...');
      return;
    }
    if (existing.docs.isNotEmpty) {
      final all = await fs.collection('activities').get();
      final del = fs.batch();
      for (final d in all.docs) {
        del.delete(d.reference);
      }
      await del.commit();
    }

    final batch = fs.batch();
    for (final a in [..._phonics, ..._colors, ..._counting, ..._memory, ..._puzzle, ..._creativity, ..._emotion, ..._music]) {
      batch.set(fs.collection('activities').doc(a.id), a.toMap());
    }
    await batch.commit();
    // ignore: avoid_print
    print('Seeded 48 activities');
  }

  static Activity _a(
    String id,
    String title,
    ActivityType type,
    String desc,
    Map<String, dynamic> content, {
    String age = 'preschool',
    Difficulty diff = Difficulty.easy,
    int minutes = 5,
    List<String> skills = const [],
  }) =>
      Activity(
        id: id,
        title: title,
        type: type,
        ageGroup: age,
        difficulty: diff,
        description: desc,
        content: content,
        audioUrl: '',
        imageAssets: const [],
        expectedOutcome: const {'totalSteps': 10},
        estimatedDuration: minutes,
        skillsTargeted: skills,
        starReward: 3,
      );

  // ============ PHONICS: Jolly-Phonics style order (easy, high-use sounds first) ============
  static final List<Activity> _phonics = [
    _a('phonics_1', 'Sounds S A T P', ActivityType.phonics, 'Meet four letters and their sounds!', {'mode': 'letters', 'letters': ['S', 'A', 'T', 'P']}, age: 'toddler', skills: ['literacy', 'phonics']),
    _a('phonics_2', 'Sounds I N M D', ActivityType.phonics, 'Four new letter friends!', {'mode': 'letters', 'letters': ['I', 'N', 'M', 'D']}, skills: ['literacy', 'phonics']),
    _a('phonics_3', 'Sounds G O C K', ActivityType.phonics, 'More sounds to discover!', {'mode': 'letters', 'letters': ['G', 'O', 'C', 'K']}, skills: ['literacy', 'phonics']),
    _a('phonics_4', 'Sounds E U R H', ActivityType.phonics, 'Four more letters!', {'mode': 'letters', 'letters': ['E', 'U', 'R', 'H']}, diff: Difficulty.medium, skills: ['literacy', 'phonics']),
    _a('phonics_5', 'Sounds B F L J', ActivityType.phonics, 'Almost the whole alphabet!', {'mode': 'letters', 'letters': ['B', 'F', 'L', 'J']}, diff: Difficulty.medium, skills: ['literacy', 'phonics']),
    _a('phonics_6', 'Sounds Q V W X Y Z', ActivityType.phonics, 'The last six letters!', {'mode': 'letters', 'letters': ['Q', 'V', 'W', 'X', 'Y', 'Z']}, age: 'kindergarten', diff: Difficulty.hard, minutes: 7, skills: ['literacy', 'phonics']),
  ];

  // ============ COLORS & SHAPES ============
  static final List<Activity> _colors = [
    _a('color_1', 'Red Blue Yellow', ActivityType.colorShape, 'Learn the first colors!', {'mode': 'colors', 'items': ['red', 'blue', 'yellow']}, age: 'toddler', skills: ['logic', 'colors']),
    _a('color_2', 'Green Orange Purple', ActivityType.colorShape, 'Three more colors!', {'mode': 'colors', 'items': ['green', 'orange', 'purple']}, age: 'toddler', skills: ['logic', 'colors']),
    _a('color_3', 'Pink Brown Black White', ActivityType.colorShape, 'Finish the rainbow!', {'mode': 'colors', 'items': ['pink', 'brown', 'black', 'white']}, skills: ['logic', 'colors']),
    _a('color_4', 'Circle Square Triangle', ActivityType.colorShape, 'Meet three shapes!', {'mode': 'shapes', 'items': ['circle', 'square', 'triangle']}, skills: ['logic', 'shapes']),
    _a('color_5', 'More Shapes', ActivityType.colorShape, 'Rectangle, star, heart and oval!', {'mode': 'shapes', 'items': ['rectangle', 'star', 'heart', 'oval']}, diff: Difficulty.medium, skills: ['logic', 'shapes']),
    _a('color_6', 'Colorful Shapes', ActivityType.colorShape, 'Find the blue triangle!', {'mode': 'combo', 'shapes': ['circle', 'square', 'triangle', 'star'], 'colors': ['red', 'blue', 'green', 'yellow']}, age: 'kindergarten', diff: Difficulty.hard, skills: ['logic', 'colors', 'shapes']),
  ];

  // ============ COUNTING ============
  static final List<Activity> _counting = [
    _a('counting_1', 'Count to 3', ActivityType.counting, 'Count the chicks!', {'min': 1, 'max': 3, 'object': '🐥', 'task': 'count'}, age: 'toddler', skills: ['numeracy', 'counting']),
    _a('counting_2', 'Count to 5', ActivityType.counting, 'Count the apples!', {'min': 1, 'max': 5, 'object': '🍎', 'task': 'count'}, age: 'toddler', skills: ['numeracy', 'counting']),
    _a('counting_3', 'Give Me Five', ActivityType.counting, 'Count and give me the right number!', {'min': 1, 'max': 5, 'object': '⭐', 'task': 'mixed'}, skills: ['numeracy', 'counting']),
    _a('counting_4', 'Count to 10', ActivityType.counting, 'Bigger numbers up to ten!', {'min': 4, 'max': 10, 'object': '🍪', 'task': 'count'}, diff: Difficulty.medium, skills: ['numeracy', 'counting']),
    _a('counting_5', 'Give Me Ten', ActivityType.counting, 'Fill the basket with the right number!', {'min': 3, 'max': 10, 'object': '🎈', 'task': 'give'}, diff: Difficulty.medium, skills: ['numeracy', 'counting']),
    _a('counting_6', 'Count to 15', ActivityType.counting, 'Big counting challenge!', {'min': 8, 'max': 15, 'object': '🦋', 'task': 'mixed'}, age: 'kindergarten', diff: Difficulty.hard, minutes: 7, skills: ['numeracy', 'counting']),
  ];

  // ============ MEMORY (more pairs, shorter peek each level) ============
  static Map<String, dynamic> _cards(List<List<String>> c, int peek) =>
      {'cards': c.map((e) => {'e': e[0], 'n': e[1]}).toList(), 'peek': peek};

  static final List<Activity> _memory = [
    _a('memory_1', 'Animal Pairs', ActivityType.memory, 'Find the matching animals!', _cards([['🐶', 'dog'], ['🐱', 'cat']], 5), age: 'toddler', skills: ['memory', 'concentration']),
    _a('memory_2', 'Fruit Match', ActivityType.memory, 'Match the yummy fruits!', _cards([['🍎', 'apple'], ['🍌', 'banana'], ['🍇', 'grapes']], 5), age: 'toddler', skills: ['memory', 'concentration']),
    _a('memory_3', 'Zoo Match', ActivityType.memory, 'Four zoo friends are hiding!', _cards([['🦁', 'lion'], ['🐘', 'elephant'], ['🐵', 'monkey'], ['🦒', 'giraffe']], 4), skills: ['memory', 'concentration']),
    _a('memory_4', 'Things That Go', ActivityType.memory, 'Five vehicles to find!', _cards([['🚗', 'car'], ['🚌', 'bus'], ['🚲', 'bike'], ['✈️', 'plane'], ['🚂', 'train']], 4), diff: Difficulty.medium, skills: ['memory', 'concentration']),
    _a('memory_5', 'Sea Friends', ActivityType.memory, 'Six sea animals!', _cards([['🐟', 'fish'], ['🐙', 'octopus'], ['🐢', 'turtle'], ['🦀', 'crab'], ['🐳', 'whale'], ['🐬', 'dolphin']], 3), diff: Difficulty.medium, minutes: 7, skills: ['memory', 'concentration']),
    _a('memory_6', 'Super Memory', ActivityType.memory, 'Eight pairs. Quick peek!', _cards([['🌞', 'sun'], ['🌙', 'moon'], ['⭐', 'star'], ['🌈', 'rainbow'], ['🌸', 'flower'], ['🌳', 'tree'], ['🦋', 'butterfly'], ['🐝', 'bee']], 3), age: 'kindergarten', diff: Difficulty.hard, minutes: 9, skills: ['memory', 'concentration']),
  ];

  // ============ PUZZLE ============
  static final List<Activity> _puzzle = [
    _a('puzzle_1', 'Farm Puzzle', ActivityType.puzzle, 'Build the picture from 4 pieces!', {'mode': 'jigsaw', 'rows': 2, 'cols': 2, 'pictures': ['🐮', '🐷']}, age: 'toddler', skills: ['logic', 'spatial awareness']),
    _a('puzzle_2', 'Jungle Puzzle', ActivityType.puzzle, 'Put the jungle animals together!', {'mode': 'jigsaw', 'rows': 2, 'cols': 3, 'pictures': ['🦁', '🐘']}, skills: ['logic', 'spatial awareness']),
    _a('puzzle_3', 'Pattern Party', ActivityType.puzzle, 'What comes next? Red, blue, red, blue...', {'mode': 'pattern', 'kinds': ['AB']}, skills: ['logic', 'patterns']),
    _a('puzzle_4', 'Odd One Out', ActivityType.puzzle, 'Spot the one that is different!', {'mode': 'odd', 'groups': [['🍎', '🚗'], ['🐶', '🌳'], ['⭐', '🍕'], ['🐱', '⚽'], ['🌞', '🐟']]}, diff: Difficulty.medium, skills: ['logic', 'reasoning']),
    _a('puzzle_5', 'Tricky Patterns', ActivityType.puzzle, 'Longer patterns with three things!', {'mode': 'pattern', 'kinds': ['AAB', 'ABC']}, diff: Difficulty.medium, skills: ['logic', 'patterns']),
    _a('puzzle_6', 'Big Puzzle', ActivityType.puzzle, 'A nine piece puzzle!', {'mode': 'jigsaw', 'rows': 3, 'cols': 3, 'pictures': ['🦄', '🐉']}, age: 'kindergarten', diff: Difficulty.hard, minutes: 8, skills: ['logic', 'spatial awareness']),
  ];

  // ============ CREATIVITY ============
  static final List<Activity> _creativity = [
    _a('creativity_1', 'Magic Drawing', ActivityType.creativity, 'Draw with rainbow paint!', {'mode': 'free'}, age: 'toddler', minutes: 8, skills: ['creativity', 'self expression']),
    _a('creativity_2', 'Color the House', ActivityType.creativity, 'Color a cozy house!', {'mode': 'color', 'template': 'house'}, age: 'toddler', minutes: 6, skills: ['creativity', 'colors']),
    _a('creativity_3', 'Color the Flower', ActivityType.creativity, 'Make a pretty flower!', {'mode': 'color', 'template': 'flower'}, minutes: 6, skills: ['creativity', 'colors']),
    _a('creativity_4', 'Sticker Meadow', ActivityType.creativity, 'Decorate the meadow with stickers!', {'mode': 'stamps'}, minutes: 6, skills: ['creativity', 'imagination']),
    _a('creativity_5', 'Color the Fish', ActivityType.creativity, 'Make a rainbow fish!', {'mode': 'color', 'template': 'fish'}, diff: Difficulty.medium, minutes: 6, skills: ['creativity', 'colors']),
    _a('creativity_6', 'Color the Butterfly', ActivityType.creativity, 'Paint beautiful wings!', {'mode': 'color', 'template': 'butterfly'}, age: 'kindergarten', diff: Difficulty.medium, minutes: 7, skills: ['creativity', 'colors']),
  ];

  // ============ EMOTIONS & KINDNESS ============
  static final List<Activity> _emotion = [
    _a('emotion_1', 'Happy and Sad', ActivityType.emotion, 'Learn two big feelings!', {'mode': 'faces', 'emotions': ['happy', 'sad']}, age: 'toddler', skills: ['social', 'emotional intelligence']),
    _a('emotion_2', 'Angry and Scared', ActivityType.emotion, 'Feelings that are hard sometimes.', {'mode': 'faces', 'emotions': ['angry', 'scared']}, skills: ['social', 'emotional intelligence']),
    _a('emotion_3', 'Surprised Sleepy Excited', ActivityType.emotion, 'Three more feelings!', {'mode': 'faces', 'emotions': ['surprised', 'sleepy', 'excited']}, skills: ['social', 'emotional intelligence']),
    _a('emotion_4', 'How Do You Feel?', ActivityType.emotion, 'Stories and feelings.', {'mode': 'scenarios', 'emotions': ['happy', 'sad', 'angry', 'scared', 'surprised']}, diff: Difficulty.medium, skills: ['social', 'emotional intelligence']),
    _a('emotion_5', 'Being Kind', ActivityType.emotion, 'How can we help our friends?', {'mode': 'helping'}, diff: Difficulty.medium, skills: ['social', 'empathy']),
    _a('emotion_6', 'Calm Bubble', ActivityType.emotion, 'Breathe slowly and feel calm.', {'mode': 'breathing'}, age: 'kindergarten', skills: ['social', 'self control']),
  ];

  // ============ MUSIC ============
  static final List<Activity> _music = [
    _a('music_1', 'Animal Sounds', ActivityType.music, 'Who says woof? Who says moo?', {
      'mode': 'sounds',
      'items': [
        {'k': 'Dog', 'emoji': '🐶', 'sound': 'Woof woof'},
        {'k': 'Cat', 'emoji': '🐱', 'sound': 'Meow'},
        {'k': 'Cow', 'emoji': '🐮', 'sound': 'Moo'},
        {'k': 'Duck', 'emoji': '🦆', 'sound': 'Quack quack'},
      ]
    }, age: 'toddler', skills: ['creativity', 'listening']),
    _a('music_2', 'Farm Orchestra', ActivityType.music, 'More animal voices!', {
      'mode': 'sounds',
      'items': [
        {'k': 'Pig', 'emoji': '🐷', 'sound': 'Oink oink'},
        {'k': 'Sheep', 'emoji': '🐑', 'sound': 'Baa baa'},
        {'k': 'Rooster', 'emoji': '🐓', 'sound': 'Cock a doodle doo'},
        {'k': 'Horse', 'emoji': '🐴', 'sound': 'Neigh'},
      ]
    }, skills: ['creativity', 'listening']),
    _a('music_3', 'High and Low', ActivityType.music, 'Is the sound high or low?', {'mode': 'pitch'}, diff: Difficulty.medium, skills: ['creativity', 'listening']),
    _a('music_4', 'Instruments', ActivityType.music, 'Meet the band!', {
      'mode': 'instruments',
      'items': [
        {'k': 'Drum', 'emoji': '🥁', 'sound': 'Boom boom'},
        {'k': 'Guitar', 'emoji': '🎸', 'sound': 'Strum strum'},
        {'k': 'Trumpet', 'emoji': '🎺', 'sound': 'Toot toot'},
        {'k': 'Piano', 'emoji': '🎹', 'sound': 'Plink plonk'},
      ]
    }, diff: Difficulty.medium, skills: ['creativity', 'listening']),
    _a('music_5', 'Play the Piano', ActivityType.music, 'Play Twinkle Twinkle Little Star!', {'mode': 'piano'}, diff: Difficulty.medium, minutes: 6, skills: ['creativity', 'music']),
    _a('music_6', 'Copy the Song', ActivityType.music, 'Listen, remember and play it back!', {'mode': 'simon', 'length': 5}, age: 'kindergarten', diff: Difficulty.hard, minutes: 7, skills: ['creativity', 'memory', 'music']),
  ];
}
