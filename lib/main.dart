import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_todo_app/model/model.dart';
import 'package:hive_todo_app/screens/to-do_screen.dart';
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
