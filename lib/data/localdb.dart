import 'package:hc/data/shift_api.dart';
import 'package:hive/hive.dart';

class LocalDb {
  final _myBox = Hive.box('myBox');
  List<ClockData>scheduleList = [];
  late ClockData clockData;
  final ShiftApi _shiftApi = ShiftApi();

  Future<void> clockCreateInitialData() async {
    scheduleList = [];
    DateTime now = DateTime.now();
    String tempIn, tempOut;
    await _shiftApi.fetchData();
    List<dynamic> outletList = await _shiftApi.fetchOutletData();
    for (var e in _shiftApi.filteredShifts) {
      Map<String, dynamic> schedule = _shiftApi.scheduleList.firstWhere(
        (item) => item['id'] == int.parse(e['id_jam']),
        orElse: () => null,
      );
      String job = _shiftApi.jobList.firstWhere(
        (item) => item['id'] == int.parse(e['id_tipe_pekerjaan'])
      )['tipe_pekerjaan'];
      String outlet = outletList.firstWhere(
        (item) => item['id'] == e['id_outlet']
      )['outlet_name'];
      if (e['check_in_time'] == null) {
        tempIn = '';
      } else {
        tempIn = e['check_in_time'];
      }
      if (e['check_out_time'] == null) {
        tempOut = '';
      } else {
        tempOut = e['check_out_time'];
      }

      scheduleList.add(
        clockData = ClockData(
          id: e['id'],
          scheduleIn: '${now.year},${now.month},${now.day},${schedule['jam_mulai'].toString().substring(0,2)},${schedule['jam_mulai'].toString().substring(3,5)}',
          scheduleOut: '${now.year},${now.month},${now.day},${schedule['jam_selesai'].toString().substring(0,2)},${schedule['jam_selesai'].toString().substring(3,5)}',
          clockIn: tempIn,
          clockOut: tempOut,
          initDate: now,
          role: job,
          outlet: outlet,
          taskStatus: e['task_status'],
          status: ''
        )
      );
    }
    scheduleList.sort((a, b) => toDate(a.scheduleIn).compareTo(toDate(b.scheduleIn)));
  }
  void clockUpdateData() {
    List<Map<String, dynamic>> jsonList = scheduleList.map((e) => e.toJson()).toList();
    _myBox.put('CLOCKSCHEDULE', jsonList);
  }
  void clockLoadData() {
    var data = _myBox.get('CLOCKSCHEDULE');
    if (data != null) {
      scheduleList = [];
      for (var e in data) {
        scheduleList.add(
          clockData = ClockData(
            id: e['id'],
            scheduleIn: e['scheduleIn'],
            scheduleOut: e['scheduleOut'],
            clockIn: e['clockIn'],
            clockOut: e['clockOut'],
            initDate: e['initDate'],
            role: e['role'],
            outlet: e['outlet'],
            taskStatus: e['taskStatus'],
            status: e['status']
          )
        );
      }
    } else {
      scheduleList = [];
    }
  }

  DateTime toDate(String str){
    List<String> strList = str.split(',');
    var date = DateTime(
      int.parse(strList[0]), 
      int.parse(strList[1]), 
      int.parse(strList[2]), 
      int.parse(strList[3]), 
      int.parse(strList[4])  
    );
    return date;
}

  String dateToString(DateTime date, int hour, int minute){
    return '${date.year},${date.month},${date.day},$hour,$minute';
  }
}

class ClockData {
  DateTime initDate;
  int id;
  String scheduleIn;
  String scheduleOut;
  String clockIn;
  String clockOut;
  String role;
  String outlet;
  String? taskStatus;
  String status;

  ClockData({
    required this.id,
    required this.scheduleIn,
    required this.scheduleOut,
    required this.clockIn,
    required this.clockOut,
    required this.role,
    required this.outlet,
    required this.taskStatus,
    required this.status,
    required this.initDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleIn': scheduleIn, 
      'scheduleOut': scheduleOut, 
      'clockIn': clockIn, 
      'clockOut': clockOut, 
      'role': role, 
      'outlet': outlet, 
      'status': status,  
      'initDate': initDate, 
    };
  }
}