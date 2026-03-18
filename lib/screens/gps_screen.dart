import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GpsScreen extends StatefulWidget {
  const GpsScreen({super.key});

  @override
  State<GpsScreen> createState() => _GpsScreenState();
}

class _GpsScreenState extends State<GpsScreen> {
  Position? _currentPosition;
  List<Map<String, dynamic>> _locationLog = [];
  bool _tracking = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadLog();
  }

  Future<void> _loadLog() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('gps_log') ?? [];
    setState(() {
      _locationLog = raw
          .map((e) => json.decode(e) as Map<String, dynamic>)
          .toList()
          .reversed
          .toList();
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _loading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnack('GPS tidak aktif, aktifkan dulu ya');
      setState(() => _loading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnack('Izin lokasi ditolak');
        setState(() => _loading = false);
        return;
      }
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final entry = {
      'lat': pos.latitude,
      'lng': pos.longitude,
      'accuracy': pos.accuracy,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('gps_log') ?? [];
    raw.add(json.encode(entry));
    if (raw.length > 50) raw.removeAt(0); // max 50 log
    await prefs.setStringList('gps_log', raw);

    setState(() {
      _currentPosition = pos;
      _loading = false;
    });

    _loadLog();
    _showSnack('📍 Lokasi berhasil direkam');
  }

  Future<void> _clearLog() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gps_log');
    setState(() => _locationLog = []);
  }

  void _showSnack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Tracker'),
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: const Color(0xFF00E5FF),
        actions: [
          if (_locationLog.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearLog,
              tooltip: 'Hapus log',
            ),
        ],
      ),
      backgroundColor: const Color(0xFF0D0D1A),
      body: Column(
        children: [
          // Current location card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF161626),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.gps_fixed, color: Color(0xFF00E5FF)),
                    const SizedBox(width: 8),
                    const Text(
                      'Lokasi Saat Ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    if (_loading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF00E5FF),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_currentPosition != null) ...[
                  _CoordRow(
                    label: 'Latitude',
                    value: _currentPosition!.latitude.toStringAsFixed(6),
                  ),
                  const SizedBox(height: 8),
                  _CoordRow(
                    label: 'Longitude',
                    value: _currentPosition!.longitude.toStringAsFixed(6),
                  ),
                  const SizedBox(height: 8),
                  _CoordRow(
                    label: 'Akurasi',
                    value: '${_currentPosition!.accuracy.toStringAsFixed(1)} m',
                  ),
                ] else
                  Text(
                    'Belum ada data lokasi\nTekan tombol di bawah untuk mulai',
                    style: TextStyle(color: Colors.white.withOpacity(0.4)),
                  ),
              ],
            ),
          ),

          // Log list
          Expanded(
            child: _locationLog.isEmpty
                ? Center(
                    child: Text(
                      'Log lokasi kosong',
                      style: TextStyle(color: Colors.white.withOpacity(0.3)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _locationLog.length,
                    itemBuilder: (context, index) {
                      final log = _locationLog[index];
                      final time = DateTime.parse(log['timestamp']);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161626),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: const Color(0xFF00E5FF).withOpacity(0.7),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${log['lat'].toStringAsFixed(5)}, ${log['lng'].toStringAsFixed(5)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _getCurrentLocation,
        backgroundColor: const Color(0xFF00E5FF),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.my_location),
        label: const Text('Rekam Lokasi'),
      ),
    );
  }
}

class _CoordRow extends StatelessWidget {
  final String label;
  final String value;
  const _CoordRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5))),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF00E5FF),
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
