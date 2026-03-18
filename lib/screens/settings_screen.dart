import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/pin_pad.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _changingPin = false;
  String _firstPin = '';
  bool _confirming = false;
  String _status = '';

  void _onPinEntered(String pin) async {
    if (!_confirming) {
      setState(() {
        _firstPin = pin;
        _confirming = true;
        _status = 'Konfirmasi PIN baru';
      });
    } else {
      if (pin == _firstPin) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_pin', pin);
        setState(() {
          _changingPin = false;
          _status = '';
          _confirming = false;
          _firstPin = '';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ PIN berhasil diubah!')),
          );
        }
      } else {
        setState(() {
          _confirming = false;
          _firstPin = '';
          _status = '❌ PIN tidak cocok';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: const Color(0xFF69FF47),
      ),
      backgroundColor: const Color(0xFF0D0D1A),
      body: _changingPin
          ? Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  _confirming ? 'Konfirmasi PIN baru' : 'Masukkan PIN baru (6 digit)',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                if (_status.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(_status, style: const TextStyle(color: Color(0xFFFF3D71))),
                  ),
                const SizedBox(height: 20),
                PinPad(pinLength: 6, onPinComplete: _onPinEntered),
                TextButton(
                  onPressed: () => setState(() {
                    _changingPin = false;
                    _status = '';
                    _confirming = false;
                    _firstPin = '';
                  }),
                  child: const Text('Batal'),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SettingsCard(
                  icon: Icons.lock_reset,
                  color: const Color(0xFF69FF47),
                  title: 'Ganti PIN',
                  subtitle: 'Ubah PIN keamanan 6 digit',
                  onTap: () => setState(() => _changingPin = true),
                ),
                const SizedBox(height: 12),
                _SettingsCard(
                  icon: Icons.logout,
                  color: const Color(0xFFFF3D71),
                  title: 'Kunci Sekarang',
                  subtitle: 'Kembali ke layar PIN lock',
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/lock',
                    (route) => false,
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsCard(
                  icon: Icons.info_outline,
                  color: Colors.white30,
                  title: 'Tentang Aplikasi',
                  subtitle: 'Security Guard v1.0.0 by NACDEV',
                  onTap: () {},
                ),
              ],
            ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161626),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
