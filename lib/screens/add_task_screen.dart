import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_application/screens/home_screen.dart';
import '../database/database_helper.dart';
import '../model/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;
  final Function? updateTaskList;
  const AddTaskScreen({this.task, this.updateTaskList, Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _titleText;
  final  _prioities = ["High", "Medium", "Low"];

  late bool _isEditMode;

  late String _title;
  late String _description;
  late String _priority;
  late String _timeString;
  late TimeOfDay _selectedTime;
  late DateTime _selectedDate;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  _toHomeScreen() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false);
  }

  _pickUserTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _isEditMode ? _selectedTime : TimeOfDay.now(),
    );

    if (pickedTime != null) {
      String time = pickedTime.format(context);

      setState(() {
        _timeController.text = time;
        _selectedTime = pickedTime;
        _timeString = _timeController.text;
      });
    }
  }

  _pickUserDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _isEditMode ? _selectedDate : DateTime.now(),
        firstDate: DateTime(2022),
        lastDate: DateTime(2030));

    if (picked == null) {
      return;
    } else {
      setState(() {
        _dateController.text = DateFormat.yMMMd().format(picked).toString();
        _selectedDate = picked;
      });
    }
  }

  _validateForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _title = _titleController.text;
        _description = _descriptionController.text;
       
      });

      Task task = Task(
          title: _title,
          description: _description,
          priority: _priority,
          time: _timeString,
          date: _selectedDate);

      if (widget.task == null) {
        DatabaseHelper.instance.insertTask(task);
      } else {
        task.id = widget.task!.id;
        DatabaseHelper.instance.updateTask(task);
      }
      widget.updateTaskList;
      _toHomeScreen();
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _titleText = 'Edit Task';
      _isEditMode = true;
      _title = widget.task!.title;
      _titleController.text = _title;

      _description = widget.task!.description;
      _descriptionController.text = _description;

      _priority = widget.task!.priority;

      _timeString = widget.task!.time;

      _timeController.text = _timeString;

      _selectedTime = TimeOfDay(
          hour: int.parse(_timeString.split(":")[0]),
          minute: int.parse(_timeString.split(":")[1]));

      _selectedDate = widget.task!.date;
      _dateController.text =
          DateFormat.yMMMd().format(_selectedDate).toString();
    } else {
      _titleText = 'Add Task';
      _isEditMode = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleText),
      ),
      body: SingleChildScrollView(
          child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: const TextStyle(fontSize: 18.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _descriptionController,
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: const TextStyle(fontSize: 18.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              DropdownButtonFormField(
                  value: _titleText == 'Edit Task' ? _priority : null,
                  items: _prioities.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(
                        dropDownStringItem,
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  style: const TextStyle(fontSize: 18.0),
                  validator: (value) =>
                      value == null ? 'Select Priority' : null,
                  decoration: InputDecoration(
                      labelText: 'Priority',
                      hintText: 'Select Priority',
                      labelStyle: const TextStyle(fontSize: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      )),
                  onChanged: (valueSelected) {
                    setState(() {
                      _priority = valueSelected.toString();
                    });
                  }),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  _pickUserDate();
                },
                decoration: InputDecoration(
                  labelText: 'Task Date',
                  labelStyle: const TextStyle(fontSize: 18.0),
                  icon: const Icon(Icons.calendar_month),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please Select a date for your task";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  _pickUserTime();
                },
                decoration: InputDecoration(
                  labelText: 'Task Time',
                  labelStyle: const TextStyle(fontSize: 18.0),
                  icon: const Icon(Icons.timer),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please Select a Time for your task";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _validateForm();
                    },
                    child: const Text('Submit'),
                    style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 25.0),
                        primary: Theme.of(context).primaryColor),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 25.0),
                        primary: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }
}
