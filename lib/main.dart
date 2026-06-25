import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_notifier/local_notifier.dart';
import 'theme/app_theme.dart';
import 'providers/ip_checker_provider.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await localNotifier.setup(
    appName: 'Netpulse',
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );
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
        title: 'Netpulse',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
