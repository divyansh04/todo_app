import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../model/todo_model.dart';

class TodoProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  User? _user;

  User? get user => _user;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    setLoading(true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(
          content: Text('Login successful'),
        ));

        // Update the user object and notify listeners
        _user = user;
        notifyListeners();

        // Fetch the user's todos
        await fetchTodos(user.uid);
      }
    } catch (error) {
      print('Error signing in with Google: $error');
    }

    setLoading(false);
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _todos.clear();
      notifyListeners();
    } catch (error) {
      print('Error signing out: $error');
    }
  }

  Future<void> fetchTodos(String userId) async {
    setLoading(true);
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('todos')
          .where('userId', isEqualTo: userId)
          .get();
      _todos = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        final todoId = doc.id;
        if (data != null) {
          return Todo(
            id: todoId,
            taskName: data['taskName'] as String,
            description: data['description'] as String,
            date: DateTime.parse(data['date'] as String),
          );
        } else {
          throw const FormatException('Invalid data format');
        }
      }).toList();

      notifyListeners();
    } catch (error) {
      print('Error fetching todos: $error');
    }
    setLoading(false);
  }

  Future<void> addTodo({
    required String taskName,
    required String description,
    required DateTime date,
    required String userId,
  }) async {
    setLoading(true);
    try {
      final todo = Todo(
        id: userId,
        taskName: taskName,
        description: description,
        date: date,
      );

      final DocumentReference docRef =
          await _firestore.collection('todos').add({
        'taskName': taskName,
        'description': description,
        'date': date.toIso8601String(),
        'userId': userId,
      });

      final todoId = docRef.id;
      todo.id = todoId;

      _todos.add(todo);
      notifyListeners();
    } catch (error) {
      print('Error adding todo: $error');
    }
    setLoading(false);
  }

  Future<void> deleteTodo(Todo todo) async {
    setLoading(true);
    try {
      await _firestore.collection('todos').doc(todo.id).delete();
      _todos.remove(todo);
      notifyListeners();
    } catch (error) {
      print('Error deleting todo: $error');
    }
    setLoading(false);
  }
}
