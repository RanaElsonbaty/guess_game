import 'package:flutter/material.dart';

class CloseButtonWidget extends StatelessWidget {
  const CloseButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.close, color: Colors.white),
      ),
    );
  }
}
