import 'package:flutter/material.dart';

// NOTE: its always a good idea to have a Splash (i.e. loading) screen in your
// apps based on the style that you prefer (+make it reusable in other widgets)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FlutterChat"),
      ),
      body: const Center(
        child: Text("Loading!"),
      ),
    );
  }

}