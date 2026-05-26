import 'package:flutter/material.dart';

class PriceComparatorApp extends StatelessWidget {
  const PriceComparatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Price Comparator',
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: Center(
          child: Text('Shopping Comparator App'),
        ),
      ),
    );
  }
}
