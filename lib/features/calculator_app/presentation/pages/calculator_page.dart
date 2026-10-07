import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorPage());
}

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      debugShowCheckedModeBanner: false,
      home: const CalculatorHomePage(),
    );
  }
}

class CalculatorHomePage extends StatelessWidget {
  const CalculatorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator App'),
      ),
      body: const Center(
        child: Text(
          'Hello, Flutter!',
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
