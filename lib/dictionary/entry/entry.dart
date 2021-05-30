import 'package:avzag/dictionary/sample/sample.dart';
import 'package:avzag/dictionary/use/use.dart';
import 'package:avzag/utils.dart';

class Entry {
  List<Sample> forms;
  List<Use>? uses;
  List<String>? tags;
  String? note;

  Entry({required this.forms, this.uses, this.tags, this.note});

  Entry.fromJson(Map<String, dynamic> json)
      : this(
          forms: listFromJson(json['forms'], (j) => Sample.fromJson(j))!,
          uses: listFromJson(json['uses'], (j) => Use.fromJson(j)),
          tags: json2list(json['tags']),
          note: json['note'],
        );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['forms'] = this.forms.map((v) => v.toJson()).toList();
    if (uses != null) data['uses'] = this.uses!.map((v) => v.toJson()).toList();
    if (tags != null) data['tags'] = tags;
    if (note?.isNotEmpty ?? false) data['note'] = note;
    return data;
  }
}