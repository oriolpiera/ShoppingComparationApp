import 'package:flutter/material.dart';

import '../features/home/presentation/home_page.dart';

class PriceComparatorApp extends StatelessWidget {
  const PriceComparatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Price Comparator',
      theme: ThemeData(useMaterial3: true),
      home: HomePage(),
    );
  }
}
