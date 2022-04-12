import 'package:menu_advisor/models/option.dart';
import 'package:menu_advisor/models/price.dart';

class Menu {
  Price price;
  int priority;
  // List<String> field;
  String id;
  // Name name;
  String name;
  String description;
  String type;
  Restaurant restaurant;
  List<Option> options;
  String createdAt;
  String updtedAt;
  int __v;
  // List<Food> foods;
  Menu(
    this.price,
    this.priority,
    // this.field,
    this.id,
    this.name,
    this.description,
    this.type,
    this.restaurant,
    this.options,
    this.createdAt,
    this.updtedAt,
    this.__v,
    // this.foods
  );

  factory Menu.fromJson(dynamic json) {
    return Menu(
      Price.fromJson(json['price']),
      json['priority'] ?? 0,
      // json['field'],
      json['_id'] ?? "",
      // Name.fromJson(json['name']),
      json['name'] ?? "",
      json['description'] ?? "",
      json['type'] ?? "",
      Restaurant.fromJson(json['restaurant']),
      Option.listFromJson(json['options']),
      json['createdAt'] ?? "",
      json['updtedAt'] ?? "",
      json['__v'] ?? 0,
      // Food.listFromJson(json['foods'])
    );
  }

  // @override
  // String toString() {
  //   // return '{ $price,$priority,$field,$_id,$name,$description,$type,$restaurant,$options,$createdAt,$updtedAt,$__v,$foods }';
  //   return '{ $price,$priority,$id,$name,$description,$type,$options,$createdAt,$updtedAt,$__v }';
  // }
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

class Restaurant {
  String id;
  int priority;
  String name;
  String description;
  String distanceMax;
  String address;
  String city;
  String postalCode;
  // User admin;
  String qrcodeLink;
  String qrcodePricelessLink;
  bool delivery;
  bool surPlace;
  bool aEmporter;
  String phoneNumber;
  String fixedLinePhoneNumber;
  Price deliveryPrice;
  int priceByMiles;
  String name_resto_code;
  List<OpeningTime> openingTimes;
  Location location;
  bool status;
  bool referencement;
  bool paiementLivraison;
  bool paiementCB;
  bool cbDirectToAdvisor;
  String logo; //imageURL
  String couvertureMobile;
  String couvertureWeb;

  Restaurant(
      this.id,
      this.priority,
      this.name,
      this.description,
      this.distanceMax,
      this.address,
      this.city,
      this.postalCode,
      // this.admin,
      this.qrcodeLink,
      this.qrcodePricelessLink,
      this.delivery,
      this.surPlace,
      this.aEmporter,
      this.phoneNumber,
      this.fixedLinePhoneNumber,
      this.deliveryPrice,
      this.priceByMiles,
      this.name_resto_code,
      this.openingTimes,
      this.location,
      this.status,
      this.referencement,
      this.paiementLivraison,
      this.paiementCB,
      this.cbDirectToAdvisor,
      this.logo,
      this.couvertureMobile,
      this.couvertureWeb);

  factory Restaurant.fromJson(dynamic json) {
    return Restaurant(
        json['_id'] as String,
        json['priority'] as int,
        json['name'] as String,
        json['description'] as String,
        // FoodType.list(json['foodTypes']),
        json['DistanceMax'] as String,
        json['address'] as String,
        json['city'] as String,
        json['postalCode'] as String,
        // User.fromJson(json['admin']),
        json['qrcodeLink'] as String,
        json['qrcodePricelessLink'] as String,
        json['delivery'] as bool,
        json['surPlace'] as bool,
        json['aEmporter'] as bool,
        json['phoneNumber'] as String,
        json['fixedLinePhoneNumber'] as String,
        Price.fromJson(json['deliveryPrice']),
        json['priceByMiles'] as int,
        json['name_resto_code'] as String,
        OpeningTime.list(json['openingTimes']),
        Location.fromJson(json['location']),
        json['status'] as bool,
        json['referencement'] as bool,
        json['paiementLivraison'] as bool,
        json['paiementCB'] as bool,
        json['cbDirectToAdvisor'] as bool,
        json['logo'] as String,
        json['couvertureMobile'] as String,
        json['couvertureWeb'] as String);
  }
}

// Nom,type(prix par plat,prix fixe,titre(plat)) //modif menu

class OpeningTime {
  String _id;
  String day;
  List<Opening> openings;
  OpeningTime(this._id, this.day, this.openings);

  factory OpeningTime.fromJson(dynamic json) {
    return OpeningTime(
        json['_id'], json['day'], Opening.list(json['openings']));
  }

  @override
  String toString() {
    return '{$day,$openings}';
  }

  static List<OpeningTime> list(dynamic json) {
    List<OpeningTime> opens = [];
    for (var i in json) {
      opens.add(OpeningTime.fromJson(i));
    }
    return opens;
  }
}

class Opening {
  int beginHour;
  int beginMinute;
  int endHour;
  int endMinute;

  Opening(this.beginHour, this.beginMinute, this.endHour, this.endMinute);

  factory Opening.fromJson(dynamic json) {
    return Opening(json['begin']['hour'], json['begin']['minute'],
        json['end']['hour'], json['end']['minute']);
  }

  @override
  String toString() {
    return '{$beginHour,$beginMinute,$endHour,$endMinute}';
  }

  static List<Opening> list(dynamic json) {
    List<Opening> opens = [];
    for (var i in json) {
      opens.add(Opening.fromJson(i));
    }
    return opens;
  }
}

class Location {
  String type;
  // List<double> coordinates;
  List<dynamic> coordinates;
  Location(this.type, this.coordinates);

  factory Location.fromJson(dynamic json) {
    return Location(json['type'], json['coordinates']);
  }

  @override
  String toString() {
    return '{$type,$coordinates}';
  }
}
