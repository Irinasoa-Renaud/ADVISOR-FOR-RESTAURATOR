import 'package:menu_advisor/models/price.dart';
import 'package:menu_advisor/models/restaurant.dart';

class Accompagnement {
  Price price;
  bool isObligatory;
  int priority;
  String fields;
  String id;
  // Restaurant restaurant;
  String name;
  String imageURL;
  int __v;
  Accompagnement(
    this.price,
    this.isObligatory,
    this.priority,
    this.fields,
    this.id,
    // this.restaurant,
    this.name,
    this.imageURL,
    this.__v,
  );

  factory Accompagnement.fromJson(dynamic json) {
    return Accompagnement(
      Price.fromJson(json['price']),
      json['isObligatory'],
      json['priority'] ?? 0,
      json['fields'] ?? "",
      json['_id'] ?? "",
      // Restaurant.fromJson(json['restaurant']),
      json['name'] ?? "",
      json['imageURL'] ?? "",
      json['__v'] ?? 0,
    );
  }

  @override
  String toString() {
    // return '{$price,$isObligatory,$priority,$fields,$id,$restaurant,$name,$imageURL,$__v}';
    return '{$price,$isObligatory,$priority,$id,$name,$imageURL,$__v}';
  }
}

class Name {
  String fr;
  Name(this.fr);

  factory Name.fromJson(dynamic json) {
    return Name(json['fr']);
  }
  @override
  String toString() {
    return '{ $fr }';
  }
}
