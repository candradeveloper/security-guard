import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/pin_setup_screen.dart';
import 'screens/pin_lock_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  final prefs = await SharedPreferences.getInstance();
  final hasPin = prefs.getString('user_pin') != null;
  
  runApp(SecurityGuardApp(hasPin: hasPin));
}

class SecurityGuardApp extends StatelessWidget {
  final bool hasPin;
  const SecurityGuardApp({super.key, required this.hasPin});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Security Guard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00E5FF),
          secondary: const Color(0xFF7C4DFF),
          surface: const Color(0xFF0D0D1A),
          error: const Color(0xFFFF3D71),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),
      ),
      initialRoute: hasPin ? '/lock' : '/setup',
      routes: {
        '/setup': (context) => const PinSetupScreen(),
        '/lock': (context) => const PinLockScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
