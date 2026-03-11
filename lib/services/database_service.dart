import 'package:firebase_core/firebase_core.dart'; // Add this import
import 'package:firebase_database/firebase_database.dart';
import '../models/todo_list_model.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final String _dbUrl =
      "https://todo-list-firebase-76762-default-rtdb.asia-southeast1.firebasedatabase.app/";

  // FIXED: Passing both the default app instance and the database URL
  DatabaseReference get _dbRef => FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: _dbUrl,
  ).ref().child('users').child(uid ?? 'anonymous').child('todos');

  // GET TODOS STREAM
  Stream<List<TodoModel>> get todos {
    return _dbRef.onValue.map((event) {
      final Map<dynamic, dynamic>? data =
          event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return [];

      return data.entries.map((entry) {
        final Map<dynamic, dynamic> value = entry.value;
        return TodoModel(
          id: entry.key.toString(),
          title: value['title'] ?? '',
          isDone: value['isDone'] ?? false,
          userId: value['userId'] ?? (uid ?? 'anonymous'),
          dueDate: value['dueDate'] != null
              ? DateTime.tryParse(value['dueDate'].toString())
              : null,
        );
      }).toList();
    });
  }

  // ADD TODO
  Future<void> addTodo(String title, DateTime? dueDate) async {
    await _dbRef.push().set({
      'title': title,
      'isDone': false,
      'userId': uid ?? 'anonymous',
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': ServerValue.timestamp,
    });
  }

  // UPDATE STATUS
  Future<void> updateTodoStatus(String id, bool isDone) async {
    await _dbRef.child(id).update({'isDone': isDone});
  }

  // UPDATE DETAILS
  Future<void> updateTodo(String id, String title, DateTime? dueDate) async {
    await _dbRef.child(id).update({
      'title': title,
      'dueDate': dueDate?.toIso8601String(),
    });
  }

  // DELETE TODO
  Future<void> deleteTodo(String id) async {
    await _dbRef.child(id).remove();
  }
}
