import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hc/data/global_variable.dart';
import 'package:hc/data/shift_api.dart';
import 'package:hc/util/error_catcher.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final user = Hive.box('myBox').get('USERDATA');
  late final String username;
  final _myBox = Hive.box('myBox');
  bool _isLoading = true;
  dynamic period;
  int inDay = 0;
  int totDay = 0;
  late List<dynamic> shifts;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    username = user['name']; 
    if ((_myBox.get('thisPeriod')) != null){
      var checkPeriod = _myBox.get('thisPeriod');
      DateTime now = DateTime.now();
      if (now.isAfter(checkPeriod['start']) && now.isBefore(checkPeriod['end'])){
        period = checkPeriod;
      } else {
        period = await findPeriod();
      }
    } else {
      period = await findPeriod();
    }
    try{
      shifts = await getAttendanceData(); 
      List<dynamic> attend = shifts.where((e) => e['check_out_time'] != null).toList();
      inDay = attend.length;
      totDay = shifts.length;
      if (mounted) setState(() {_isLoading = false;});
    } catch(e){
      if (mounted) setState(() {_isLoading = false;});
      errorCatcher(from: 'Loading data', error: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
      ? Center(child: CircularProgressIndicator(color: greenTheme,))
      : Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: const Icon(Icons.account_circle, size: 100),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: widgetBg,
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to Logout'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              _myBox.clear();
                              Navigator.of(context).pop();
                              Navigator.pushNamed(context, '/loginpage');
                            },
                            child: const Text('Yes', style: TextStyle(color: Colors.red)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    shape: const CircleBorder(),
                    elevation: 4,
                  ),
                  child: const Icon(Icons.logout, size: 20, color: Colors.white),
                ),
              ),
            ],
          ),
          Text((username.length >= 25)?username.substring(0, 25): username, style: const TextStyle(fontSize: 20),),
          // Analytics
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              height: 170,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [greenTheme.withOpacity(0.9), greenTheme.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.insights, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Employee Insight',
                          style: GoogleFonts.openSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${DateFormat('dd/MM/yyyy').format(period['start'])} - ${DateFormat('dd/MM/yyyy').format(period['end'])}',
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(height: 5),
                            Text('Kehadiran', style: TextStyle(color: Colors.white70)),
                            Text(
                              '$inDay/$totDay',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        // Circular Progress
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 60,
                              width: 60,
                              child: CircularProgressIndicator(
                                value: totDay == 0 ? 0 : inDay / totDay,
                                strokeWidth: 6,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            Text(
                              totDay == 0 ? '0%' : '${((inDay / totDay) * 100).round()}%',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Schedule
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
              child: Container(
                padding: EdgeInsets.all(10),
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widgetBg.withOpacity(0.9), widgetBg.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Jadwal Periode Ini',
                      style: GoogleFonts.openSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Expanded(
                      child: FutureBuilder(
                        future: Future.wait(List.generate(shifts.length, (index) => buildScheduleRowData(index))),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator(color: greenTheme));
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List<TableRow> rows = [
                              TableRow(
                                decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
                                children: [
                                  Center(child: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Center(child: Text('Waktu', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Center(child: Text('Outlet', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Center(child: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                              ),
                              ...snapshot.data!.map((data) => TableRow(
                                children: data.map((item) => Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Center(child: Text(item)),
                                )).toList(),
                              ))
                            ];
                            return SingleChildScrollView(
                              child: Table(
                                border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey[400]!)),
                                columnWidths: const {
                                  0: FlexColumnWidth(1.5),
                                  1: FlexColumnWidth(1.2),
                                  2: FlexColumnWidth(2),
                                  3: FlexColumnWidth(2),
                                },
                                children: rows,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            ),
          )
        ],
      )
    );
  }

  Future<List<String>> buildScheduleRowData(int index) async {
    var tanggal = DateFormat('dd/MM').format(DateTime.parse(shifts[index]['tanggal']));
    var clockList = await getScheduleData();
    var clock = clockList.firstWhere((e) => e['id'].toString() == shifts[index]['id_jam']);
    var mulai = clock['jam_mulai'].substring(0,5);
    var selesai = clock['jam_selesai'].substring(0,5);
    var jobList = await getJobData();
    var role = jobList.firstWhere((e) => e['id'].toString() == shifts[index]['id_tipe_pekerjaan'])['tipe_pekerjaan'];
    var outletList = await getOutletData();
    var outlet = outletList.firstWhere((element) => element['id'] == shifts[index]['id_outlet'])['outlet_name'];

    return [tanggal, '$mulai - $selesai', outlet, role];
  }



  Future<Map<String, dynamic>> findPeriod() async {
    var url = Uri.parse('https://shift.lakesidefnb.group/api/periode-gaji');
    final DateTime now = DateTime.now();
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body)['periode'];
        for (var item in data) {
          DateTime start = DateTime.parse(item['tgl_mulai']);
          DateTime end = DateTime.parse(item['tgl_akhir']).add(Duration(days: 1)-(Duration(seconds: 1)));
          if (now.isAfter(start) && now.isBefore(end)) {
            Map<String, dynamic> period = {
              "start": start,
              "end": end,
            };
            Hive.box('myBox').put('thisPeriod', period);
            return period;
          }
        }
      }
    } catch (e) {
      print('API Request error: $e');
    }
    return {
      "start": DateTime(2000),  
      "end": DateTime(2000),
    };
  }

  Future<List<dynamic>> getAttendanceData() async {
    final myBox = Hive.box('myBox');
    final user = myBox.get('USERDATA');
    var url = Uri.parse('https://shift.lakesidefnb.group/api/jadwal-shift');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body)['jadwal_shift'];
        List<dynamic> userFilteredData = data.where((e) => e['id_user'] == user['id'].toString()).toList();
        List<dynamic> filteredData = userFilteredData.where((e) =>DateTime.parse(e['tanggal']).isAfter(period['start']) &&DateTime.parse(e['tanggal']).isBefore(period['end'])).toList();
        return filteredData;
      } else {
        print('Server responded with status: ${response.statusCode}');
      }
    } catch (e) {
      errorCatcher(from: 'Loading data', error: e.toString());
    }
    return [];
  }

  Future<void> getData() async {
    try{
      shifts = await getAttendanceData(); 
      List<dynamic> attend = shifts.where((e) => e['check_out_time'] != null).toList();
      inDay = attend.length;
      totDay = shifts.length;
    } catch(e){
      if (mounted) setState(() {_isLoading = false;});
      errorCatcher(from: 'Loading data', error: e.toString());
    }
  }
}