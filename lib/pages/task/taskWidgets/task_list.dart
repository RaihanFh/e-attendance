import 'dart:convert';
import 'package:hc/util/error_catcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hc/data/global_variable.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class TaskList extends StatefulWidget {
  final Map<String, dynamic> task;
  final int index;

  const TaskList({
    required this.task,
    required this.index,
    super.key,
  });

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<Map<String, dynamic>> taskList = [];
  final user = Hive.box('myBox').get('USERDATA');
  late final int userId;
  Set<int> loadingIndexes = {};
  

  @override
  void initState() {
    super.initState();
    userId = user['id'];
    if (widget.task['task'] != null &&
        widget.task['task_status'] != null &&
        widget.task['task'].toString().isNotEmpty) {
      final tempTask = widget.task['task'].toString().split(';');
      final tempStatus = widget.task['task_status'].toString().split(';');
      for (int i = 0; i < tempTask.length; i++) {
        taskList.add({
          "task": tempTask[i],
          "check": tempStatus[i],
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: _allTasksChecked ? Colors.green[100] : widgetBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.transparent),
          ),
          iconColor: greenTheme,
          collapsedIconColor: widgetBgDisabled,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.task['outlet']}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), 
              ),
              Text(
                '${DateFormat('dd-MM-yyyy').format(widget.task['date'])} (${widget.task['schedule_start']} - ${widget.task['schedule_end']})',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]), 
              ),
            ],
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5),
              child: ListView.builder(
                itemCount: taskList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(height: 30,width: 30,
                          child: loadingIndexes.contains(index)
                        ? Padding(
                          padding: const EdgeInsets.all(5),
                          child: CircularProgressIndicator(color: greenTheme,),
                        )
                        : Checkbox(
                          activeColor: greenTheme,
                          value: taskList[index]['check'] == 'done',
                          onChanged: (value) async => await checkBoxChanged(value, index),
                        ),
                        ),
                        
                        Expanded(
                          child: Text(taskList[index]['task']),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkBoxChanged(bool? value, int index) async {
    try {
      if (mounted) setState(() => loadingIndexes.add(index));
      taskList[index]['check'] = value == true ? 'done' : 'in progress';
      final url = Uri.parse(
        'https://shift.lakesidefnb.group/api/jadwal-shift/${widget.task['id']}',
      );
      final responseGet = await http.get(url);
      if (responseGet.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(responseGet.body)['JadwalShift'];
        data['task_status'] = taskList.map((e) => e['check'].toString()).join(';');
        final responsePut = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );
        if (responsePut.statusCode == 200) {
          if (mounted) setState(() => loadingIndexes.remove(index));
        } else {
          throw Exception('Failed to update task ${responsePut.statusCode}');
        }
      } else {
        throw Exception('Failed to fetch task');
      }
    } catch (e) {
      errorCatcher(from: 'Changing Task Status', error: e.toString());
      if (mounted) setState(() => loadingIndexes.remove(index));
    }
  }

  bool get _allTasksChecked {
    return taskList.isNotEmpty && taskList.every((task) => task['check'] == 'done');
  }
}
