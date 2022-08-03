import 'package:flutter/material.dart';

class Task {
  int? id;
  String title;
  String description;
  String priority;
  String time;
  DateTime date;

  Task(
      {this.id,
      required this.title,
      required this.description,
      required this.priority,
      required this.time,
      required this.date});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['description'] = description;
    map['priority'] = priority;
    map['time'] = time;
    map['date'] = date.toString();

    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      priority: map['priority'],
      time: map['time'],
      date: DateTime.parse(map['date']),
    );
  }
}
