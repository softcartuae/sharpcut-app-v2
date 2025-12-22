import 'package:flutter/material.dart';

IconData getIconForService(String? name) {
  if (name == null) return Icons.layers;

  final lowerName = name.toLowerCase();
  if (lowerName.contains('hair') || lowerName.contains('cut')) {
    return Icons.content_cut;
  }
  if (lowerName.contains('shav') || lowerName.contains('beard')) {
    return Icons.face;
  }
  if (lowerName.contains('face') || lowerName.contains('facial')) {
    return Icons.person_outline;
  }
  if (lowerName.contains('massage')) return Icons.spa;
  if (lowerName.contains('wash')) return Icons.water_drop;
  if (lowerName.contains('color') || lowerName.contains('dye')) {
    return Icons.format_paint;
  }
  if (lowerName.contains('nose')) return Icons.face_retouching_natural;

  return Icons.layers; // Default fallback
}
