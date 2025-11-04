import 'package:flutter/material.dart';

class BodyPartHighlightView extends StatelessWidget {
  final String partKey;

  const BodyPartHighlightView(this.partKey, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9999).withOpacity(0.25),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/images/$partKey.png',
            width: 380,
            height: 450,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
