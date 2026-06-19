import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/ip_checker_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const IPCheckerApp());
}

class IPCheckerApp extends StatelessWidget {
  const IPCheckerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IPCheckerProvider()),
      ],
      child: MaterialApp(
        title: 'IP Checker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
