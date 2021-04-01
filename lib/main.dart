import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chat_test/views/login.dart';

import 'package:chat_test/shared/const.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Demo',
      theme: ThemeData(
        primaryColor: themeColor,
      ),
      home: LoginScreen(title: 'CHAT DEMO'),
      debugShowCheckedModeBanner: false,
    );
  }
}
