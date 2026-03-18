import 'package:flutter/material.dart';

class PinPad extends StatefulWidget {
  final int pinLength;
  final void Function(String pin) onPinComplete;

  const PinPad({
    super.key,
    required this.pinLength,
    required this.onPinComplete,
  });

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _pin = '';

  void _addDigit(String digit) {
    if (_pin.length < widget.pinLength) {
      setState(() => _pin += digit);
      if (_pin.length == widget.pinLength) {
        final submitted = _pin;
        setState(() => _pin = '');
        widget.onPinComplete(submitted);
      }
    }
  }

  void _removeDigit() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PIN dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.pinLength, (i) {
            final filled = i < _pin.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled
                    ? const Color(0xFF00E5FF)
                    : Colors.transparent,
                border: Border.all(
                  color: filled
                      ? const Color(0xFF00E5FF)
                      : Colors.white38,
                  width: 2,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 40),
        // Number grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              for (var row in [
                ['1', '2', '3'],
                ['4', '5', '6'],
                ['7', '8', '9'],
                ['', '0', '⌫'],
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: row.map((key) {
                      if (key.isEmpty) return const SizedBox(width: 72);
                      return _PinKey(
                        label: key,
                        onTap: () {
                          if (key == '⌫') {
                            _removeDigit();
                          } else {
                            _addDigit(key);
                          }
                        },
                        isDelete: key == '⌫',
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PinKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDelete;

  const _PinKey({
    required this.label,
    required this.onTap,
    this.isDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDelete
              ? const Color(0xFFFF3D71).withOpacity(0.1)
              : const Color(0xFF161626),
          border: Border.all(
            color: isDelete
                ? const Color(0xFFFF3D71).withOpacity(0.3)
                : Colors.white12,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isDelete ? const Color(0xFFFF3D71) : Colors.white,
              fontSize: isDelete ? 20 : 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
