import 'package:flutter/cupertino.dart';
import 'package:menu_advisor/models/api.dart';

class FoodCategory {
  int priority;
  String id;
  // FoodCategoryName name;
  String? imageURL;
  // int _v;
  FoodCategory(
    this.priority,
    this.id,
    // this.name,
    this.imageURL,
    // this._v
  );

  factory FoodCategory.fromJson(dynamic json) {
    return FoodCategory(
      json['priority'],
      json['_id'],
      // FoodCategoryName.fromJson(json['name']),
      json['imageURL'],
      // json['_v']
    );
  }

  @override
  String toString() {
    // return '{ $priority,$_id,$name,$imageURL,$_v}';
    return '{ $priority,$id,$imageURL}';
  }

  static List<FoodCategory> list(dynamic json) {
    List<FoodCategory> categories = [];
    for (var i in json) {
      categories.add(FoodCategory.fromJson(i));
    }
    return categories;
  }

  // Future<Type> getFoodCategory()async{
  //    var url = Uri.parse(Api.Type);
  //           try {
  //             // debugPrint("$logTrace $url");
  //             var response = await http.get(url, headers: {
  //               'Content-Type': 'application/json',
  //               'Accept': 'application/json',
  //               'Authorization': 'Bearer $aToken',
  //             });
  //             var jsonData = json.decode(response.body);
  //             List<Type> categories = [];
  //             for (var i in jsonData) {
  //               debugPrint("$logTrace ${i['_id'].toString()}");
  //               // Type Type = Type.fromJson(i);
  //               Type Type = Type(
  //                 i['priority'],
  //                 i['_id'],
  //                 // FoodCategoryName.fromJson(i['name'].toString()),
  //                 i['imageURL'],
  //                 // i['_v']
  //               );
  //               categories.add(Type);
  //               debugPrint("$logTrace $categories");
  //             }
  //             // debugPrint("$logTrace ${categories[1].imageURL}");
  //           } catch (e) {
  //             debugPrint("$logTrace resp error $e");
  //           }
  // }
}

class FoodCategoryName {
  String fr;
  FoodCategoryName(this.fr);

  factory FoodCategoryName.fromJson(dynamic json) {
    return FoodCategoryName(json['fr']);
  }
  @override
  String toString() {
    return '{ $fr }';
  }
}
