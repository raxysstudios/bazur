import 'package:avzag/home/language_tile.dart';
import 'package:avzag/home/store.dart';
import 'package:avzag/store.dart';
import 'package:avzag/utils.dart';
import 'package:flutter/material.dart';

class EditorSwitch extends StatefulWidget {
  @override
  _EditorSwitchState createState() => _EditorSwitchState();
}

class _EditorSwitchState extends State<EditorSwitch> {
  Future<String?> chooseLanguage() async {
    return await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text("Select editing language"),
        children: [
          Container(
            height: 512,
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.edit_off_outlined),
                  title: Text("None"),
                  selected: editorMode == null,
                  onTap: () => Navigator.pop(context),
                ),
                for (final l in languages)
                  LanguageTile(
                    l,
                    selected: editorMode == l.name,
                    onTap: () => Navigator.pop(
                      context,
                      l.name,
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text('Editor mode'),
      subtitle: Text(
        editorMode == null ? 'Off' : capitalize(editorMode!),
      ),
      value: editorMode != null,
      secondary: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Icon(Icons.edit_outlined),
      ),
      onChanged: (e) async {
        final mode = await chooseLanguage();
        setState(() => editorMode = mode);
      },
    );
  }
}
