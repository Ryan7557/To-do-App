import 'package:hive/hive.dart';

part 'model.g.dart';

@HiveType(typeId: 0)
class Data {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  bool isComplete;

  Data({
    required this.id,
    required this.title,
    this.isComplete = false,
  });

  void toggleComplete() {
    isComplete = !isComplete;
  }
}
