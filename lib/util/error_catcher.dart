import 'package:flutter/material.dart';
import 'package:hc/data/global_variable.dart';

void errorCatcher({required String from, required String error}){
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: widgetBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 2),
            Text("Terjadi kesalahan", style: TextStyle(fontSize: 20),),
          ],
        ),
        content: Text("Terjadi kesalahan di $from:\n$error",),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK", style: TextStyle(color: Colors.grey[700]),),
          ),
        ],
      );
    },
  );
}