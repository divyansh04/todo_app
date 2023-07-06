
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/todo_provider.dart';

class TodoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context);
    final todos = provider.todos;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return ListTile(
          title: Text(todo.taskName),
          subtitle: Text(todo.description),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              provider.deleteTodo(todo);
            },
          ),
        );
      },
    );
  }
}
