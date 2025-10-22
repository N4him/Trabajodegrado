import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BodyPartHighlightView extends StatelessWidget {
  final String partKey;

  const BodyPartHighlightView(this.partKey, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Silueta base en SVG (o PNG si prefieres)
        SvgPicture.asset(
          'assets/silhouette.svg',
          width: 300,
          height: 600,
        ),
        // Highlight específico como SVG
        SvgPicture.asset(
          'assets/highlights/highlight_$partKey.svg',
          width: 300,
          height: 600,
          color: Theme.of(context).primaryColor.withOpacity(0.4),
        ),
      ],
    );
  }
}
