class Sample {
  String text;
  String? translation;

  Sample(
    this.text, {
    this.translation,
  });

  Sample.fromJson(Map<String, dynamic> json)
      : this(
          json['plain'] as String,
          translation: json['translation'] as String?,
        );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['plain'] = text;
    if (translation?.isNotEmpty ?? false) data['translation'] = translation;
    return data;
  }
}