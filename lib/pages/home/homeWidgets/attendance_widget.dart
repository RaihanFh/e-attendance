import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hc/data/localdb.dart';
import 'package:hc/data/global_variable.dart';
import 'package:hc/pages/home/homeWidgets/clock_slider.dart';
import 'package:hc/util/error_catcher.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceWidget extends StatefulWidget {
  final LocalDb localDb;
  final int index;
  const AttendanceWidget({
    required this.localDb,
    required this.index,  
    super.key
  });

  @override
  State<AttendanceWidget> createState() => _AttendanceWidgetState();
}

class _AttendanceWidgetState extends State<AttendanceWidget> {
  bool isLoading = false;
  bool enableSlider = true;
  String sliderType = 'Clock In';
  late DateTime scheduleIn;
  late DateTime scheduleOut;
  late String outlet;
  late String role;
  late String status;
  late int id;

  @override
  void initState() {
    super.initState();
    scheduleIn = widget.localDb.toDate(widget.localDb.scheduleList[widget.index].scheduleIn);
    scheduleOut = widget.localDb.toDate(widget.localDb.scheduleList[widget.index].scheduleOut);
    status = widget.localDb.scheduleList[widget.index].status;
    role = widget.localDb.scheduleList[widget.index].role;
    outlet = widget.localDb.scheduleList[widget.index].outlet;
    id = widget.localDb.scheduleList[widget.index].id;

    if (widget.localDb.scheduleList[widget.index].clockIn != '') {
      sliderType = 'Clock Out';
    }

    if (widget.localDb.scheduleList[widget.index].clockOut != '') {
      sliderType = 'Thank you for your work';
      enableSlider = false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: widgetBg,
        borderRadius: BorderRadius.circular(12)
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Role   \t\t:\t $role'),
                Text('Mulai :\t ${DateFormat('HH:mm').format(scheduleIn)}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Outlet\t:\t $outlet'),
                Text('Selesai :\t ${DateFormat('HH:mm').format(scheduleOut)}'),
              ],
            ),
          ),
          ClockSlider(
            localDb: widget.localDb, 
            index: widget.index, 
            isLoading: isLoading,
            sliderType: sliderType,
            handler: (context, type) => handleTap(context: context, type: type),
            enableSlider: enableSlider,
          )
        ],
      ),
    );
  }

  // --------------------------------------- Functions ---------------------------------------
  Future<void> handleTap(
      {required BuildContext context,
      required String type,}) async {
    try {
      if (type == 'Clock In') {
        await _handleClockIn(context);
      } else {
        await _handleClockOut(context);
      }
    } catch (e) {
      errorCatcher(from: 'Loading data', error: e.toString());
    } finally{
      if (mounted) setState(() {isLoading = false;});
    }
  }

  // Check-In
  Future<void> _handleClockIn(BuildContext context) async {
    if (mounted) setState(() {
      isLoading = true;
    });
    Position value = await _getCurrentLocation(context);
    String location = _isWithinRadius(value.latitude, value.longitude)
      ? 'In store'
      : 'Not in store'
    ;
    if (location == 'In store') {
      clockedIn(widget.localDb.toDate(widget.localDb.scheduleList[widget.index].scheduleIn));
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: widgetBg,
          title: const Text('Reminder'),
          content: const Text('Please go to your shift location to Clock In', ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (mounted) setState(() {
                  isLoading = false;
                });
              },
              child: Text('Ok', style: TextStyle(color: greenTheme)),
            ),
          ],
        ),
      );
    }
  }
  void clockedIn(DateTime schedule) async {
    DateTime now = DateTime.now();
    String strNow = widget.localDb.dateToString(now, now.hour, now.minute);
    bool success = false;
    try {
      success = await _updateData(true, id, now);
    } catch(e) {
      print('Terjadi kesalahan: $e');
      errorCatcher(from: 'Clock In', error: e.toString());
    }
    if (success) {
      if (mounted) setState(() {
        status = statusCheck('Clock In', schedule, now);
        widget.localDb.scheduleList[widget.index].status = status;
        widget.localDb.scheduleList[widget.index].clockIn = strNow;
        widget.localDb.clockUpdateData();
        sliderType = 'Clock Out';
        isLoading = false;
      });
    } else {
      isLoading = false;
    }
  }

  // Check-Out
  Future<void> _handleClockOut(BuildContext context) async {
    if (mounted) setState(() {
      isLoading = true;
    });
    Position value = await _getCurrentLocation(context);
    String location = _isWithinRadius(value.latitude, value.longitude)
      ? 'In store'
      : 'Not in store'
    ;
    if (location == 'In store') {
      clockedOut(widget.localDb.toDate(widget.localDb.scheduleList[widget.index].scheduleOut));
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: widgetBg,
          title: const Text('Reminder'),
          content: const Text('Please go to your shift location to Clock Out'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (mounted) setState(() {
                  isLoading = false;
                });
              },
              child: Text('Ok', style: TextStyle(color: greenTheme)),
            ),
          ],
        ),
      );
    }
  }
  void clockedOut(DateTime schedule) async {
    DateTime now = DateTime.now();
    String strNow = widget.localDb.dateToString(now, now.hour, now.minute);
    bool success = false;
    try {
      success = await _updateData(false, id, now);
    } catch(e) {
      print('Terjadi kesalahan: $e');
      errorCatcher(from: 'Clock out', error: e.toString());
    }
    if (success) {
      if (mounted) setState(() {
      status = statusCheck('Clock In', schedule, now);
      widget.localDb.scheduleList[widget.index].status = status;
      widget.localDb.scheduleList[widget.index].clockOut = strNow;
      widget.localDb.clockUpdateData();
      sliderType = 'Thank you for your work';
      enableSlider = false;
      isLoading = false;
      });
    } else {
      isLoading = false;
    }
  }

  // Status checker
  String statusCheck(String type, DateTime schedule, DateTime clock) {
    if (type == 'Clock In') {
      if (_isOnTime(type, clock, schedule, 0)) {
        return 'On Time';
      } else if (_isLate(clock, schedule, 0)) {
        return 'Late';
      } else {
        return 'Didn\'t attend';
      }
    } else {
      if (_isOnTime(type, clock, schedule, 0)) {
        return 'On Time';
      } else if (_isOvertime(clock, schedule, 60)) {
        return 'Overtime';
      } else {
        return 'Didn\'t attend';
      }
    }
  }
  bool _isOnTime(String type, DateTime now, DateTime date, int minutes) {
    if (type == 'Clock In') {
      return (now.year == date.year &&
              now.month == date.month &&
              now.day == date.day) &&
          ((now.isBefore(date.add(Duration(minutes: minutes)))) &&
              (now.isAfter(date.subtract(Duration(minutes: minutes + 31)))));
    } else {
      return (now.year == date.year &&
              now.month == date.month &&
              now.day == date.day) &&
          ((now.isAfter(date.add(Duration(minutes: minutes)))) &&
              (now.isBefore(date.add(Duration(minutes: minutes + 60)))));
    }
  }
  bool _isLate(DateTime now, DateTime date, int minutes) {
    return (now.year == date.year &&
            now.month == date.month &&
            now.day == date.day) &&
        (now.isAfter(date.add(Duration(minutes: minutes))));
  }
  bool _isOvertime(DateTime now, DateTime date, int minutes) {
    return (now.year == date.year &&
            now.month == date.month &&
            now.day == date.day) &&
        (now.isAfter(date.add(Duration(minutes: minutes))));
  }

  // Location service
  Future<Position> _getCurrentLocation(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDisabledDialog(context);
      if (mounted) setState(() {
        isLoading = false;
      });
      return Future.error('Location services are disabled');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() {
          isLoading = false;
        });
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() {
        isLoading = false;
      });
      return Future.error('Location permissions are permanently denied');
    }
    return await Geolocator.getCurrentPosition();
  }
  bool _isWithinRadius(double userLat, double userLong) {
    final double targetLat;
    final double targetLong;
    switch (widget.localDb.scheduleList[widget.index].outlet){
      case "HARMONY CAFE":
        targetLat = -6.973916518585853;
        targetLong = 107.63137344578338;
        break;
      case "LAKESIDE":
        targetLat = -6.972392030917999;
        targetLong = 107.6312519399845;
        break;
      case "LITERASI": 
        targetLat = -6.97153252442936; 
        targetLong = 107.63224928668637;
        break;
      case "LAKESIDE FIT+":
        targetLat = -6.972392030917999;
        targetLong = 107.6312519399845;
        break;
      default:
        targetLat = userLat;
        targetLong = userLong;
    }
    double distance = Geolocator.distanceBetween(userLat, userLong, targetLat, targetLong);
    return distance <= 50;
  }
  void _showLocationServiceDisabledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widgetBg,
        title: const Text('Location services are disabled'),
        content: const Text('Please enable location service'),
        actions: [
          TextButton(
            onPressed: () async {
              await Geolocator.openLocationSettings();
              Navigator.of(context).pop();
            },
            child: Text('Go to location settings', style: TextStyle(color: greenTheme)),
          ),
        ],
      ),
    );
  }
  
  // Update data in API
  Future<bool> _updateData(bool isCheckin, int id, DateTime time) async {
    final url = Uri.parse('https://shift.lakesidefnb.group/api/jadwal-shift/$id');
    final response = await http.get(url);
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
    if (response.statusCode == 200) {
      var request = json.decode(response.body);
      if (isCheckin) {
        request['JadwalShift']['check_in_time'] = timeStr;
      } else {
        request['JadwalShift']['check_out_time'] = timeStr;
      }
      print(jsonEncode(request['JadwalShift']));
      final putResponse = await http.put(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(request['JadwalShift']));
      if (putResponse.statusCode == 200) {
        print('Update berhasil');
        return true;
      } else {
        print('Update gagal: ${putResponse.statusCode}');
      }
    } else {
      print('Pengambilan data gagal: ${response.statusCode}');
    }
    isLoading = false;
    return false;
  }
}