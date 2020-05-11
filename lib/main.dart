import 'package:flutter/material.dart';
import 'package:iot_first_app/screens/mainScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.deepOrange,
        accentColor: Colors.white,
      ),
      home: MyHomePage(),
    );
  }
}
