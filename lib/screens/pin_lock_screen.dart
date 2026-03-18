import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/pin_pad.dart';
import '../services/intruder_service.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen>
    with TickerProviderStateMixin {
  int _attempts = 0;
  String _errorMsg = '';
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onPinEntered(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('user_pin') ?? '';

    if (pin == savedPin) {
      await prefs.setInt('failed_attempts', 0);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } else {
      _attempts++;
      _shakeController.forward(from: 0);

      // Ambil foto intruder setelah 2 kali salah
      if (_attempts >= 2) {
        await IntruderService.captureIntruder();
      }

      setState(() {
        _errorMsg = _attempts >= 2
            ? '❌ Salah PIN! Foto diambil ($_attempts x)'
            : '❌ PIN salah, coba lagi';
      });

      // Lock sementara setelah 5x salah
      if (_attempts >= 5) {
        setState(() {
          _errorMsg = '🔒 Terlalu banyak percobaan. Tunggu 30 detik...';
        });
        await Future.delayed(const Duration(seconds: 30));
        setState(() {
          _attempts = 0;
          _errorMsg = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0D1A), Color(0xFF1A0D2E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: const Icon(
                  Icons.lock_outline,
                  size: 72,
                  color: Color(0xFF00E5FF),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Masukkan PIN',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_errorMsg.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3D71).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFF3D71).withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMsg,
                    style: const TextStyle(color: Color(0xFFFF3D71)),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 40),
              PinPad(
                pinLength: 6,
                onPinComplete: _onPinEntered,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
