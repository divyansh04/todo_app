import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/todo_list.dart';
import '../controller/todo_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final todoProvider = Provider.of<TodoProvider>(context);
    if (user != null) {
      todoProvider.setLoading(true);
      todoProvider.fetchTodos(user.uid);
      todoProvider.setLoading(false);
    }
    return Scaffold(
      key: todoProvider.scaffoldMessengerKey,
      appBar: AppBar(
        title: const Text('Todo App'),
        backgroundColor: const Color(0xFF011638),
        elevation: 0,
        actions: [
          if (user != null && !todoProvider.isLoading)
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () async {
                todoProvider.setLoading(true);
                await todoProvider.signOut();
                todoProvider.setLoading(false);
              },
            ),
        ],
      ),
      body: Center(
        child: user == null
            ? ElevatedButton(
                onPressed: () {
                  todoProvider.signInWithGoogle();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF011638),
                  elevation: 2, // Add a slight elevation/shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                ),
                child: todoProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Sign in with Google'),
              )
            : Consumer<TodoProvider>(
                builder: (context, provider, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome, ${user.displayName}!',
                        style: const TextStyle(
                          color: Color(0xFF011638), // Set the primary color
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddTodoBottomSheet(context, provider);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Todo'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF011638),
                          elevation: 2, // Add a slight elevation/shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      todoProvider.isLoading
                          ? const CircularProgressIndicator(
                              color: Color(0xFF011638),
                            )
                          : todoProvider.todos.isEmpty
                              ? Container()
                              : Expanded(child: TodoList()),
                    ],
                  );
                },
              ),
      ),
    );
  }

  void _showAddTodoBottomSheet(BuildContext context, TodoProvider provider) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Material(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF011638), // Primary color
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final title = titleController.text.trim();
                      final description = descriptionController.text.trim();
                      if (title.isNotEmpty && description.isNotEmpty) {
                        provider.addTodo(
                          taskName: title,
                          description: description,
                          date: DateTime.now(),
                          userId: FirebaseAuth.instance.currentUser!.uid,
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please enter title and description')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF011638),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
