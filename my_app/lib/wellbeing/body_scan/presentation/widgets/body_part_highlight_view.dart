import 'package:flutter/material.dart';

class BodyPartHighlightView extends StatelessWidget {
  final String partKey;

  // Color principal
  static const Color primaryColor = Color(0xFFAFB99B);

  const BodyPartHighlightView(this.partKey, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.25),
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