import 'package:flutter/material.dart';

class StagePath extends StatelessWidget {
  final double height;

  const StagePath({super.key, this.height = 200}); // default height changed

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Image.asset(
        'assets/images/path.png', // use renamed asset file
        fit: BoxFit.fitHeight,
      ),
    );
  }
}