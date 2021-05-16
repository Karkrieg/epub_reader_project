import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';

class BookReader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Example',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
    );
  }
}
