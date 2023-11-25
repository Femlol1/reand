import 'package:get/get.dart';

import '../database/db.dart';
import '../models/task.dart';

class TaskController extends GetxController {
  final RxList<Task> taskList = <Task>[].obs;
  // Adds a task to the database.
  Future<int> addTask({Task? task}) {
    return DBHelper.insert(task);
  }

  // Retrieves all tasks from the database and updates the taskList.
  Future<void> getTasks() async {
    final List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
  }

// Deletes a specific task and refreshes the task list.
  void deleteTasks(Task task) async {
    await DBHelper.delete(task);
    getTasks();
  }

// Deletes all tasks from the database and refreshes the task list.
  void deleteAllTasks() async {
    await DBHelper.deleteAll();
    getTasks();
  }

  // Marks a task as completed and refreshes the task list.
  void markTaskAsCompleted(int id) async {
    await DBHelper.update(id);
    getTasks();
  }
}
