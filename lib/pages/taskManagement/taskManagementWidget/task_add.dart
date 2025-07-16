import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hc/data/global_variable.dart';
import 'package:hc/util/error_catcher.dart';
import 'package:http/http.dart' as http;

class Taskadd extends StatefulWidget {
  final Map<String, dynamic> staff;
  final VoidCallback revert;
  final String time, date, role;
  const Taskadd({required this.staff, required this.date, required this.time, required this.role, required this.revert, super.key});

  @override
  State<Taskadd> createState() => _TaskaddState();
}

class _TaskaddState extends State<Taskadd> {
  bool _isLoading = false;
  final _controller = TextEditingController();
  List<String> taskList =[];
  List<String> statusList =[];

  @override
  void initState() {
    if(widget.staff['task'] != null && widget.staff['task'].toString().isNotEmpty){
      taskList = widget.staff['task'].toString().split(';');
      statusList = widget.staff['task_status'].toString().split(';');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              createNewTask();
            },
            backgroundColor: greenTheme,
            shape: CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white,),
          ),
          body: Column(
            children: [
              Row(
                children: [
                  IconButton(onPressed: widget.revert, icon: Icon(Icons.arrow_back_sharp)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${widget.role}', style: GoogleFonts.openSans(fontSize: 20, color: Colors.black),),
                      Text('${widget.date} | ${widget.time}', style: GoogleFonts.openSans(fontSize: 20, color: Colors.black),),
                    ],
                  ),
                  SizedBox()
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: ListView.builder(
                    itemCount: taskList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _showTaskOptions(index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(horizontal: 16),
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
                                child: Center(
                                  child: Text(
                                    taskList[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 8,
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: greenTheme,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    (index + 1).toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                ),
              ),
            ],
          ),
        ),
        _isLoading
        ?Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(child: CircularProgressIndicator(color: greenTheme),),
        )
        : Container()
      ]
    );
  }

  void createNewTask() {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          backgroundColor: widgetBg,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Tambah Task baru',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: greenTheme, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: greenTheme, width: 2),
                  ),
                ),
                cursorColor: Colors.black,
                maxLines: 10,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              )
            ],
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                addTask(_controller.text);
                Navigator.of(context).pop();
              } ,
              color: Color(0xFF4CAF50),
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
            MaterialButton(
              onPressed: () => Navigator.of(context).pop(),
              color: Colors.grey,
              child: Text('Cancel', style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      }
    );
  }

Future<void> addTask(String input) async {
  if (input.trim().isEmpty) return;
  if (mounted) setState(() {
    taskList.add(input.trim());
    statusList.add('In Progress');
    _controller.clear();
  });
  await updateTaskList(); 
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: widgetBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("Berhasil"),
          ],
        ),
        content: Text("Task berhasil ditambahkan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}


  void _showTaskOptions(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: widgetBg,
          title: Text("Task ${index + 1}"),
          content: Text("Pilih tindakan yang ingin dilakukan."),
          actions: [
            TextButton.icon(
              icon: Icon(Icons.delete, color: Colors.red),
              label: Text("Hapus"),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTask(index);
              },
            ),
            TextButton(
              child: Text("cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // void _editTask(int index) {
  //   _controller.text = taskList[index];
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text("Edit Task"),
  //         content: TextField(
  //           controller: _controller,
  //           decoration: InputDecoration(
  //             border: OutlineInputBorder(),
  //             hintText: 'Edit task',
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               if (mounted) setState(() {
  //                 taskList[index] = _controller.text;
  //                 _controller.clear();
  //               });
  //               updateTaskList();
  //               Navigator.of(context).pop();
  //             },
  //             child: Text("Simpan"),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               _controller.clear();
  //               Navigator.of(context).pop();
  //             },
  //             child: Text("Batal"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _deleteTask(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: widgetBg,
          title: Text("Hapus Task"),
          content: Text("Apakah kamu yakin ingin menghapus task ini?"),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) setState(() {
                  taskList.removeAt(index);
                  statusList.removeAt(index);
                });
                updateTaskList();
                Navigator.of(context).pop();
              },
              child: Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Batal"),
            ),
          ],
        );
      },
    );
  }


  Future<void> updateTaskList() async {
    final url = Uri.parse('https://shift.lakesidefnb.group/api/jadwal-shift/${widget.staff['id']}');
    widget.staff['task'] = taskList.join(';');
    widget.staff['task_status'] = statusList.join(';');
    if (mounted) setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(widget.staff),
      );
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan ke server')),
        );
      }
    } catch (e) {
      errorCatcher(from: 'Saat update', error: e.toString());
    } finally {
      if (mounted) setState(() {
        _isLoading = false;
      });
    }
  }
}