// lib/Kidling/data/data.dart
//
// NEW CURRICULUM: 8 worlds x 6 levels = 48 activities.
// Every world climbs gently: meet a few things -> more things -> mix them ->
// use them in a new way. Content here only lists WHAT to teach; the lesson
// engine decides HOW (Learn -> Try together -> Star challenge).
//
// Usage (once, from a debug button or main): await SeedActivities.seedAllActivities();

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isapp/features/kidling/models/kidling_model.dart';

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
    KidActivityType type,
    String desc,
    Map<String, dynamic> content, {
    String age = 'preschool',
    KidDifficulty diff = KidDifficulty.easy,
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
    _a('phonics_1', 'Sounds S A T P', KidActivityType.phonics, 'Meet four letters and their sounds!', {'mode': 'letters', 'letters': ['S', 'A', 'T', 'P']}, age: 'toddler', skills: ['literacy', 'phonics']),
    _a('phonics_2', 'Sounds I N M D', KidActivityType.phonics, 'Four new letter friends!', {'mode': 'letters', 'letters': ['I', 'N', 'M', 'D']}, skills: ['literacy', 'phonics']),
    _a('phonics_3', 'Sounds G O C K', KidActivityType.phonics, 'More sounds to discover!', {'mode': 'letters', 'letters': ['G', 'O', 'C', 'K']}, skills: ['literacy', 'phonics']),
    _a('phonics_4', 'Sounds E U R H', KidActivityType.phonics, 'Four more letters!', {'mode': 'letters', 'letters': ['E', 'U', 'R', 'H']}, diff: KidDifficulty.medium, skills: ['literacy', 'phonics']),
    _a('phonics_5', 'Sounds B F L J', KidActivityType.phonics, 'Almost the whole alphabet!', {'mode': 'letters', 'letters': ['B', 'F', 'L', 'J']}, diff: KidDifficulty.medium, skills: ['literacy', 'phonics']),
    _a('phonics_6', 'Sounds Q V W X Y Z', KidActivityType.phonics, 'The last six letters!', {'mode': 'letters', 'letters': ['Q', 'V', 'W', 'X', 'Y', 'Z']}, age: 'kindergarten', diff: KidDifficulty.hard, minutes: 7, skills: ['literacy', 'phonics']),
  ];

  // ============ COLORS & SHAPES ============
  static final List<Activity> _colors = [
    _a('color_1', 'Red Blue Yellow', KidActivityType.colorShape, 'Learn the first colors!', {'mode': 'colors', 'items': ['red', 'blue', 'yellow']}, age: 'toddler', skills: ['logic', 'colors']),
    _a('color_2', 'Green Orange Purple', KidActivityType.colorShape, 'Three more colors!', {'mode': 'colors', 'items': ['green', 'orange', 'purple']}, age: 'toddler', skills: ['logic', 'colors']),
    _a('color_3', 'Pink Brown Black White', KidActivityType.colorShape, 'Finish the rainbow!', {'mode': 'colors', 'items': ['pink', 'brown', 'black', 'white']}, skills: ['logic', 'colors']),
    _a('color_4', 'Circle Square Triangle', KidActivityType.colorShape, 'Meet three shapes!', {'mode': 'shapes', 'items': ['circle', 'square', 'triangle']}, skills: ['logic', 'shapes']),
    _a('color_5', 'More Shapes', KidActivityType.colorShape, 'Rectangle, star, heart and oval!', {'mode': 'shapes', 'items': ['rectangle', 'star', 'heart', 'oval']}, diff: KidDifficulty.medium, skills: ['logic', 'shapes']),
    _a('color_6', 'Colorful Shapes', KidActivityType.colorShape, 'Find the blue triangle!', {'mode': 'combo', 'shapes': ['circle', 'square', 'triangle', 'star'], 'colors': ['red', 'blue', 'green', 'yellow']}, age: 'kindergarten', diff: KidDifficulty.hard, skills: ['logic', 'colors', 'shapes']),
  ];

  // ============ COUNTING ============
  static final List<Activity> _counting = [
    _a('counting_1', 'Count to 3', KidActivityType.counting, 'Count the chicks!', {'min': 1, 'max': 3, 'object': '🐥', 'task': 'count'}, age: 'toddler', skills: ['numeracy', 'counting']),
    _a('counting_2', 'Count to 5', KidActivityType.counting, 'Count the apples!', {'min': 1, 'max': 5, 'object': '🍎', 'task': 'count'}, age: 'toddler', skills: ['numeracy', 'counting']),
    _a('counting_3', 'Give Me Five', KidActivityType.counting, 'Count and give me the right number!', {'min': 1, 'max': 5, 'object': '⭐', 'task': 'mixed'}, skills: ['numeracy', 'counting']),
    _a('counting_4', 'Count to 10', KidActivityType.counting, 'Bigger numbers up to ten!', {'min': 4, 'max': 10, 'object': '🍪', 'task': 'count'}, diff: KidDifficulty.medium, skills: ['numeracy', 'counting']),
    _a('counting_5', 'Give Me Ten', KidActivityType.counting, 'Fill the basket with the right number!', {'min': 3, 'max': 10, 'object': '🎈', 'task': 'give'}, diff: KidDifficulty.medium, skills: ['numeracy', 'counting']),
    _a('counting_6', 'Count to 15', KidActivityType.counting, 'Big counting challenge!', {'min': 8, 'max': 15, 'object': '🦋', 'task': 'mixed'}, age: 'kindergarten', diff: KidDifficulty.hard, minutes: 7, skills: ['numeracy', 'counting']),
  ];

  // ============ MEMORY (more pairs, shorter peek each level) ============
  static Map<String, dynamic> _cards(List<List<String>> c, int peek) =>
      {'cards': c.map((e) => {'e': e[0], 'n': e[1]}).toList(), 'peek': peek};

  static final List<Activity> _memory = [
    _a('memory_1', 'Animal Pairs', KidActivityType.memory, 'Find the matching animals!', _cards([['🐶', 'dog'], ['🐱', 'cat']], 5), age: 'toddler', skills: ['memory', 'concentration']),
    _a('memory_2', 'Fruit Match', KidActivityType.memory, 'Match the yummy fruits!', _cards([['🍎', 'apple'], ['🍌', 'banana'], ['🍇', 'grapes']], 5), age: 'toddler', skills: ['memory', 'concentration']),
    _a('memory_3', 'Zoo Match', KidActivityType.memory, 'Four zoo friends are hiding!', _cards([['🦁', 'lion'], ['🐘', 'elephant'], ['🐵', 'monkey'], ['🦒', 'giraffe']], 4), skills: ['memory', 'concentration']),
    _a('memory_4', 'Things That Go', KidActivityType.memory, 'Five vehicles to find!', _cards([['🚗', 'car'], ['🚌', 'bus'], ['🚲', 'bike'], ['✈️', 'plane'], ['🚂', 'train']], 4), diff: KidDifficulty.medium, skills: ['memory', 'concentration']),
    _a('memory_5', 'Sea Friends', KidActivityType.memory, 'Six sea animals!', _cards([['🐟', 'fish'], ['🐙', 'octopus'], ['🐢', 'turtle'], ['🦀', 'crab'], ['🐳', 'whale'], ['🐬', 'dolphin']], 3), diff: KidDifficulty.medium, minutes: 7, skills: ['memory', 'concentration']),
    _a('memory_6', 'Super Memory', KidActivityType.memory, 'Eight pairs. Quick peek!', _cards([['🌞', 'sun'], ['🌙', 'moon'], ['⭐', 'star'], ['🌈', 'rainbow'], ['🌸', 'flower'], ['🌳', 'tree'], ['🦋', 'butterfly'], ['🐝', 'bee']], 3), age: 'kindergarten', diff: KidDifficulty.hard, minutes: 9, skills: ['memory', 'concentration']),
  ];

  // ============ PUZZLE ============
  static final List<Activity> _puzzle = [
    _a('puzzle_1', 'Farm Puzzle', KidActivityType.puzzle, 'Build the picture from 4 pieces!', {'mode': 'jigsaw', 'rows': 2, 'cols': 2, 'pictures': ['🐮', '🐷']}, age: 'toddler', skills: ['logic', 'spatial awareness']),
    _a('puzzle_2', 'Jungle Puzzle', KidActivityType.puzzle, 'Put the jungle animals together!', {'mode': 'jigsaw', 'rows': 2, 'cols': 3, 'pictures': ['🦁', '🐘']}, skills: ['logic', 'spatial awareness']),
    _a('puzzle_3', 'Pattern Party', KidActivityType.puzzle, 'What comes next? Red, blue, red, blue...', {'mode': 'pattern', 'kinds': ['AB']}, skills: ['logic', 'patterns']),
    _a('puzzle_4', 'Odd One Out', KidActivityType.puzzle, 'Spot the one that is different!', {'mode': 'odd', 'groups': [['🍎', '🚗'], ['🐶', '🌳'], ['⭐', '🍕'], ['🐱', '⚽'], ['🌞', '🐟']]}, diff: KidDifficulty.medium, skills: ['logic', 'reasoning']),
    _a('puzzle_5', 'Tricky Patterns', KidActivityType.puzzle, 'Longer patterns with three things!', {'mode': 'pattern', 'kinds': ['AAB', 'ABC']}, diff: KidDifficulty.medium, skills: ['logic', 'patterns']),
    _a('puzzle_6', 'Big Puzzle', KidActivityType.puzzle, 'A nine piece puzzle!', {'mode': 'jigsaw', 'rows': 3, 'cols': 3, 'pictures': ['🦄', '🐉']}, age: 'kindergarten', diff: KidDifficulty.hard, minutes: 8, skills: ['logic', 'spatial awareness']),
  ];

  // ============ CREATIVITY ============
  static final List<Activity> _creativity = [
    _a('creativity_1', 'Magic Drawing', KidActivityType.creativity, 'Draw with rainbow paint!', {'mode': 'free'}, age: 'toddler', minutes: 8, skills: ['creativity', 'self expression']),
    _a('creativity_2', 'Color the House', KidActivityType.creativity, 'Color a cozy house!', {'mode': 'color', 'template': 'house'}, age: 'toddler', minutes: 6, skills: ['creativity', 'colors']),
    _a('creativity_3', 'Color the Flower', KidActivityType.creativity, 'Make a pretty flower!', {'mode': 'color', 'template': 'flower'}, minutes: 6, skills: ['creativity', 'colors']),
    _a('creativity_4', 'Sticker Meadow', KidActivityType.creativity, 'Decorate the meadow with stickers!', {'mode': 'stamps'}, minutes: 6, skills: ['creativity', 'imagination']),
    _a('creativity_5', 'Color the Fish', KidActivityType.creativity, 'Make a rainbow fish!', {'mode': 'color', 'template': 'fish'}, diff: KidDifficulty.medium, minutes: 6, skills: ['creativity', 'colors']),
    _a('creativity_6', 'Color the Butterfly', KidActivityType.creativity, 'Paint beautiful wings!', {'mode': 'color', 'template': 'butterfly'}, age: 'kindergarten', diff: KidDifficulty.medium, minutes: 7, skills: ['creativity', 'colors']),
  ];

  // ============ EMOTIONS & KINDNESS ============
  static final List<Activity> _emotion = [
    _a('emotion_1', 'Happy and Sad', KidActivityType.emotion, 'Learn two big feelings!', {'mode': 'faces', 'emotions': ['happy', 'sad']}, age: 'toddler', skills: ['social', 'emotional intelligence']),
    _a('emotion_2', 'Angry and Scared', KidActivityType.emotion, 'Feelings that are hard sometimes.', {'mode': 'faces', 'emotions': ['angry', 'scared']}, skills: ['social', 'emotional intelligence']),
    _a('emotion_3', 'Surprised Sleepy Excited', KidActivityType.emotion, 'Three more feelings!', {'mode': 'faces', 'emotions': ['surprised', 'sleepy', 'excited']}, skills: ['social', 'emotional intelligence']),
    _a('emotion_4', 'How Do You Feel?', KidActivityType.emotion, 'Stories and feelings.', {'mode': 'scenarios', 'emotions': ['happy', 'sad', 'angry', 'scared', 'surprised']}, diff: KidDifficulty.medium, skills: ['social', 'emotional intelligence']),
    _a('emotion_5', 'Being Kind', KidActivityType.emotion, 'How can we help our friends?', {'mode': 'helping'}, diff: KidDifficulty.medium, skills: ['social', 'empathy']),
    _a('emotion_6', 'Calm Bubble', KidActivityType.emotion, 'Breathe slowly and feel calm.', {'mode': 'breathing'}, age: 'kindergarten', skills: ['social', 'self control']),
  ];

  // ============ MUSIC ============
  static final List<Activity> _music = [
    _a('music_1', 'Animal Sounds', KidActivityType.music, 'Who says woof? Who says moo?', {
      'mode': 'sounds',
      'items': [
        {'k': 'Dog', 'emoji': '🐶', 'sound': 'Woof woof'},
        {'k': 'Cat', 'emoji': '🐱', 'sound': 'Meow'},
        {'k': 'Cow', 'emoji': '🐮', 'sound': 'Moo'},
        {'k': 'Duck', 'emoji': '🦆', 'sound': 'Quack quack'},
      ]
    }, age: 'toddler', skills: ['creativity', 'listening']),
    _a('music_2', 'Farm Orchestra', KidActivityType.music, 'More animal voices!', {
      'mode': 'sounds',
      'items': [
        {'k': 'Pig', 'emoji': '🐷', 'sound': 'Oink oink'},
        {'k': 'Sheep', 'emoji': '🐑', 'sound': 'Baa baa'},
        {'k': 'Rooster', 'emoji': '🐓', 'sound': 'Cock a doodle doo'},
        {'k': 'Horse', 'emoji': '🐴', 'sound': 'Neigh'},
      ]
    }, skills: ['creativity', 'listening']),
    _a('music_3', 'High and Low', KidActivityType.music, 'Is the sound high or low?', {'mode': 'pitch'}, diff: KidDifficulty.medium, skills: ['creativity', 'listening']),
    _a('music_4', 'Instruments', KidActivityType.music, 'Meet the band!', {
      'mode': 'instruments',
      'items': [
        {'k': 'Drum', 'emoji': '🥁', 'sound': 'Boom boom'},
        {'k': 'Guitar', 'emoji': '🎸', 'sound': 'Strum strum'},
        {'k': 'Trumpet', 'emoji': '🎺', 'sound': 'Toot toot'},
        {'k': 'Piano', 'emoji': '🎹', 'sound': 'Plink plonk'},
      ]
    }, diff: KidDifficulty.medium, skills: ['creativity', 'listening']),
    _a('music_5', 'Play the Piano', KidActivityType.music, 'Play Twinkle Twinkle Little Star!', {'mode': 'piano'}, diff: KidDifficulty.medium, minutes: 6, skills: ['creativity', 'music']),
    _a('music_6', 'Copy the Song', KidActivityType.music, 'Listen, remember and play it back!', {'mode': 'simon', 'length': 5}, age: 'kindergarten', diff: KidDifficulty.hard, minutes: 7, skills: ['creativity', 'memory', 'music']),
  ];
}
