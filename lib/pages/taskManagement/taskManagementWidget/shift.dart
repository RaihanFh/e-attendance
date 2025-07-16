import 'package:flutter/material.dart';
import 'package:hc/data/global_variable.dart';

class shift extends StatefulWidget {
  final Map<String,dynamic> data;
  final List<dynamic> scheduleList;
  final List<dynamic> jobList;
  final String date;
  final Function(Map<String,dynamic>, String, String, String) passing;

  const shift({
    super.key,
    required this.data,
    required this.scheduleList,
    required this.jobList,
    required this.date,
    required this.passing
  });

  @override
  State<shift> createState() => _shiftState();
}

class _shiftState extends State<shift> {
  late String time, role;
  bool active = true;
  late final schedule;
  @override
  void initState() {
    if (widget.data['id_user'] == null) active = false;
    schedule = widget.scheduleList.firstWhere((element) => element['id'].toString() == widget.data['id_jam']);
    time = '${schedule['jam_mulai'].substring(0,5)} - ${schedule['jam_selesai'].substring(0,5)}';
    role = widget.jobList.firstWhere((element) => element['id'].toString() == widget.data['id_tipe_pekerjaan'])['tipe_pekerjaan'];
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: GestureDetector(
        onTap: () => active ? widget.passing(widget.data, widget.date, time, role) : {},
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          height: 40,
          width: 350,
          decoration: BoxDecoration(
            color: active? Colors.green[100] : widgetBgDisabled,
            border: Border(bottom: BorderSide(width: 1),)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(time),
              Text('|'),
              Text(role)
            ],
          ),
        ),
      )
    );
  }
}