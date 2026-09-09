import 'dart:ui';

Offset normalizeNotePosition({
  required Offset localPosition,
  required Size availableSize,
}) => Offset(
  availableSize.width == 0
      ? 0
      : (localPosition.dx / availableSize.width).clamp(0, 1).toDouble(),
  availableSize.height == 0
      ? 0
      : (localPosition.dy / availableSize.height).clamp(0, 1).toDouble(),
);

Offset resolveNotePosition({
  required Offset normalizedPosition,
  required Size availableSize,
}) => Offset(
  normalizedPosition.dx.clamp(0, 1).toDouble() * availableSize.width,
  normalizedPosition.dy.clamp(0, 1).toDouble() * availableSize.height,
);
