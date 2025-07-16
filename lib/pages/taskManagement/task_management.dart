import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hc/data/global_variable.dart';
import 'package:hc/data/shift_api.dart';
import 'package:hc/pages/taskManagement/taskManagementWidget/task_add.dart';
import 'package:hc/pages/taskManagement/taskManagementWidget/shift_list.dart';
import 'package:hc/util/error_catcher.dart';
import 'package:http/http.dart' as http;

class TaskManagement extends StatefulWidget {
  const TaskManagement({super.key});

  @override
  State<TaskManagement> createState() => _TaskManagementState();
}

class _TaskManagementState extends State<TaskManagement> {
  List<dynamic> scheduleList = [];
  List<dynamic> usersList = [];
  List<dynamic> jobList = [];
  List<dynamic> outletList = [];
  List<Map<String, dynamic>> groupedList = [];
  bool _isLoading = true;
  bool _onChoosing = true;
  Map<String,dynamic> chosen = {};
  String chosenDate = '', chosenTime = '', chosenRole = '';
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await loadData();
    await displayAll();
    if (mounted) setState(() {_isLoading = false;});
  }

  void handler(Map<String,dynamic> staff, String date, String time, String role){
    if (mounted) setState(() {
      chosen = staff;
      chosenDate = date; 
      chosenTime = time; 
      chosenRole = role;
      _onChoosing = false;
    });
    
  }

  void back(){
    if (mounted) setState(() {
      _onChoosing = true;
      chosen = {};
      chosenDate = ''; 
      chosenTime = ''; 
      chosenRole = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
    ? Center(child: CircularProgressIndicator(color: greenTheme,))
    : Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text('Add Task',style: GoogleFonts.openSans(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black),),
          ),
        ),
        Expanded(
          child: _onChoosing 
          ? RefreshIndicator(
            backgroundColor: greenTheme,
            color: Colors.white,
            onRefresh: () async{
              if (mounted) setState(() {_isLoading = true;});
              await _initializeData();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListView.builder(
                itemCount: groupedList.length,
                itemBuilder: (context, index) {
                  return ShiftList(number: index, shift: groupedList[index], scheduleList: scheduleList, jobList: jobList, outletList: outletList, passing: handler);
                },
              ),
            ),
          )
          : Taskadd(staff: chosen, time: chosenTime, date: chosenDate, role: chosenRole, revert: back,)
        ),
      ],
    );
  }

  Future<void> displayAll() async {
    var url = Uri.parse('https://shift.lakesidefnb.group/api/jadwal-shift');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        DateTime now = DateTime.now();
        DateTime today = DateTime(now.year, now.month, now.day).subtract(Duration(minutes: 1));
        List<dynamic> data = json.decode(response.body)['jadwal_shift'];
        List<dynamic> filteredData = [];
        groupedList.clear();
        // Data filtering
        data = data.where((e) => DateTime.parse(e['tanggal']).isAfter(today)).toList();
        for (var i in data) {
          var schedule = scheduleList.firstWhere((e) => e['id'].toString() == i['id_jam'], orElse: () => null);
          if (schedule != null) {
            String end = schedule['jam_selesai'];
            DateTime endTime = DateTime.parse('${i['tanggal']} $end');
            if (endTime.isAfter(now)) filteredData.add(i);
          }
        }
        // Data grouping
        Map<String, Map<String, List<dynamic>>> tempGroup = {};
        for (var shift in filteredData) {
          String outlet = shift['id_outlet'];
          String tanggal = shift['tanggal'];
          tempGroup.putIfAbsent(outlet, () => {});
          tempGroup[outlet]!.putIfAbsent(tanggal, () => []);
          tempGroup[outlet]![tanggal]!.add(shift);
        }
        tempGroup.forEach((outlet, tanggalMap) {
          List<Map<String, dynamic>> tanggalList = [];
          tanggalMap.forEach((tanggal, shifts) {
            shifts.sort((a, b) {
              var scheduleA = scheduleList.firstWhere((s) => s['id'].toString() == a['id_jam'].toString());
              var scheduleB = scheduleList.firstWhere((s) => s['id'].toString() == b['id_jam'].toString());
              
              if (scheduleA == null || scheduleB == null) return 0;
              
              return scheduleA['jam_mulai'].compareTo(scheduleB['jam_mulai']);
            });
            tanggalList.add({
              'tanggal': tanggal,
              'shifts': shifts,
            });
          });
          tanggalList.sort((a, b) {
            DateTime dateA = DateTime.parse(a['tanggal']);
            DateTime dateB = DateTime.parse(b['tanggal']);
            return dateA.compareTo(dateB);
          });
          groupedList.add({
            'id_outlet': outlet,
            'tanggal': tanggalList,
          });
        });
        if (mounted) setState(() {});
      } else {
        print('No data: ${response.statusCode}');
      }
    } catch (e) {
      errorCatcher(from: 'data grouping', error: e.toString());
    }
  }


  Future<void> loadData() async {
    var urlSchedule = Uri.parse('https://shift.lakesidefnb.group/api/jam-shift');
    var urlUsers = Uri.parse('https://shift.lakesidefnb.group/api/users');
    final ShiftApi shiftApi = ShiftApi();
    try{
      var responseSchedule = await http.get(urlSchedule);
      var responseUsers = await http.get(urlUsers);
      if(responseUsers.statusCode == 200 && responseSchedule.statusCode == 200){
        scheduleList = json.decode(responseSchedule.body)['JamShift'];
        usersList = json.decode(responseUsers.body)['data'];
        jobList = await getJobData();
        await shiftApi.fetchData();
        outletList = await shiftApi.fetchOutletData();
      } 
    } catch (e){
      errorCatcher(from: 'Loading data', error: e.toString());
    }
  }
}