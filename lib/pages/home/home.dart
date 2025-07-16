import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hc/data/localdb.dart';
import 'package:hc/data/global_variable.dart';
import 'package:hc/pages/home/homeWidgets/attendance_widget.dart';
import 'package:hc/util/error_catcher.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _myBox = Hive.box('myBox');
  LocalDb localDb = LocalDb();
  DateTime now = DateTime.now();
  late String userDisplay;
  bool _isLoading = true;

  @override
  void initState()  {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final userData = _myBox.get('USERDATA');
    userDisplay = userData['name'].toString(); 
    if (userDisplay.length >= 19) userDisplay = userDisplay.substring(0, 19);
    try{
      if (_myBox.get('CLOCKSCHEDULE') == null) {
        await localDb.clockCreateInitialData();
      } else {
        localDb.clockLoadData();
        if (!((now.year == localDb.scheduleList[0].initDate.year) &&
            (now.month == localDb.scheduleList[0].initDate.month) &&
            (now.day == localDb.scheduleList[0].initDate.day))) {
          _myBox.delete('CLOCKSCHEDULE');
          await localDb.clockCreateInitialData();
        }
      }
    }catch(e){
      errorCatcher(from: 'Loading data', error: e.toString());
    }
    if (mounted) setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
      ? Center(child: CircularProgressIndicator(color: greenTheme,))
      : Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang',
                      style: GoogleFonts.montserrat(fontSize: 25, fontWeight: FontWeight.normal),
                    ),
                    Text(userDisplay, style: const TextStyle(fontSize: 20, color: Colors.black)),
                    Text(DateFormat('dd MMMM yyyy').format(now), style: GoogleFonts.openSans(fontSize: 15, color: Colors.black54)),
                  ],
                ),
                const Icon(Icons.account_circle_rounded, size: 100, color: Color.fromARGB(255, 77, 146, 120))
              ],
            ),
          ),
          Center(
            child: Text(
              'Jadwal Hari Ini',
              style: GoogleFonts.openSans(fontSize: 23, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              backgroundColor: greenTheme,
              color: Colors.white,
              onRefresh:() async{
                if (mounted) setState(() {_isLoading = true;});
                if (_myBox.get('CLOCKSCHEDULE') != null) {
                  _myBox.delete('CLOCKSCHEDULE');
                }
                await _initializeData();
              } , 
              child: ListView.builder(
                itemCount: localDb.scheduleList.length,
                itemBuilder: (context, index) => AttendanceWidget(localDb: localDb, index: index),
              ),
            ),
          )
        ],
      ),
    );
  }
}
