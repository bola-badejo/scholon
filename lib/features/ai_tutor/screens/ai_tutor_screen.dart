import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:isapp/core/design/reading_column.dart';
import 'package:isapp/core/design/scholon_type.dart';
import 'package:isapp/core/theme/scholar_theme.dart';
import 'package:isapp/features/ai_tutor/controllers/ai_tutor_controller.dart';
import 'package:isapp/features/ai_tutor/models/ai_models.dart';

/// Opens the tutor with the learner's current context, e.g.
///   AiTutorScreen.open(const AiContext(screen: 'lesson', courseName: 'Physics', lessonTitle: 'Motion'))
class AiTutorScreen extends StatefulWidget {
  final AiContext? initialContext;
  final String? firstQuestion;
  const AiTutorScreen({super.key, this.initialContext, this.firstQuestion});

  static Future<void> open([AiContext? context, String? question]) async {
    await Get.to(() => AiTutorScreen(initialContext: context, firstQuestion: question));
  }

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  late final AiTutorController c = Get.isRegistered<AiTutorController>() ? Get.find<AiTutorController>() : Get.put(AiTutorController());
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialContext != null) c.setContext(widget.initialContext!);
    if (widget.firstQuestion != null) WidgetsBinding.instance.addPostFrameCallback((_) => c.send(widget.firstQuestion!));
    ever(c.messages, (_) => _toBottom());
  }

  void _toBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      });

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _submit() {
    final t = _input.text;
    _input.clear();
    c.send(t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(gradient: Scholar.backdrop),
        child: SafeArea(
          child: Column(children: [
            _bar(),
            Expanded(
              child: ReadingColumn(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() => c.messages.isEmpty ? _empty() : _list()),
              ),
            ),
            ReadingColumn(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12), child: _composer()),
          ]),
        ),
      ),
    );
  }

  Widget _bar() => Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
        child: Row(children: [
          IconButton(onPressed: Get.back, tooltip: 'Back', icon: const Icon(Icons.arrow_back_rounded, color: Colors.white)),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Scholon AI', style: ScholonType.cardTitle(Colors.white)),
              Obx(() => _statusLine()),
            ]),
          ),
          IconButton(tooltip: 'History', onPressed: _history, icon: const Icon(Icons.history_rounded, color: Colors.white70)),
          IconButton(tooltip: 'New conversation', onPressed: c.newConversation, icon: const Icon(Icons.add_comment_outlined, color: Colors.white70)),
        ]),
      );

  Widget _statusLine() {
    final s = c.status.value;
    final color = s.available ? Scholar.mint : Scholar.sun;
    return Semantics(
      label: 'Model status: ${s.detail}',
      child: Row(children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 6),
        Flexible(child: Text(s.available ? '${s.name} - ${s.detail}' : 'Offline lookup only - ${s.detail}', maxLines: 1, overflow: TextOverflow.ellipsis, style: ScholonType.support(Colors.white60))),
        if (!s.available) TextButton(onPressed: c.refreshStatus, style: TextButton.styleFrom(minimumSize: const Size(0, 24), padding: const EdgeInsets.symmetric(horizontal: 8)), child: const Text('Retry')),
      ]),
    );
  }

  Widget _empty() => ListView(children: [
        const SizedBox(height: 28),
        Text('What would you like to understand?', style: ScholonType.pageTitle(Colors.white)),
        const SizedBox(height: 8),
        Text('Ask about your lessons. Answers cite the Scholon material they came from.', style: ScholonType.body(Colors.white70)),
        const SizedBox(height: 18),
        _levels(),
        const SizedBox(height: 18),
        for (final s in c.suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.white.withOpacity(.08),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => c.send(s),
                child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [Expanded(child: Text(s, style: ScholonType.body(Colors.white))), const Icon(Icons.north_east_rounded, size: 16, color: Colors.white54)])),
              ),
            ),
          ),
      ]);

  Widget _levels() {
    const names = {'simple': 'Simple', 'beginner': 'Beginner', 'detailed': 'Detailed', 'university': 'University', 'revision': 'Revision'};
    return Obx(() => Wrap(spacing: 8, runSpacing: 8, children: [
          for (final e in names.entries) ChoiceChip(label: Text(e.value), selected: c.level.value == e.key, onSelected: (_) => c.setLevel(e.key)),
        ]));
  }

  Widget _list() => ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: c.messages.length,
        itemBuilder: (_, i) => _bubble(c.messages[i], i == c.messages.length - 1),
      );

  Widget _bubble(ChatMessage m, bool last) {
    final mine = m.role == ChatRole.user;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 560),
        decoration: BoxDecoration(
          color: mine ? Scholar.violet : Colors.white.withOpacity(.09),
          borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomLeft: Radius.circular(mine ? 20 : 4), bottomRight: Radius.circular(mine ? 4 : 20)),
          border: m.failed ? Border.all(color: Scholar.coral.withOpacity(.6)) : null,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!mine && m.origin == AnswerOrigin.offlineLookup)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.find_in_page_rounded, size: 14, color: Scholar.sun),
                const SizedBox(width: 6),
                Text('Offline lookup - not AI-generated', style: ScholonType.label(Scholar.sun)),
              ]),
            ),
          if (mine)
            SelectableText(m.text, style: ScholonType.body(Colors.white))
          else if (m.text.isEmpty)
            const SizedBox(width: 40, height: 18, child: LinearProgressIndicator(color: Scholar.aurora, backgroundColor: Colors.white12))
          else
            MarkdownBody(
              data: m.text,
              selectable: true,
              styleSheet: MarkdownStyleSheet(p: ScholonType.body(Colors.white), listBullet: ScholonType.body(Colors.white), strong: ScholonType.body(Colors.white).copyWith(fontWeight: FontWeight.w700), code: ScholonType.code(color: Scholar.aurora)),
            ),
          if (!mine && m.sources.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Sources', style: ScholonType.label(Colors.white54)),
            const SizedBox(height: 4),
            for (var i = 0; i < m.sources.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('[${i + 1}] ${m.sources[i].title} - ${m.sources[i].locator}', style: ScholonType.support(Colors.white60)),
              ),
          ],
          if (!mine && m.text.isNotEmpty)
            Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(visualDensity: VisualDensity.compact, tooltip: 'Copy', onPressed: () {
                    Clipboard.setData(ClipboardData(text: m.text));
                    Get.snackbar('Copied', 'Answer copied to clipboard', duration: const Duration(seconds: 1));
                  }, icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white38)),
              if (last && !c.isGenerating.value) TextButton.icon(onPressed: c.retryLast, icon: const Icon(Icons.refresh_rounded, size: 16), label: const Text('Retry')),
            ]),
        ]),
      ),
    );
  }

  Widget _composer() => Obx(() => Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: TextField(
            controller: _input,
            minLines: 1,
            maxLines: 5,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _submit(),
            style: ScholonType.body(Colors.white),
            decoration: InputDecoration(
              hintText: c.context.value.lessonTitle != null ? 'Ask about "${c.context.value.lessonTitle}"' : 'Ask Scholon AI',
              hintStyle: ScholonType.body(Colors.white38),
              filled: true,
              fillColor: Colors.white.withOpacity(.09),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        c.isGenerating.value
            ? IconButton.filled(onPressed: c.stop, tooltip: 'Stop', style: IconButton.styleFrom(backgroundColor: Scholar.coral), icon: const Icon(Icons.stop_rounded))
            : IconButton.filled(onPressed: _submit, tooltip: 'Send', style: IconButton.styleFrom(backgroundColor: Scholar.aurora, foregroundColor: Scholar.night), icon: const Icon(Icons.arrow_upward_rounded)),
      ]));

  void _history() {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * .6),
        decoration: const BoxDecoration(color: Scholar.indigo, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Obx(() => c.conversations.isEmpty
            ? Padding(padding: const EdgeInsets.all(32), child: Text('No conversations yet.', style: ScholonType.body(Colors.white70)))
            : ListView(shrinkWrap: true, padding: const EdgeInsets.all(12), children: [
                for (final conv in c.conversations)
                  ListTile(
                    title: Text(conv.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: ScholonType.body(Colors.white)),
                    subtitle: Text('${conv.messages.length} messages', style: ScholonType.support(Colors.white54)),
                    trailing: IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.white38), onPressed: () => c.deleteConversation(conv), tooltip: 'Delete'),
                    onTap: () {
                      c.openConversation(conv);
                      Get.back();
                    },
                  ),
              ])),
      ),
    );
  }
}
