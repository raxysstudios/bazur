import 'package:avzag/home/models.dart';
import 'package:avzag/store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'language_flag.dart';

List<Language> languages = [];
Set<String> selected = Set();

ModuleLoader homeLoader = ModuleLoader((langs) async {
  languages.clear();
  await FirebaseFirestore.instance
      .collection('languages')
      .orderBy('family')
      .orderBy('name')
      .withConverter(
        fromFirestore: (snapshot, _) => Language.fromJson(snapshot.data()!),
        toFirestore: (Language language, _) => language.toJson(),
      )
      .get()
      .then((d) async {
    languages = d.docs.map((l) => l.data()).toList();
    for (final l in languages) await donwloadFlag(l);
  });
  selected
    ..clear()
    ..addAll(langs);
});
