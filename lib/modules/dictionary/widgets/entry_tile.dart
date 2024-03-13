import 'package:bazur/models/entry.dart';
import 'package:bazur/shared/extensions.dart';
import 'package:bazur/shared/utils.dart';
import 'package:bazur/shared/widgets/span_icon.dart';

import 'package:flutter/material.dart';

class EntryTile extends StatelessWidget {
  final Entry hit;
  final bool showLanguage;
  final VoidCallback? onTap;

  const EntryTile(
    this.hit, {
    this.showLanguage = true,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return ListTile(
      visualDensity: const VisualDensity(
        vertical: VisualDensity.minimumDensity,
      ),
      title: Row(
        children: [
          if (hit.unverified)
            const SpanIcon(
              Icons.unpublished_outlined,
              padding: EdgeInsets.only(right: 8),
            ),
          Text(
            hit.headword.titled,
            style: styleNative.copyWith(
              fontSize: theme.titleMedium?.fontSize,
            ),
          ),
          if (hit.form != null && hit.form != hit.headword)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                hit.form!.titled,
                style: styleNative.copyWith(
                  fontSize: theme.titleMedium?.fontSize,
                  color: theme.bodySmall?.color,
                ),
              ),
            ),
          const Spacer(),
          if (showLanguage)
            Text(
              hit.language.titled,
              style: theme.bodySmall,
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}
