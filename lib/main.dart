import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_todo_app/model/model.dart';
import 'package:hive_todo_app/themes/theme.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DataAdapter());
  await Hive.openBox('todo_box');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: TodoApp(
        onThemeChanged: () {
          setState(() {
            isDarkMode = !isDarkMode;
          });
        },
        isDarkMode: isDarkMode,
      ),
    );
  }
}

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
    await todoBox.deleteAt(index);
    setState(() {});
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
      ),
    );
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutQuad,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: todoItem.isComplete
            ? Colors.green.withOpacity(0.4)
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
          ),
          subtitle: Text(formattedDate),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Todo App'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
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
