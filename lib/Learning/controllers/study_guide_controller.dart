import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isapp/Models/planner_models.dart';

class StudyPlanController extends GetxController {
  final RxList<StudyTask> _tasks = <StudyTask>[].obs;

  /// Normalized today (00:00)
  DateTime get today =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  /// Formatter key for maps
  String _key(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  /// 🔹 Public getters
  List<StudyTask> get allTasks => _tasks;

  List<StudyTask> tasksForDay(DateTime date) {
    final key = _key(date);
    return _tasks.where((t) => _key(t.date) == key).toList();
  }

  List<StudyTask> get todayTasks => tasksForDay(today);

  /// Calendar dots (date → tasks)
  Map<DateTime, List<StudyTask>> get calendarMap {
    final map = <DateTime, List<StudyTask>>{};
    for (final task in _tasks) {
      final d = DateTime(task.date.year, task.date.month, task.date.day);
      map.putIfAbsent(d, () => []).add(task);
    }
    return map;
  }

  /// Seed data (replace with Firebase later)
  @override
  void onInit() {
    super.onInit();
    _generateSamplePlan();
  }

  void _generateSamplePlan() {
    final base = today;

    _tasks.assignAll(List.generate(30, (i) {
      final date = base.add(Duration(days: i));
      return StudyTask(
        id: 'task_$i',
        title: 'Study Session ${i + 1}',
        date: date,
        duration: const Duration(minutes: 45),
      );
    }));
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((e) => e.id == id);
    if (index != -1) {
      _tasks[index] =
          _tasks[index].copyWith(completed: !_tasks[index].completed);
    }
  }
}
