import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/pin_pad.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _firstPin = '';
  String _confirmPin = '';
  bool _confirming = false;
  String _status = '';

  void _onPinEntered(String pin) async {
    if (!_confirming) {
      setState(() {
        _firstPin = pin;
        _confirming = true;
        _status = 'Konfirmasi PIN kamu';
      });
    } else {
      if (pin == _firstPin) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_pin', pin);
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        setState(() {
          _confirming = false;
          _firstPin = '';
          _status = '❌ PIN tidak cocok, coba lagi';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Icon(Icons.security, size: 64, color: Color(0xFF00E5FF)),
            const SizedBox(height: 16),
            Text(
              'Security Guard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF00E5FF),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _confirming ? 'Konfirmasi PIN kamu' : 'Buat PIN baru (6 digit)',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white60,
              ),
            ),
            if (_status.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _status,
                style: const TextStyle(color: Color(0xFFFF3D71)),
              ),
            ],
            const SizedBox(height: 40),
            PinPad(
              pinLength: 6,
              onPinComplete: _onPinEntered,
            ),
          ],
        ),
      ),
    );
  }
}
