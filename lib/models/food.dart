import 'package:menu_advisor/models/foodTypes.dart';
import 'package:menu_advisor/models/price.dart';

class Food {
  // String _id;
  String name;
  String description;
  Ftype type;
  List<FoodAttribute> attributs;
  String restaurant;
  int note;
  String imageURL;
  int priority;
  Price price;
  bool statut;
  bool imageNotContractual;
  List<FoodAttribute> allergene;
  bool? isAvailable;
  Food(
      // this._id,
      this.name,
      this.description,
      this.type,
      this.attributs,
      this.restaurant,
      this.note,
      this.imageURL,
      this.priority,
      this.price,
      this.statut,
      this.imageNotContractual,
      this.allergene,
      this.isAvailable);

  factory Food.fromJson(dynamic json) {
    return Food(
        // json['_id'] as String,
        json['name'] as String,
        json['description'] as String,
        Ftype.fromJson(json['type']),
        json['attributes'] == null
            ? []
            : FoodAttribute.list(json['attributes']),
        json['restaurant'] as String,
        json['note'] as int,
        json['imageURL'] as String,
        json['priority'] as int,
        Price.fromJson(json['price']),
        json['statut'] as bool,
        json['imageNotContractual'] as bool,
        json['allergene'] == null ? [] : FoodAttribute.list(json['allergene']),
        json['isAvailable'] as bool);
  }

  @override
  String toString() {
    // return '{$_id,$name,$description,$type,$restaurant,$note,$imageURL,$priority,$price,$statut,$imageNotContractual,$allergene,$isAvailable}';
    return '{$name,$description,$type,$restaurant,$note,$imageURL,$priority,$price,$statut,$imageNotContractual,$isAvailable}';
  }

  static List<Food> listFromJson(dynamic json) {
    List<Food> foods = [];
    for (var i in json) {
      foods.add(Food.fromJson(i));
    }
    return foods;
  }
}

class Ftype {
  int priority;
  // "field": [],
  String _id;
  String name;
  String restaurant;
  int v;
  Ftype(this.priority, this._id, this.name, this.restaurant, this.v);

  factory Ftype.fromJson(dynamic json) {
    return Ftype(json['priority'] ?? 0, json["_id"] ?? "", json["name"] ?? "",
        json["restaurant"] ?? "", json["__v"] ?? 0);
  }
}

class FoodAttribute {
  final String id;
  final FoodTypeName nom;
  final String tag;
  final int v;
  FoodAttribute(this.id, this.nom, this.tag, this.v);

  factory FoodAttribute.fromJson(dynamic json) {
    return FoodAttribute(
        json['_id'] ?? "",
        json['locales'] != null
            ? FoodTypeName.fromJson(json['locales'])
            : FoodTypeName(""),
        json['tag'] ?? "",
        json['__v'] ?? 0);
  }

  static List<FoodAttribute> list(dynamic json) {
    List<FoodAttribute> attrs = [];
    for (var i in json) {
      attrs.add(FoodAttribute.fromJson(i));
    }
    return attrs;
  }
}
