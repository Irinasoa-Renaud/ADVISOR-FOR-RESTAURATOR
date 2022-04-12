import 'package:menu_advisor/models/price.dart';

class FoodType {
  int priority;
  // "field": [],
  String id;
  FoodTypeName name;
  Restaurant restaurant;
  // String restoName;
  int v;
  FoodType(
      this.priority,
      this.id,
      this.name,
      this.restaurant,
      // this.restoName,
      this.v);

  factory FoodType.fromJson(dynamic json) {
    return FoodType(
        json['priority'] ?? 0,
        json["_id"] ?? "",
        FoodTypeName.fromJson(json["name"]),
        json["restaurant"] != null
            ? Restaurant.fromJson(json["restaurant"])
            : Restaurant.vide(),
        // json["restaurant"]["name"] ?? "",
        json["__v"]);
  }

  @override
  String toString() {
    // return "{$priority,$_id,$name,$restaurant,$v}";
    return "{$priority,$id,$name,$v}";
  }

  static List<FoodType> list(dynamic json) {
    List<FoodType> foodTypes = [];
    for (var i in json) {
      foodTypes.add(FoodType.fromJson(i));
    }
    return foodTypes;
  }
}

class FoodTypeName {
  String fr;
  FoodTypeName(this.fr);

  factory FoodTypeName.fromJson(dynamic json) {
    return FoodTypeName(json['fr']);
  }
  @override
  String toString() {
    return '{ $fr }';
  }
}

/*--------*/
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
        json['_id'] ?? "",
        json['priority'] ?? 0,
        json['name'] ?? "",
        json['description'] ?? "",
        // FoodType.list(json['foodTypes']),
        json['DistanceMax'] ?? "",
        json['address'] ?? "",
        json['city'] ?? "",
        json['postalCode'] ?? "",
        // User.fromJson(json['admin']),
        json['qrcodeLink'] ?? "",
        json['qrcodePricelessLink'] ?? "",
        json['delivery'] ?? false,
        json['surPlace'] ?? false,
        json['aEmporter'] ?? false,
        json['phoneNumber'] ?? "",
        json['fixedLinePhoneNumber'] ?? "",
        Price.fromJson(json['deliveryPrice']),
        json['priceByMiles'] ?? 0,
        json['name_resto_code'] ?? "",
        OpeningTime.list(json['openingTimes']),
        Location.fromJson(json['location']),
        json['status'] ?? false,
        json['referencement'] ?? false,
        json['paiementLivraison'] ?? false,
        json['paiementCB'] ?? false,
        json['cbDirectToAdvisor'] ?? false,
        json['logo'] ?? "",
        json['couvertureMobile'] ?? "",
        json['couvertureWeb'] ?? "");
  }
  factory Restaurant.vide() {
    return Restaurant(
        "",
        0,
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        false,
        false,
        false,
        "",
        "",
        Price(0, "eur"),
        0,
        "",
        [
          OpeningTime("", "", [Opening(0, 0, 0, 0)])
        ],
        Location("", [0.0, 0.0]),
        false,
        false,
        false,
        false,
        false,
        "",
        "",
        "");
  }
}

class OpeningTime {
  String _id;
  String day;
  List<Opening> openings;
  OpeningTime(this._id, this.day, this.openings);

  factory OpeningTime.fromJson(dynamic json) {
    return OpeningTime(
        json['_id'] ?? "", json['day'] ?? "", Opening.list(json['openings']));
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
    return Opening(json['begin']['hour'] ?? 0, json['begin']['minute'] ?? 0,
        json['end']['hour'] ?? 0, json['end']['minute'] ?? 0);
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
    return Location(json['type'] ?? "", json['coordinates']);
  }

  @override
  String toString() {
    return '{$type,$coordinates}';
  }
}

class Livraison {
  List<dynamic> freeCP;
  List<dynamic> freeCity;
  Livraison(this.freeCP, this.freeCity);

  factory Livraison.fromJson(dynamic json) {
    return Livraison(json['freeCP'], json['freeCity']);
  }

  @override
  String toString() {
    return '{$freeCP,$freeCity}';
  }
}

class DynamicToString {
  static list<String>(List<dynamic> json) {
    List<String> strings = [];
    strings = json.map<String>((e) {
      return e;
    }).toList();
    return strings;
  }
}
