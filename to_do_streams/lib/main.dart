import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class Task {
  String title;
  bool completed;

  Task(this.title, this.completed);
}

class TaskBloc {
  final _taskController = StreamController<List<Task>>.broadcast();

  List<Task> _tasks = [];

  Stream<List<Task>> get tasksStream => _taskController.stream;

  void addTask(Task task) {
    _tasks.add(task);
    _taskController.sink.add(_tasks);
  }

  void toggleTask(int index) {
    _tasks[index].completed = !_tasks[index].completed;
    _taskController.sink.add(_tasks);
  }

  void editTask(int index, String newTitle) {
    _tasks[index].title = newTitle;
    _taskController.sink.add(_tasks);
  }

  void deleteTask(int index) {
    _tasks.removeAt(index);
    _taskController.sink.add(_tasks);
  }

  void dispose() {
    _taskController.close();
  }
}

final bloc = TaskBloc();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lista de Tareas'),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Task>>(
                stream: bloc.tasksStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text('No hay tareas'),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return TaskWidget(index, snapshot.data![index]);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onSubmitted: (value) {
                  bloc.addTask(Task(value, false));
                },
                decoration: InputDecoration(
                  hintText: 'Añadir nueva tarea',
                  suffixIcon: Icon(Icons.add),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskWidget extends StatefulWidget {
  final int index;
  final Task task;

  TaskWidget(this.index, this.task);

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.task.title;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: widget.task.completed
          ? Text(
              widget.task.title,
              style: TextStyle(decoration: TextDecoration.lineThrough),
            )
          : TextField(
              controller: _controller,
              onSubmitted: (newTitle) {
                bloc.editTask(widget.index, newTitle);
              },
            ),
      leading: Checkbox(
        value: widget.task.completed,
        onChanged: (value) {
          bloc.toggleTask(widget.index);
        },
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _controller.text = widget.task.title;
              bloc.editTask(widget.index, _controller.text);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              bloc.deleteTask(widget.index);
            },
          ),
        ],
      ),
    );
  }
}