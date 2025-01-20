import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_todo_app/model/model.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DataAdapter());
  await Hive.openBox('todo_box');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TodoApp(),
    );
  }
}

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

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
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
          title: Text(todoItem.title),
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
