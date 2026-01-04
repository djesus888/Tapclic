import 'package:flutter/material.dart';

/// StarRating.vue → star_rating.dart
/// Guardar en: lib/widgets/star_rating.dart
class StarRating extends StatelessWidget {
  final double rating;
  const StarRating({super.key, required this.rating});

  double get _safeRating {
    final val = rating.toDouble();
    if (val.isNaN) return 0;
    return val.clamp(0, 5);
  }

  @override
  Widget build(BuildContext context) {
    final color = _safeRating > 0 ? Colors.amber : Theme.of(context).colorScheme.onSurface.withOpacity(0.3);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = (i + 1) <= _safeRating;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          size: 16,
          color: filled ? color : null,
        );
      }),
    );
  }
}
