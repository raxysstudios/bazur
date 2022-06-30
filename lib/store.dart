import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/language.dart';
import 'shared/utils.dart';

late final Algolia algolia;
late final SharedPreferences prefs;

class EditorStore {
  static List<String> adminable = [];

  static String? _language;
  static String? get language => _language;
  static set language(String? value) {
    _language = value;
    if (value == null) {
      prefs.remove('editorLanguage');
    } else {
      prefs.setString('editorLanguage', value);
    }
  }

  static User? get user => FirebaseAuth.instance.currentUser;
  static bool get editor => user != null && language != null;
  static bool get admin => editor && adminable.contains(language);

  static Future<List<String>> getAdminable() async {
    final token = await user?.getIdTokenResult(true);
    return json2list(token?.claims?['admin']) ?? [];
  }

  static void _check(User? user) async {
    if (user == null) {
      adminable.clear();
      language = null;
      return;
    }
    adminable = await getAdminable();
  }

  static Future<void> init() async {
    _language = prefs.getString('editorLanguage');
    adminable = await getAdminable();
    FirebaseAuth.instance.userChanges().listen(_check);
  }
}

class GlobalStore {
  static Map<String, Language?> languages = {};

  static void set({
    Iterable<String>? names,
    Iterable<Language>? objects,
  }) {
    if (objects != null) {
      languages = {for (final l in objects) l.name: l};
    } else if (names != null) {
      languages = {for (final l in names) l: null};
    }
    if (!languages.containsKey(EditorStore.language)) {
      EditorStore.language = null;
    }
    prefs.setStringList('languages', languages.keys.toList());
  }

  static void init([List<String>? names]) {
    set(
      names: names ?? prefs.getStringList('languages') ?? ['aghul'],
    );
    for (final l in languages.keys) {
      FirebaseFirestore.instance
          .doc('languages/$l')
          .withConverter(
            fromFirestore: (snapshot, _) => Language.fromJson(snapshot.data()!),
            toFirestore: (_, __) => {},
          )
          .get()
          .then((r) {
        final l = r.data();
        if (l != null) languages[l.name] = l;
      });
    }
  }
}
