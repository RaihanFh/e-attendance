import 'package:flutter/material.dart';
import 'package:hc/data/global_variable.dart';
import 'package:hc/pages/taskManagement/taskManagementWidget/shift.dart';
import 'package:intl/intl.dart';

class ShiftList extends StatefulWidget {
  final int number;
  final Map<String, dynamic> shift;
  final List<dynamic> scheduleList;
  final List<dynamic> jobList;
  final List<dynamic> outletList;
  final Function(Map<String,dynamic>, String, String, String) passing;
  const ShiftList({
    required this.number,
    required this.shift,
    required this.scheduleList,
    required this.jobList,
    required this.outletList,
    required this.passing,
    super.key
  });

  @override
  State<ShiftList> createState() => _ShiftListState();
}

class _ShiftListState extends State<ShiftList> {
  late String outlet;
  late String logo;
  
  @override
  void initState() {
    super.initState();
    outlet = widget.outletList.firstWhere((e)=> e['id'] == widget.shift['id_outlet'])['outlet_name'];
    switch (outlet){
      case 'LAKESIDE':
        logo = 'assets/Logo Lakeside.png';
        break;
      case 'LITERASI':
        logo = 'assets/Logo Literasi Cafe.png';
        break;
      case 'HARMONY CAFE':
        logo = 'assets/Logo Harmony Cafe.png';
        break;
      case 'LAKESIDE FIT+':
        logo = 'assets/Logo Lakeside FIT+.png';
        break;
      default:
        logo = 'assets/default.png';
    }
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widgetBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.transparent),
          ),
          iconColor: greenTheme,
          collapsedBackgroundColor: widgetBg,
          leading: CircleAvatar(backgroundImage: AssetImage(logo),),
          title: Text(widget.outletList.firstWhere((e)=> e['id'] == widget.shift['id_outlet'])['outlet_name']),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(widget.shift['tanggal'].length, (dateIndex) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Column(
                    children: [
                      Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.shift['tanggal'][dateIndex]['tanggal']))),
                      Column(
                        children: List.generate(widget.shift['tanggal'][dateIndex]['shifts'].length, (shiftIndex){
                          return shift(
                            data: widget.shift['tanggal'][dateIndex]['shifts'][shiftIndex], 
                            scheduleList: widget.scheduleList, 
                            jobList: widget.jobList,
                            date: DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.shift['tanggal'][dateIndex]['tanggal'])),
                            passing: widget.passing,
                          );
                        }),
                      ),
                    ],
                  )
                  
                );
              }),
            )
          ],
        )
      ),
    );
  }
}