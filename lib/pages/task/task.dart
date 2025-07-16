import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hc/data/global_variable.dart';
import 'package:hc/data/shift_api.dart';
import 'package:hc/util/error_catcher.dart';
import 'package:http/http.dart' as http;
import 'package:hc/pages/task/taskWidgets/task_list.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class Task extends StatefulWidget {
  const Task({super.key});

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> {
  List<dynamic> taskList = [];
  bool _isLoading = true;

  @override
  void initState() {
    _initializeData();
    super.initState();
  }
  
  Future<void> _initializeData() async {
    await getTask();
    if (mounted) setState(() {_isLoading = false;});
  } 

  @override
  Widget build(BuildContext context) {
  return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text('Task List',style: GoogleFonts.openSans(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black),),
          ),
        ),
        _isLoading
        ? Expanded(child: Center(child: CircularProgressIndicator(color: greenTheme,)))
        : Expanded(
          child: RefreshIndicator(
            backgroundColor: greenTheme,
            color: Colors.white,
            onRefresh: () async{
              if (mounted) setState(() {_isLoading = true;});
              await _initializeData();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              child: ListView.builder(
                itemCount: taskList.length,
                itemBuilder: (context, index) {
                  return TaskList(
                    task: taskList[index],
                    index: index,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> getTask() async {
    taskList.clear();
    var url = Uri.parse('https://shift.lakesidefnb.group/api/jadwal-shift');
    final user = Hive.box('myBox').get('USERDATA');
    final ShiftApi _shiftApi = ShiftApi();
    try {
      var response = await http.get(url);
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      List<dynamic> data = json.decode(response.body)['jadwal_shift'];
      List<dynamic> filteredData = (data.where((e) => e['id_user'] == user['id'].toString() && DateTime.parse(e['tanggal']).isAfter(DateTime.parse(today).subtract(Duration(seconds: 1))))).toList();
      if (filteredData.isNotEmpty){
        List<dynamic> outletList = await _shiftApi.fetchOutletData(); 
        List<dynamic> scheduleList = await getScheduleData();
        for(var i in filteredData){
          if (i['task'] != null && i['task'].toString().isNotEmpty){
            var schedule = scheduleList.firstWhere((element) => element['id'].toString() == i['id_jam']);
            taskList.add({
              "outlet": (outletList.firstWhere((e) => e['id'] == i['id_outlet']))['outlet_name'],
              "task": i['task'],
              "task_status": i['task_status'],
              "id" : i['id'],
              "schedule_start": schedule['jam_mulai'].substring(0,5),
              "schedule_end": schedule['jam_selesai'].substring(0,5),
              "date" : DateTime.parse(i['tanggal'])
            });
          }
        }
        taskList.sort((a, b) {
          int dateCompare = (a['date'] as DateTime).compareTo(b['date'] as DateTime);
          if (dateCompare != 0) return dateCompare;
          return a['schedule_start'].compareTo(b['schedule_start']);
        });
        if (mounted){
          if (mounted) setState(() {});
        }
      }
    } catch (e){
      errorCatcher(from: 'Loading data',error: e.toString());
    } finally{
      if (mounted) setState(() {_isLoading = false;});
    }
  }
}