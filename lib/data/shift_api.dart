import 'dart:convert';
import 'package:hc/util/error_catcher.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

class ShiftApi {  
  List<dynamic> filteredShifts = [];
  List<dynamic> scheduleList = [];
  List<dynamic> jobList = [];
  dynamic userData;

  Future<void>  fetchData() async{
    await fetchShiftData();
    await fetchJobData();
    await fetchScheduleData();
  }

  Future<void> fetchShiftData() async{
    final myBox = Hive.box('myBox');
    final user = myBox.get('USERDATA');
    var url = Uri.parse('https://shift.lakesidefnb.group/api/jadwal-shift');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200){
        String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        Map<String, dynamic> data = json.decode(response.body);
        filteredShifts = data['jadwal_shift'].where((shift) => shift['id_user'] == user['id'].toString() && shift['tanggal'] == today).toList();
      } else {
      }
    } catch(e){
      errorCatcher(from: 'Loading data shift', error: e.toString());
    }
  }

  Future<void> fetchScheduleData() async{
    var urlSchedule = Uri.parse('https://shift.lakesidefnb.group/api/jam-shift');
    try {
      var response = await http.get(urlSchedule);
      if (response.statusCode == 200){
        Map<String, dynamic> data = json.decode(response.body);
        scheduleList = data['JamShift'].toList();
      } else {
        print('failed to fetch Schedule');
      }
    } catch(e){
      print('API Request Error: $e');
      errorCatcher(from: 'Loading data schedule', error: e.toString());
    }
  }

  Future<void> fetchJobData() async{
    var urlJob = Uri.parse('https://shift.lakesidefnb.group/api/tipe-pekerjaan');
    try {
      var response = await http.get(urlJob);
      if (response.statusCode == 200){
        Map<String, dynamic> data = json.decode(response.body);
        jobList = data['TipePekerjaan'].toList();
      } else {
        print('failed to fetch Job');
      }
    } catch(e){
      print('API Request Error: $e');
      errorCatcher(from: 'Loading data job', error: e.toString());
    }
  }

  Future<void> fetchUsersData(String input, bool useUsername) async{
    var urlUsers = Uri.parse('https://shift.lakesidefnb.group/api/users');
    try {
      var response = await http.get(urlUsers);
      if (response.statusCode == 200){
        Map<String, dynamic> data = json.decode(response.body);
        if (useUsername){
          userData = data['users'].firstWhere((user) => user['username'] == input, orElse: () => null);
        } else {
          userData = data['users'].firstWhere((user) => user['no_telepon'] == input, orElse: () => null);
        }
      } else{
        print('failed to fetch Users');
      }
    } catch(e){
      print('API Request Error: $e');
      errorCatcher(from: 'Loading data user', error: e.toString());
    }
  }

  Future<List<dynamic>> fetchOutletData() async {
    final String apiToken = '92|BN2EvdcWabONwrvbSIbFgSZyPoEoFwjsRwse7li6';
    final String apiUrl = 'https://pos.lakesidefnb.group/api/outlet';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          return responseData['data'];
        } else {
          return [];
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('API Request Error: $e');
      errorCatcher(from: 'Loading data outlet', error: e.toString());
      return [];
    }
  }
}

Future<List<dynamic>> getShiftData() async{
  var url = Uri.parse('https://shift.lakesidefnb.group/api/jadwal-shift');
  try {
    var response = await http.get(url);
    if (response.statusCode == 200){
      Map<String, dynamic> data = json.decode(response.body);
      return data['jadwal_shift'];
    } else {
      return [];
    }
  } catch(e){
    errorCatcher(from: 'Loading data shift', error: e.toString());
    return [];
  }
}

Future<List<dynamic>> getScheduleData() async{
  var urlSchedule = Uri.parse('https://shift.lakesidefnb.group/api/jam-shift');
  try {
    var response = await http.get(urlSchedule);
    if (response.statusCode == 200){
      Map<String, dynamic> data = json.decode(response.body);
      return data['JamShift'];
    } else {
      return [];
    }
  } catch(e){
    errorCatcher(from: 'Loading data schedule', error: e.toString());
    return [];
  }
}

Future<List<dynamic>> getJobData() async{
  var urlJob = Uri.parse('https://shift.lakesidefnb.group/api/tipe-pekerjaan');
  try {
    var response = await http.get(urlJob);
    if (response.statusCode == 200){
      Map<String, dynamic> data = json.decode(response.body);
      return data['TipePekerjaan'];
    } else {
      return [];
    }
  } catch(e){
    errorCatcher(from: 'Loading data job', error: e.toString());
    return [];
  }
}

Future<List<dynamic>> getUsersData() async{
  var urlUsers = Uri.parse('https://shift.lakesidefnb.group/api/users');
  try {
    var response = await http.get(urlUsers);
    if (response.statusCode == 200){
      Map<String, dynamic> data = json.decode(response.body);
      return data['users'];
    } else{
      print('failed to fetch Users');
      return [];
    }
  } catch(e){
    errorCatcher(from: 'Loading data user', error: e.toString());
    return [];
  }
}

Future<List<dynamic>> getOutletData() async {
  final String apiToken = '92|BN2EvdcWabONwrvbSIbFgSZyPoEoFwjsRwse7li6';
  final String apiUrl = 'https://pos.lakesidefnb.group/api/outlet';

  try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('data') && responseData['data'] is List) {
        return responseData['data'];
      } else {
        return [];
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('API Request Error: $e');
    errorCatcher(from: 'Loading data outlet', error: e.toString());
    return [];
  }
}