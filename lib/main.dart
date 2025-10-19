import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: VxBox(
          child: "Hello, VelocityX!".text.white.xl5.makeCentered(),
        ).gray900.make(),
      ),
    );
  }
}
