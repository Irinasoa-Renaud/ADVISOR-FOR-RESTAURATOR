import 'package:menu_advisor/models/price.dart';
import 'package:http/http.dart' as http;

import 'api.dart';

class RecommandedPlat {
  int priority;
  String createdAt;
  String updateAt;
  String _id;
  Food food;
  String restaurantId;
  int __v;
  RecommandedPlat(
    this.priority,
    this.createdAt,
    this.updateAt,
    this._id,
    this.food,
    this.restaurantId,
    this.__v,
  );

  factory RecommandedPlat.fromJson(dynamic json) {
    return RecommandedPlat(
        json['priority'],
        json['createdAt'],
        json['updateAt'] ?? "",
        json['_id'] ?? "",
        Food.fromJson(json['food']),
        json['restaurant'] ?? "",
        json['__v'] ?? "");
  }

  // @override
  // String toString() {
  //   // return '{$priority,$createdAt,$updateAt,$_id,$food,$restaurantId,$__v}';
  //   return '{$priority,$createdAt,$updateAt,$_id,$restaurantId,$__v}';
  // }
}

class Food {
  // String _id;
  String name;
  String description;
  Ftype type;
  String restaurant;
  int note;
  String imageURL;
  int priority;
  Price price;
  bool statut;
  bool imageNotContractual;
  bool? isAvailable;
  Food(
      // this._id,
      this.name,
      this.description,
      this.type,
      this.restaurant,
      this.note,
      this.imageURL,
      this.priority,
      this.price,
      this.statut,
      this.imageNotContractual,
      this.isAvailable);

  factory Food.fromJson(dynamic json) {
    return Food(
        // json['_id'] as String,
        json['name'] as String,
        json['description'] as String,
        Ftype.fromJson(json['type']),
        json['restaurant'] as String,
        json['note'] as int,
        json['imageURL'] as String,
        json['priority'] as int,
        Price.fromJson(json['price']),
        json['statut'] as bool,
        json['imageNotContractual'] as bool,
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

// class Food {
//   String _id;
//   Name name;
//   String description;
//   Ftype type;
//   // attributes: Array<FoodAttribute>;
//   // Restaurant? restaurantObject;
//   String restaurant;
//   int note;
//   String imageURL;
//   int priority;
//   Price price;
//   bool statut;
//   // options: {
//   //   String title;
//   //   int maxOptions;
//   //   items: Accompaniment[];
//   //   bool isObligatory?;
//   // }[];
//   bool imageNotContractual;
//   // List<String> allergene;
//   bool? isAvailable;
//   Food(
//       this._id,
//       this.name,
//       this.description,
//       this.type,
//       this.restaurant,
//       this.note,
//       this.imageURL,
//       this.priority,
//       this.price,
//       this.statut,
//       this.imageNotContractual,
//       // this.allergene,
//       this.isAvailable);

//   factory Food.fromJson(dynamic json) {
//     return Food(
//         json['_id'] as String,
//         Name.fromJson(json['name']),
//         json['description'] as String,
//         Ftype.fromJson(json['type']),
//         json['restaurant'] as String,
//         json['note'] as int,
//         json['imageURL'] as String,
//         json['priority'] as int,
//         Price.fromJson(json['price']),
//         json['statut'] as bool,
//         json['imageNotContractual'] as bool,
//         // json['allergene'] as List<String>,
//         json['isAvailable'] as bool);
//   }

//   @override
//   String toString() {
//     // return '{$_id,$name,$description,$type,$restaurant,$note,$imageURL,$priority,$price,$statut,$imageNotContractual,$allergene,$isAvailable}';
//     return '{$name,$description,$type,$restaurant,$note,$imageURL,$priority,$price,$statut,$imageNotContractual,$isAvailable}';
//   }

//   static List<Food> listFromJson(dynamic json) {
//     List<Food> foods = [];
//     for (var i in json) {
//       foods.add(Food.fromJson(i));
//     }
//     return foods;
//   }
// }

class Ftype {
  int priority;
  // "field": [],
  String _id;
  String name;
  String restaurant;
  int v;
  Ftype(this.priority, this._id, this.name, this.restaurant, this.v);

  factory Ftype.fromJson(dynamic json) {
    return json != null
        ? Ftype(json['priority'] ?? 0, json["_id"] ?? "", json["name"] ?? "",
            json["restaurant"] ?? "", json["__v"] ?? 0)
        : Ftype(0, "", "", "", 0);
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
