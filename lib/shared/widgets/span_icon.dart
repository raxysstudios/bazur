import 'package:flutter/material.dart';

class SpanIcon extends StatelessWidget {
  const SpanIcon(
    this.icon, {
    this.color,
    this.padding = const EdgeInsets.only(right: 2),
    super.key,
  });

  final IconData icon;
  final Color? color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Icon(
        icon,
        size: 16,
        color: color ?? Theme.of(context).textTheme.bodySmall?.color,
      ),
    );
  }
}
