import 'package:flutter/material.dart';

/// A network image that fades in once its first frame decodes, instead of
/// popping in abruptly, and falls back to a plain surface tile on error.
class FadingNetworkImage extends StatelessWidget {
  const FadingNetworkImage({required this.imageUrl, required this.fit, super.key});

  final String? imageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    if (imageUrl == null) return ColoredBox(color: placeholderColor);

    return Image.network(
      imageUrl!,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => ColoredBox(color: placeholderColor),
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
  }
}
