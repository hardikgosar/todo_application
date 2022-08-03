import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_application/database/database_helper.dart';
import 'package:todo_application/screens/add_task_screen.dart';

import '../model/task_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Task>> _taskList;
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  late Color select;
  late String date;

  _updateTaskList() {
    print('update method called');
    _taskList = _databaseHelper.getTaskList();
  }

  @override
  void initState() {
    super.initState();

    _updateTaskList();
  }

  Widget _buildTask(Task task) {
    String date = DateFormat.yMMMMd().format(task.date).toString();
    select = selectedColor(task.priority);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5.0,
      color: select,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  task.title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AddTaskScreen(
                                  updateTaskList: _updateTaskList(),
                                  task: task,
                                )));
                  },
                  icon: const Icon(Icons.edit),
                )
              ],
            ),
            Text(
              task.description,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.normal,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date + ' ' + task.time,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _databaseHelper.deleteTask(task);
                      _updateTaskList();
                    });
                  },
                  icon: const Icon(Icons.delete),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TODO',
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => AddTaskScreen()));
              },
              icon: const Icon(
                Icons.add,
                size: 25.0,
                color: Colors.white,
              ))
        ],
      ),
      body: FutureBuilder(
        future: _taskList,
        builder: (context, AsyncSnapshot snapshot) {
          return !snapshot.hasData
              ? const Center(
                  child: Text(
                    'No Task Added, Add Task',
                    style: TextStyle(fontSize: 20.0),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildTask(snapshot.data![index]);
                      }),
                );
        },
      ),
    );
  }

  Color selectedColor(String priority) {
    switch (priority) {
      case 'High':
        select = Colors.red;
        break;
      case 'Medium':
        select = Colors.amber;
        break;
      case 'Low':
        select = Colors.green;
        break;
      default:
    }
    return select;
  }
}
