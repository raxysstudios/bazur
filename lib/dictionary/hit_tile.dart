import 'package:algolia/algolia.dart';
import 'package:avzag/utils.dart';
import 'package:flutter/material.dart';

class EntryHit {
  final String entryID;
  final String headword;
  final String? form;
  final String language;
  final String term;
  final String? definition;
  final bool pendingReview;
  final List<String>? tags;

  const EntryHit({
    required this.entryID,
    required this.headword,
    this.form,
    required this.language,
    required this.term,
    this.tags,
    this.pendingReview = false,
    this.definition,
  });

  factory EntryHit.fromAlgoliaHit(AlgoliaObjectSnapshot hit) {
    final json = hit.data;

    final form = listFromJson(
          hit.highlightResult?['forms'],
          (i) => i['matchLevel'] != 'none',
        )?.indexOf(true) ??
        -1;

    return EntryHit(
      entryID: json['entryID'],
      headword: json['headword'],
      form: form >= 0 ? json2list(json['forms'])![form] : null,
      language: json['language'],
      term: json['term'],
      definition: json['definition'],
      pendingReview: json['pendingReview'] ?? false,
      tags: json2list(json['tags']),
    );
  }
}

class HitTile extends StatelessWidget {
  final EntryHit hit;
  final bool showLanguage;
  final VoidCallback? onTap;

  const HitTile(
    this.hit, {
    Key? key,
    this.showLanguage = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return ListTile(
      dense: true,
      title: Row(
        children: [
          if (hit.pendingReview) ...[
            const Icon(Icons.pending_actions_outlined),
            const SizedBox(width: 4),
          ],
          Text(
            capitalize(hit.headword),
            style: theme.subtitle1?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
          ),
          if (hit.form != null && hit.form != hit.headword) ...[
            const SizedBox(width: 4),
            Text(
              capitalize(hit.form!),
              style: TextStyle(
                color: theme.caption?.color,
              ),
              maxLines: 1,
            ),
          ],
          const Spacer(),
          if (showLanguage)
            Text(
              capitalize(hit.language),
              style: theme.caption,
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}
