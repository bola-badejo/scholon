// lib/Kidling/screens/completion_overlay.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/Kidling/controllers/audio_assistant_services.dart';
import 'package:isapp/Kidling/models/kidling_model.dart';
import 'package:isapp/Kidling/screens/activity_page.dart';
import 'package:isapp/Kidling/theme/magic_theme.dart';
import 'package:isapp/Kidling/widgets/magic_widgets.dart';

class CompletionOverlay extends StatefulWidget {
  final Activity activity;
  final int stars;
  final double accuracy;
  final String timeSpent;
  final int firstTryCorrect;
  final int totalQuestions;
  final Activity? next;
  final bool isNewBest;
  final VoidCallback onReplay;

  const CompletionOverlay({
    super.key,
    required this.activity,
    required this.stars,
    required this.accuracy,
    required this.timeSpent,
    required this.firstTryCorrect,
    required this.totalQuestions,
    required this.next,
    required this.isNewBest,
    required this.onReplay,
  });

  @override
  State<CompletionOverlay> createState() => _CompletionOverlayState();
}

class _CompletionOverlayState extends State<CompletionOverlay> {
  int _shown = 0;

  String get _title => widget.stars >= 3 ? 'Superstar!' : (widget.stars == 2 ? 'Amazing!' : 'Good try!');

  @override
  void initState() {
    super.initState();
    final audio = AudioAssistantService.ensure();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      MagicFx.confetti(context, count: 80);
      for (var i = 1; i <= widget.stars; i++) {
        await Future.delayed(const Duration(milliseconds: 650));
        if (!mounted) return;
        setState(() => _shown = i);
        audio.playSfx('star');
        audio.light();
      }
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      final msg = widget.stars >= 3
          ? 'You are a superstar!'
          : widget.stars == 2
              ? 'You did amazing! Let us try for three stars next time.'
              : 'Great effort! Practice makes you stronger. Let us try again soon.';
      audio.speak('$_title You earned ${widget.stars} ${widget.stars == 1 ? 'star' : 'stars'}. $msg');
    });
  }

  @override
  Widget build(BuildContext context) {
    final next = widget.next;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Magic.dusk, Magic.midnight], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Magic.sun.withOpacity(.8), width: 3),
            boxShadow: Magic.glow(Magic.sun, blur: 40, a: .5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Luma(size: 140, mood: LumaMood.cheer),
              Text(_title, style: Magic.title(Magic.sun, 36)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final on = i < _shown;
                  return AnimatedScale(
                    scale: on ? 1 : .6,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    child: Icon(on ? Icons.star_rounded : Icons.star_outline_rounded, size: 72, color: on ? Magic.sun : Colors.white30),
                  );
                }),
              ),
              if (widget.isNewBest && widget.stars > 0)
                Padding(padding: const EdgeInsets.only(top: 4), child: Text('New best!', style: Magic.title(Magic.mint, 20))),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  children: [
                    if (widget.totalQuestions > 0) _row('Right the first time', '${widget.firstTryCorrect} of ${widget.totalQuestions}'),
                    _row('Accuracy', '${widget.accuracy.toStringAsFixed(0)}%'),
                    _row('Time', widget.timeSpent),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (next != null) ...[
                BigButton(
                  label: 'Next adventure',
                  icon: Icons.arrow_forward_rounded,
                  color: Magic.candy,
                  onTap: () {
                    Get.back();
                    Get.off(() => ActivityPage(activity: next));
                  },
                ),
                const SizedBox(height: 10),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(child: BigButton(label: 'Again', outlined: true, onTap: widget.onReplay)),
                  const SizedBox(width: 12),
                  Flexible(
                    child: BigButton(
                      label: 'Home',
                      outlined: next != null,
                      color: Magic.candy,
                      onTap: () {
                        Get.back();
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String l, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(l, style: Magic.body(Colors.white70, 16)), Text(v, style: Magic.title(Colors.white, 18))],
        ),
      );
}
