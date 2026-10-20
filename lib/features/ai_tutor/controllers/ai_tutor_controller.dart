import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:isapp/features/ai_tutor/models/ai_models.dart';
import 'package:isapp/features/ai_tutor/services/curriculum_knowledge_builder.dart';
import 'package:isapp/features/ai_tutor/services/inference_provider.dart';
import 'package:isapp/features/ai_tutor/services/knowledge_index.dart';
import 'package:isapp/features/ai_tutor/services/prompt_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Conversation state, retrieval, provider fallback (hosted -> offline lookup),
/// stop/retry and local history.
class AiTutorController extends GetxController {
  AiTutorController({InferenceProvider? hosted, InferenceProvider? onDevice})
    : _hosted = hosted ?? ScholonHostedProvider(),
      _onDevice = onDevice ?? OnDeviceProvider();

  final InferenceProvider _hosted;
  final InferenceProvider _onDevice;
  static const _uuid = Uuid();

  final messages = <ChatMessage>[].obs;
  final conversations = <Conversation>[].obs;
  final isGenerating = false.obs;
  final indexReady = false.obs;
  final status = const ModelInfo(
    name: 'Scholon AI',
    runtime: 'scholon-hosted',
    available: false,
    detail: 'Checking...',
  ).obs;
  final level = 'beginner'.obs;
  final context = const AiContext().obs;

  KnowledgeIndex? _index;
  String _conversationId = _uuid.v4();
  StreamSubscription<String>? _sub;
  DateTime _lastSend = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void onInit() {
    super.onInit();
    _loadHistory();
    refreshStatus();
    CurriculumKnowledgeBuilder.build().then((i) {
      _index = i;
      indexReady.value = true;
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  void setContext(AiContext c) =>
      context.value = c.copyWith(level: level.value);
  void setLevel(String l) {
    level.value = l;
    context.value = context.value.copyWith(level: l);
  }

  Future<void> refreshStatus() async {
    final s = await _hosted.status();
    status.value = s.available
        ? s
        : (await _onDevice.status()).available
        ? await _onDevice.status()
        : s;
  }

  bool get canGenerate => status.value.available;

  List<String> get suggestions {
    final c = context.value;
    if (c.lessonTitle != null) {
      return [
        'Explain "${c.lessonTitle}" simply',
        'Give me a worked example',
        'Quiz me on this lesson',
        'What mistakes do students make here?',
      ];
    }
    if (c.courseName != null) {
      return [
        'What will I learn in ${c.courseName}?',
        'What should I know before starting?',
        'Make a study plan for this course',
      ];
    }
    return [
      'Explain a topic I am stuck on',
      'Help me plan my revision',
      'Quiz me on what I studied today',
    ];
  }

  Future<void> send(String text) async {
    final q = text.trim();
    if (q.isEmpty || isGenerating.value) return;
    if (DateTime.now().difference(_lastSend) <
        const Duration(milliseconds: 1200)) {
      return;
    }
    _lastSend = DateTime.now();

    final history = messages.toList();
    messages.add(
      ChatMessage(
        id: _uuid.v4(),
        role: ChatRole.user,
        text: q,
        at: DateTime.now(),
      ),
    );
    await _answer(q, history);
  }

  Future<void> retryLast() async {
    if (isGenerating.value) return;
    final lastUserIndex = messages.lastIndexWhere(
      (m) => m.role == ChatRole.user,
    );

    if (lastUserIndex == -1) return;

    final lastUser = messages[lastUserIndex];
    
    while (messages.isNotEmpty && messages.last.role == ChatRole.assistant) {
      messages.removeLast();
    }
    
    final history = messages.take(lastUserIndex).toList();

    await _answer(lastUser.text, history);
  }

  Future<void> _answer(String q, List<ChatMessage> history) async {
    isGenerating.value = true;
    final hits =
        _index?.search(
          '$q ${context.value.lessonTitle ?? ''}',
          k: 4,
          courseCode: context.value.courseCode,
        ) ??
        const <ScoredChunk>[];
    final prompt = PromptBuilder.build(
      question: q,
      history: history,
      context: context.value,
      retrieved: hits,
    );

    final id = _uuid.v4();
    messages.add(
      ChatMessage(
        id: id,
        role: ChatRole.assistant,
        text: '',
        at: DateTime.now(),
        sources: prompt.sources,
      ),
    );
    final idx = messages.length - 1;

    await refreshStatus();
    if (!canGenerate) {
      messages[idx] = messages[idx].copyWith(
        text: OfflineLookup.answer(q, hits),
        origin: AnswerOrigin.offlineLookup,
        sources: hits.take(3).map((h) => h.chunk.toRef()).toList(),
      );
      isGenerating.value = false;
      _save();
      return;
    }

    final provider = status.value.runtime == 'on-device' ? _onDevice : _hosted;
    final done = Completer<void>();
    final buf = StringBuffer();
    _sub = provider
        .generate(prompt)
        .listen(
          (tok) {
            buf.write(tok);
            messages[idx] = messages[idx].copyWith(text: buf.toString());
          },
          onError: (e) {
            final msg = e is StateError
                ? e.message
                : 'Something went wrong while answering.';
            messages[idx] = messages[idx].copyWith(
              text: buf.isEmpty ? msg : '${buf.toString()}\n\n($msg)',
              failed: true,
              origin: AnswerOrigin.system,
            );
            if (!done.isCompleted) done.complete();
          },
          onDone: () {
            if (buf.isEmpty) {
              messages[idx] = messages[idx].copyWith(
                text: 'No answer was returned. Please try again.',
                failed: true,
                origin: AnswerOrigin.system,
              );
            }
            if (!done.isCompleted) done.complete();
          },
          cancelOnError: true,
        );
    await done.future;
    _sub = null;
    isGenerating.value = false;
    _save();
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    if (messages.isNotEmpty &&
        messages.last.role == ChatRole.assistant &&
        messages.last.text.isEmpty) {
      messages[messages.length - 1] = messages.last.copyWith(
        text: 'Stopped.',
        origin: AnswerOrigin.system,
      );
    }
    isGenerating.value = false;
    _save();
  }

  void newConversation() {
    stop();
    _conversationId = _uuid.v4();
    messages.clear();
  }

  void openConversation(Conversation c) {
    stop();
    _conversationId = c.id;
    messages.assignAll(c.messages);
  }

  // ---- history (local, per device) ----
  Future<void> _loadHistory() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final l = jsonDecode(sp.getString('ai_conversations') ?? '[]') as List;
      conversations.assignAll(
        l.map(
          (e) => Conversation.fromJson(Map<String, dynamic>.from(e as Map)),
        ),
      );
    } catch (e) {
      debugPrint('AI history load failed: $e');
    }
  }

  Future<void> _save() async {
    if (messages.isEmpty) return;
    final firstUser =
        messages.firstWhereOrNull((m) => m.role == ChatRole.user)?.text ??
        'Conversation';
    final conv = Conversation(
      id: _conversationId,
      title: firstUser.length > 48
          ? '${firstUser.substring(0, 48)}...'
          : firstUser,
      messages: messages.toList(),
    );
    conversations.removeWhere((c) => c.id == conv.id);
    conversations.insert(0, conv);
    if (conversations.length > 30) {
      conversations.removeRange(30, conversations.length);
    }
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(
        'ai_conversations',
        jsonEncode(conversations.map((c) => c.toJson()).toList()),
      );
    } catch (_) {}
  }

  Future<void> deleteConversation(Conversation c) async {
    conversations.removeWhere((x) => x.id == c.id);
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      'ai_conversations',
      jsonEncode(conversations.map((c) => c.toJson()).toList()),
    );
  }
}
