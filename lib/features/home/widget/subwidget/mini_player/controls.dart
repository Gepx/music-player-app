import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class FControls extends StatelessWidget {
  const FControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Iconsax.previous, color: Colors.white, size: 20),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Iconsax.pause, color: Colors.white, size: 24),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Iconsax.next, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}
