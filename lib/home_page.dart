import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hc/data/global_variable.dart';
import 'package:hc/pages/taskManagement/task_management.dart';
import 'package:hive_flutter/hive_flutter.dart';

// halaman2 di navagation bar
import 'package:hc/pages/home/home.dart';
import 'package:hc/pages/task/task.dart';
import 'package:hc/pages/account/account.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // index untuk tab yang dipilih
  final user = Hive.box('myBox').get('USERDATA');
  late final List<Widget> _pages;
  late final List<Widget> _icons;

  @override
  void initState() {
    if(user['role'] == 'Manager'){
      _pages = [
        Home(),
        Task(),
        TaskManagement(),
        Account()
      ];
      _icons = [
        Icon(Icons.home, color: Colors.white),
        Icon(Icons.task_alt_outlined, color: Colors.white),
        Icon(Icons.post_add_rounded, color: Colors.white),
        Icon(Icons.account_circle, color: Colors.white),
      ];
    } else{
      _pages = [
        Home(),
        Task(),
        Account()
      ];
      _icons = [
        Icon(Icons.home, color: Colors.white),
        Icon(Icons.task_alt_outlined, color: Colors.white),
        Icon(Icons.account_circle, color: Colors.white),
      ];
    }
    super.initState();
  }

  // method untuk mengubah tab yang dipilih
  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // App bar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: greenTheme,
        elevation: 0,
        centerTitle: true,
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Lakeside FnB\n',
                style: GoogleFonts.poiretOne(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextSpan(
                text: 'e-attendance',
                style: GoogleFonts.sourceSans3(
                  textStyle: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: _pages[_selectedIndex], // page yang dipilih
      // navigation bar
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        onTap: _navigateBottomBar,
        backgroundColor: Colors.white,
        color: greenTheme,
        animationDuration: const Duration(milliseconds: 300),
        items: _icons,
      ),
    );
  }
}
