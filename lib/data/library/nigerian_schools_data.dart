class NigerianSchoolData {
  // Nigerian School Classes Structure
  static final Map<String, List<String>> classesByLevel = {
    'Basic': [
      'Basic 1',
      'Basic 2', 
      'Basic 3',
      'Basic 4',
      'Basic 5',
      'Basic 6',
      'Basic 7',
      'Basic 8',
      'Basic 9',
    ],
    'Senior Secondary': [
      'SSS 1 (Senior Secondary 1)',
      'SSS 2 (Senior Secondary 2)',
      'SSS 3 (Senior Secondary 3)',
    ],
  };

  // Nigerian Subjects
  static final List<String> subjects = [
    'Mathematics',
    'English Language',
    'Basic Science',
    'Basic Technology',
    'Social Studies',
    'Home Economics',
    'Agricultural Science',
    'Physical & Health Education',
    'Computer Studies',
    'Creative & Cultural Arts',
    'Civic Education',
    'Security Education',
    'Christian Religious Studies',
    'Islamic Religious Studies',
    'Yoruba Language',
    'Igbo Language',
    'Hausa Language',
    'French',
    'Business Studies',
    'Economics',
    'Commerce',
    'Financial Accounting',
    'Biology',
    'Chemistry',
    'Physics',
    'Further Mathematics',
    'Literature in English',
    'Government',
    'Geography',
    'History',
    'Technical Drawing',
    'Food & Nutrition',
    'Music',
    'Visual Arts',
  ];

  // Nigerian States
  static final List<String> states = [
    'Abia',
    'Adamawa',
    'Akwa Ibom',
    'Anambra',
    'Bauchi',
    'Bayelsa',
    'Benue',
    'Borno',
    'Cross River',
    'Delta',
    'Ebonyi',
    'Edo',
    'Ekiti',
    'Enugu',
    'Federal Capital Territory (FCT)',
    'Gombe',
    'Imo',
    'Jigawa',
    'Kaduna',
    'Kano',
    'Katsina',
    'Kebbi',
    'Kogi',
    'Kwara',
    'Lagos',
    'Nasarawa',
    'Niger',
    'Ogun',
    'Ondo',
    'Osun',
    'Oyo',
    'Plateau',
    'Rivers',
    'Sokoto',
    'Taraba',
    'Yobe',
    'Zamfara',
  ];

  // Event Categories for Nigerian Schools
  static final List<String> eventCategories = [
    'Academic',
    'Sports',
    'Cultural',
    'Religious',
    'Parents Meeting',
    'PTA Meeting',
    'Examination',
    'Excursion',
    'Career Day',
    'Speech & Prize Giving',
    'Graduation',
    'Inter-House Competition',
    'Inter-School Competition',
    'Science Fair',
    'Debate',
    'Music & Drama',
    'Founder\'s Day',
    'Open Day',
    'Workshop',
    'Seminar',
  ];

  // Announcement Targets for Nigerian Schools
  static final Map<String, List<String>> announcementTargets = {
    'All': ['All Users'],
    'Students': [
      'Basic 1-3',
      'Basic 4-6', 
      'Basic 7-9',
      'SSS 1',
      'SSS 2',
      'SSS 3',
      'All Students'
    ],
    'Parents': ['All Parents'],
    'Teachers': ['All Teachers', 'Academic Staff', 'Non-Academic Staff'],
    'Specific Classes': [
      'Basic 1',
      'Basic 2',
      'Basic 3',
      'Basic 4',
      'Basic 5',
      'Basic 6',
      'Basic 7',
      'Basic 8',
      'Basic 9',
      'SSS 1',
      'SSS 2',
      'SSS 3',
    ],
  };

  // Get all classes as flat list
  static List<String> getAllClasses() {
    return [
      ...classesByLevel['Basic']!,
      ...classesByLevel['Senior Secondary']!,
    ];
  }

  // Get class level
  static String getClassLevel(String className) {
    if (className.contains('Basic')) return 'Basic';
    if (className.contains('SSS')) return 'Senior Secondary';
    return 'Unknown';
  }

  // Format class display
  static String formatClassDisplay(String className) {
    return className.replaceAll('SSS', 'Senior Secondary ');
  }

  // Get next class
  static String? getNextClass(String currentClass) {
    final allClasses = getAllClasses();
    final index = allClasses.indexOf(currentClass);
    if (index != -1 && index < allClasses.length - 1) {
      return allClasses[index + 1];
    }
    return null;
  }
}