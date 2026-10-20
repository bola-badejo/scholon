import 'package:flutter/material.dart';
import 'package:isapp/core/theme/scholar_theme.dart';
import 'package:isapp/features/ai_tutor/models/ai_models.dart';
import 'package:isapp/features/ai_tutor/screens/ai_tutor_screen.dart';

/// Contextual entry point. Place it on lessons, quizzes, library items...
/// The tutor opens as a separate route, so the lesson underneath keeps its
/// scroll position and state; popping returns right where the learner was.
class AskScholonButton extends StatelessWidget {
  final AiContext context;
  final String? question;
  final bool extended;
  const AskScholonButton({super.key, required this.context, this.question, this.extended = true});

  @override
  Widget build(BuildContext ctx) {
    void open() => AiTutorScreen.open(context, question);
    return extended
        ? FloatingActionButton.extended(onPressed: open, backgroundColor: Scholar.aurora, foregroundColor: Scholar.night, icon: const Icon(Icons.auto_awesome_rounded), label: const Text('Ask Scholon AI'), tooltip: 'Ask Scholon AI about this')
        : FloatingActionButton(onPressed: open, backgroundColor: Scholar.aurora, foregroundColor: Scholar.night, tooltip: 'Ask Scholon AI', child: const Icon(Icons.auto_awesome_rounded));
  }
}
