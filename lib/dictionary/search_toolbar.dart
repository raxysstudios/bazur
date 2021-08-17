import 'dart:async';
import 'package:avzag/home/language_avatar.dart';
import 'package:avzag/home/store.dart';
import 'package:avzag/store.dart';
import 'package:avzag/utils.dart';
import 'package:flutter/material.dart';
import 'hit_tile.dart';

class SearchToolbar extends StatefulWidget {
  final ValueSetter<List<List<EntryHit>>> onSearch;
  const SearchToolbar(this.onSearch);

  @override
  SearchToolbarState createState() => SearchToolbarState();
}

class SearchToolbarState extends State<SearchToolbar> {
  final inputController = TextEditingController();
  Timer timer = Timer(Duration.zero, () {});
  String text = "";
  bool searching = false;
  String? language;

  @override
  void initState() {
    super.initState();
    if (BaseStore.languages.length == 1) language = BaseStore.languages.first;
    inputController.addListener(() {
      final text = inputController.text
          .split(' ')
          .where((e) => e.isNotEmpty && e != '#')
          .join(' ');
      if (this.text != text) {
        timer.cancel();
        setState(() {
          this.text = text;
        });
        if (text.isEmpty)
          search();
        else
          timer = Timer(
            Duration(milliseconds: 300),
            search,
          );
      }
    });
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  String filterOr(String filter, Iterable<String> values) =>
      values.map((v) => '$filter:$v').join(' OR ');

  void search() async {
    setState(() {
      searching = text.isNotEmpty;
    });
    widget.onSearch(<List<EntryHit>>[]);
    if (!searching) return;

    var query = BaseStore.algolia.instance
        .index(
          (language?.isEmpty ?? true) ? 'dictionary' : 'dictionary_headword',
        )
        .query(text)
        .filters(
          filterOr(
            'language',
            (language?.isEmpty ?? true) ? BaseStore.languages : [language!],
          ),
        )
        .setRestrictSearchableAttributes([
      'term',
      'forms',
      'definition',
      if (text.contains('#')) 'tags',
    ]);

    final snap = await query.getObjects().then(
          (snapshot) async => (language?.isEmpty ?? false)
              ? await BaseStore.algolia.instance
                  .index('dictionary')
                  .filters(
                    filterOr(
                      'term',
                      snapshot.hits.map((hit) => hit.data['term']),
                    ),
                  )
                  .getObjects()
              : snapshot,
        );

    final hits = snap.hits.map((h) => EntryHit.fromAlgoliaHit(h)).toList();
    if (language?.isNotEmpty ?? false)
      widget.onSearch([hits]);
    else {
      final groups = <String, List<EntryHit>>{};
      for (final hit in hits) {
        final key = hit.term;
        if (!groups.containsKey(key)) groups[key] = [];
        groups[key]!.add(hit);
      }
      widget.onSearch(groups.values.toList());
    }
    setState(() {
      searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              PopupMenuButton<String>(
                icon: language == null
                    ? Icon(Icons.language_outlined)
                    : language!.isEmpty
                        ? Icon(Icons.auto_awesome_outlined)
                        : LanguageAvatar(language!),
                tooltip: 'Select search mode',
                onSelected: (l) {
                  setState(() {
                    language = l == 'English' ? null : l;
                  });
                  inputController.clear();
                },
                itemBuilder: (BuildContext context) {
                  const density = const VisualDensity(
                    vertical: VisualDensity.minimumDensity,
                    horizontal: VisualDensity.minimumDensity,
                  );
                  return [
                    if (BaseStore.languages.length > 1) ...[
                      PopupMenuItem(
                        value: 'English',
                        child: ListTile(
                          visualDensity: density,
                          leading: Icon(Icons.language_outlined),
                          title: Text('English'),
                          selected: language == null,
                        ),
                      ),
                      PopupMenuItem(
                        value: '',
                        child: ListTile(
                          visualDensity: density,
                          leading: Icon(Icons.auto_awesome_outlined),
                          title: Text('Cross-lingual'),
                          selected: language?.isEmpty ?? false,
                        ),
                      ),
                      PopupMenuDivider(),
                    ],
                    for (final l in BaseStore.languages)
                      PopupMenuItem(
                        value: l,
                        child: ListTile(
                          visualDensity: density,
                          leading: LanguageAvatar(l),
                          title: Text(
                            capitalize(HomeStore.languages[l]!.name),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: language == l,
                        ),
                      ),
                  ];
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 4),
                  child: TextField(
                    controller: inputController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Search by terms, forms, tags' +
                          (language?.isEmpty ?? true
                              ? ''
                              : ' in ${capitalize(language!)}'),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed:
                    inputController.text.isEmpty ? null : inputController.clear,
                icon: Icon(Icons.clear),
              ),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: searching ? null : 0,
        ),
      ],
    );
  }
}