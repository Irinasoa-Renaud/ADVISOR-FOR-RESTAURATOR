class Option {
  // List<Item> items;
  String _id;
  String title;
  int maxOptions;
  bool isObligatory;
  Option(this._id, this.title, this.maxOptions, this.isObligatory);

  factory Option.fromJson(dynamic json) {
    return Option(json['_id'] ?? "", json['title'] ?? "",
        json['maxOptions'] ?? 0, json['isObligatory'] ?? false);
  }

  @override
  String toString() {
    return '{$_id,$title,$maxOptions,$isObligatory}';
  }

  static List<Option> listFromJson(dynamic json) {
    List<Option> options = [];
    for (var i in json) {
      options.add(Option.fromJson(i));
    }
    return options;
  }
}
