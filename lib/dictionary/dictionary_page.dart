import 'package:avzag/dictionary/search_controller.dart';
import 'package:avzag/dictionary/searcher.dart';
import 'package:avzag/dictionary/store.dart';
import 'package:avzag/firebase_builder.dart';
import 'package:avzag/home/store.dart';
import 'package:avzag/store.dart';
import 'package:avzag/utils.dart';
import 'entry/entry.dart';
import 'entry/entry_display.dart';
import 'package:avzag/navigation/nav_drawer.dart';
import 'package:flutter/material.dart';

import 'entry/entry_editor.dart';

class DictionaryPage extends StatefulWidget {
  @override
  _DictionaryPageState createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  late Searcher searcher;
  late Future<void>? loader;
  bool useScholar = false;

  @override
  void initState() {
    super.initState();
    searcher = Searcher(dictionaries, setState);

    loader = loadDictionaries(languages);
  }

  void showHelp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: [],
        );
      },
    );
  }

  void openEditor({Entry? entry}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryEditor(
          entry ?? Entry(forms: []),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureLoader(
      future: loader,
      builder: () => Scaffold(
        appBar: AppBar(
          title: Text(
            'Dictionaries',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            if (editorMode != null)
              IconButton(
                onPressed: openEditor,
                icon: Icon(Icons.add_box_outlined),
                tooltip: 'Add entry',
              ),
            IconButton(
              onPressed: showHelp,
              icon: Icon(Icons.help_outline_outlined),
              tooltip: 'Show help',
            ),
            SizedBox(width: 4),
          ],
        ),
        drawer: NavDraver(title: 'Dictionary'),
        body: ListView(
          children: [
            SearchController(searcher),
            Divider(height: 0),
            for (final m in searcher.results.entries) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  capitalize(m.key),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              for (final l in m.value.entries)
                for (final e in l.value)
                  ListTile(
                    dense: true,
                    title: Text(
                      capitalize(e.forms[0].plain),
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: Text(
                      capitalize(l.key),
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return EntryDisplay(
                            e,
                            scholar: useScholar,
                            toggleScholar: () => setState(() {
                              useScholar = !useScholar;
                            }),
                          );
                        },
                      );
                    },
                  ),
              Divider(height: 0),
            ],
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                searcher.executing
                    ? 'Searching...'
                    : searcher.done
                        ? 'End of results.'
                        : 'Start typing above to see results.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
