import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hc/data/global_variable.dart';
import 'package:hc/home_page.dart';
import 'package:hc/login_page.dart';
import 'package:hc/util/dependency_injection.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('myBox');
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  DependencyInjection.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: (Hive.box('myBox').get('USERDATA')!=null) ? HomePage():
      LoginPage(),
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black), 
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      routes: {
        '/homepage': (context) => const HomePage(),
        '/loginpage': (context) => const LoginPage(),
      },
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
    );
  }
}
