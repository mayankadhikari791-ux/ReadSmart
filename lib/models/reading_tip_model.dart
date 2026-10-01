import 'package:flutter/material.dart';

class ReadingTip {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String? badgeText;
  final String? actionText;
  final bool isComprehensionGuardrail;

  ReadingTip({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accentColor,
    this.badgeText,
    this.actionText,
    this.isComprehensionGuardrail = false,
  });
}
