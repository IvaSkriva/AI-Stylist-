import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/closet_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AiStylistApp());
}

class AiStylistApp extends StatelessWidget {
  const AiStylistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ClosetProvider>(
      create: (_) => ClosetProvider()..loadItems(),
      child: MaterialApp(
        title: 'AI Stylist',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}
