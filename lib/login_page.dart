import 'package:flutter/material.dart';
import 'package:hc/util/error_catcher.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _useUsername = true;
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD2E8E3),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dynamic Input Field
                TextField(
                  controller: _useUsername ? _usernameController : _phoneController,
                  keyboardType: _useUsername ? TextInputType.text : TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: Icon(_useUsername ? Icons.person : Icons.phone),
                    hintText: _useUsername ? 'Username' : 'Phone Number',
                    filled: true,
                    fillColor: const Color(0xFFF3F0F0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    hintText: 'Password',
                    filled: true,
                    fillColor: const Color(0xFFF3F0F0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final input = _useUsername
                          ? _usernameController.text
                          : _phoneController.text;
                      final password = _passwordController.text;
                      if (input.isNotEmpty && password.isNotEmpty) {
                        await login(input, password, _useUsername);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please fill all fields'), showCloseIcon: true,),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3C8C6C),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Toggle Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text("Username"),
                      selected: _useUsername,
                      selectedColor: const Color(0xFFD2E8E3),
                      onSelected: (selected) {
                        setState(() {
                          _useUsername = true;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text("Phone"),
                      selectedColor: const Color(0xFFD2E8E3),
                      selected: !_useUsername,
                      onSelected: (selected) {
                        setState(() {
                          _useUsername = false;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login(String input, String password, bool useUsername) async {
    late final Uri url;
    late final dynamic userData;
    var urlUsers = Uri.parse('https://shift.lakesidefnb.group/api/users');
    late final http.Response response;
    input = input.trim();
    // Post
    try{
      if (useUsername){
        url = Uri.parse('https://shift.lakesidefnb.group/api/auth/LoginWithUsername');
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'username': input,
            'password': password,
          },
        );
      } else {
        url = Uri.parse('https://shift.lakesidefnb.group/api/auth/LoginWithNumber');
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'no_telepon': input,
            'password': password,
          },
        );
      }
      // Verification
      if (response.statusCode == 200) {
        final responseUser = await http.get(urlUsers);
        Map<String, dynamic> data = json.decode(responseUser.body);
        if (useUsername){
          userData = data['data'].firstWhere((user) => user['username'] == input, orElse: () => null);
        } else {
          userData = data['data'].firstWhere((user) => user['no_telepon'] == input, orElse: () => null);
        }
        final myBox = Hive.box('myBox');
        myBox.put('USERDATA', userData);
        Navigator.pushReplacementNamed(context, '/homepage');
      } else if (response.statusCode == 401) {
        if (useUsername){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Username/Password salah')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nomor Telepon/Password salah')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan saat login')),
        );
      }
    } catch (e){
      errorCatcher(from: "saat Login", error: e.toString());
    }
  }
}