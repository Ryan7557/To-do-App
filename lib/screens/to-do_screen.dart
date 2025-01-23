import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_todo_app/model/model.dart';
// import 'package:hive_todo_app/themes/theme.dart';

class TodoApp extends StatefulWidget {
  const TodoApp({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });
  final VoidCallback onThemeChanged;
  final bool isDarkMode;

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  late final Box todoBox;
  final TextEditingController _titleController = TextEditingController();
  Map<int, double> opacityValues = {};

  @override
  void initState() {
    super.initState();
    todoBox = Hive.box('todo_box');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _addTodo() async {
    if (_titleController.text.isEmpty) return;

    Data newData = Data(
      id: DateTime.now().toString(),
      title: _titleController.text,
    );
    await todoBox.add(newData);
    _titleController.clear();
    setState(() {});
  }

  Future<void> _deleteTodo(int index) async {
    setState(() {
      opacityValues[index] = 0;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    await todoBox.deleteAt(index);

    setState(() {
      opacityValues.remove(index);
    });

    // ignore: use_build_context_synchronously
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Task deleted'),
        ),
      );
    }
  }

  void _startAddNewTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: TextField(
            controller: _titleController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Task Title',
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                _addTodo();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTodoItem(BuildContext context, int index) {
    final todoItem = todoBox.getAt(index) as Data;
    final DateTime createdAt = DateTime.parse(todoItem.id);
    final String formattedDate =
        '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!opacityValues.containsKey(index)) {
      opacityValues[index] = 1.0;
    }

    return AnimatedOpacity(
      opacity: opacityValues[index] ?? 1.0,
      duration: const Duration(milliseconds: 700),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutQuad,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: todoItem.isComplete
              // ignore: deprecated_member_use
              ? (isDark
                  // ignore: deprecated_member_use
                  ? Colors.green.withOpacity(0.2)
                  // ignore: deprecated_member_use
                  : Colors.green.withOpacity(0.1))
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
            title: Text(
              todoItem.title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            subtitle: Text(
              formattedDate,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            leading: Icon(
              todoItem.isComplete
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: todoItem.isComplete ? Colors.green : null,
            ),
            trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _deleteTodo(index);
                  });
                }),
            onTap: () {
              setState(() {
                todoItem.isComplete = !todoItem.isComplete;
                todoBox.putAt(index, todoItem);
              });
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Todo App'),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              widget.onThemeChanged();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: todoBox.length,
        itemBuilder: _buildTodoItem,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _startAddNewTask(context);
        },
        tooltip: 'Add Todo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
