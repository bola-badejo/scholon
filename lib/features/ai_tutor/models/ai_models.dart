/// What the learner is looking at when they ask for help.
class AiContext {
  final String screen; // 'lesson', 'quiz', 'library', 'course', 'home'...
  final String? courseCode;
  final String? courseName;
  final String? lessonTitle;
  final String? selectedText;
  final String? videoTranscriptExcerpt; // only when a verified transcript exists
  final String level; // 'simple' | 'beginner' | 'detailed' | 'university'

  const AiContext({
    this.screen = 'home',
    this.courseCode,
    this.courseName,
    this.lessonTitle,
    this.selectedText,
    this.videoTranscriptExcerpt,
    this.level = 'beginner',
  });

  AiContext copyWith({String? level}) => AiContext(
        screen: screen,
        courseCode: courseCode,
        courseName: courseName,
        lessonTitle: lessonTitle,
        selectedText: selectedText,
        videoTranscriptExcerpt: videoTranscriptExcerpt,
        level: level ?? this.level,
      );
}

/// A passage the answer was grounded in. Shown to the learner as a reference.
class SourceRef {
  final String title;
  final String locator; // e.g. "MAT > Term 1 > Week 2 > Limits"
  final String sourceType; // note | quiz-explanation | overview | library
  final String license;
  const SourceRef({required this.title, required this.locator, required this.sourceType, this.license = 'Scholon course material'});

  Map<String, dynamic> toJson() => {'title': title, 'locator': locator, 'type': sourceType, 'license': license};
  factory SourceRef.fromJson(Map<String, dynamic> j) => SourceRef(title: j['title'] ?? '', locator: j['locator'] ?? '', sourceType: j['type'] ?? '', license: j['license'] ?? '');
}

enum ChatRole { user, assistant }

/// How an answer was produced. Never blurred in the UI.
enum AnswerOrigin { generative, offlineLookup, system }

class ChatMessage {
  final String id;
  final ChatRole role;
  final String text;
  final DateTime at;
  final List<SourceRef> sources;
  final AnswerOrigin origin;
  final bool failed;

  const ChatMessage({required this.id, required this.role, required this.text, required this.at, this.sources = const [], this.origin = AnswerOrigin.generative, this.failed = false});

  ChatMessage copyWith({String? text, List<SourceRef>? sources, bool? failed, AnswerOrigin? origin}) =>
      ChatMessage(id: id, role: role, text: text ?? this.text, at: at, sources: sources ?? this.sources, origin: origin ?? this.origin, failed: failed ?? this.failed);

  Map<String, dynamic> toJson() => {'id': id, 'role': role.name, 'text': text, 'at': at.toIso8601String(), 'sources': sources.map((s) => s.toJson()).toList(), 'origin': origin.name, 'failed': failed};

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'] ?? '',
        role: ChatRole.values.firstWhere((r) => r.name == j['role'], orElse: () => ChatRole.assistant),
        text: j['text'] ?? '',
        at: DateTime.tryParse(j['at'] ?? '') ?? DateTime.now(),
        sources: ((j['sources'] as List?) ?? const []).map((e) => SourceRef.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
        origin: AnswerOrigin.values.firstWhere((o) => o.name == j['origin'], orElse: () => AnswerOrigin.generative),
        failed: j['failed'] == true,
      );
}

class Conversation {
  final String id;
  String title;
  final List<ChatMessage> messages;
  final DateTime updated;
  Conversation({required this.id, required this.title, required this.messages, DateTime? updated}) : updated = updated ?? DateTime.now();

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'updated': DateTime.now().toIso8601String(), 'messages': messages.map((m) => m.toJson()).toList()};
  factory Conversation.fromJson(Map<String, dynamic> j) => Conversation(
        id: j['id'] ?? '',
        title: j['title'] ?? 'Conversation',
        updated: DateTime.tryParse(j['updated'] ?? ''),
        messages: ((j['messages'] as List?) ?? const []).map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      );
}

/// What a runtime reports about itself, shown in the model status UI.
class ModelInfo {
  final String name;
  final String runtime; // 'scholon-hosted' | 'on-device' | 'offline-lookup'
  final bool available;
  final String detail;
  const ModelInfo({required this.name, required this.runtime, required this.available, required this.detail});
}
