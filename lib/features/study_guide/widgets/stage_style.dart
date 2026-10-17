import 'package:flutter/material.dart';
import 'package:isapp/core/theme/scholar_theme.dart';
import 'package:isapp/features/study_guide/models/mastery_record.dart';
import 'package:isapp/features/study_guide/models/plan_item.dart';

class StageStyle {
  StageStyle._();

  static Color color(TopicStage s) {
    switch (s) {
      case TopicStage.learn:
        return Scholar.sky;
      case TopicStage.practice:
        return Scholar.sun;
      case TopicStage.check:
        return Scholar.lilac;
      case TopicStage.master:
        return Scholar.mint;
    }
  }

  static IconData icon(TopicStage s) {
    switch (s) {
      case TopicStage.learn:
        return Icons.menu_book_rounded;
      case TopicStage.practice:
        return Icons.edit_rounded;
      case TopicStage.check:
        return Icons.quiz_rounded;
      case TopicStage.master:
        return Icons.workspace_premium_rounded;
    }
  }

  static IconData reasonIcon(PlanReason r) {
    switch (r) {
      case PlanReason.dueReview:
        return Icons.update_rounded;
      case PlanReason.weakSpot:
        return Icons.healing_rounded;
      case PlanReason.newTopic:
        return Icons.auto_awesome_rounded;
      case PlanReason.checkpoint:
        return Icons.flag_rounded;
      case PlanReason.weeklyReview:
        return Icons.event_repeat_rounded;
      case PlanReason.examPrep:
        return Icons.local_fire_department_rounded;
    }
  }
}
