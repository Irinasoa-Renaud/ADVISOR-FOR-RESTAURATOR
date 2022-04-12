import 'package:flutter/material.dart';
import 'package:menu_advisor/models/category.dart';
import 'package:menu_advisor/models/foodTypes.dart';
import 'package:menu_advisor/models/price.dart';
import 'package:menu_advisor/models/user.dart';

class Restaurant {
  String id;
  int priority;
  List<FoodCategory> category;
  String name;
  String description;
  // List<FoodType> foodType;
  String distanceMax;
  // String imageURL;
  String discountType;
  // String type;
  String address;
  String city;
  String postalCode;
  // List<String> foods;
  // List<String> menus;
  User admin;
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
  // Livraison livraison;
  bool paiementCB;
  // String? customerStripeKey;
  // String? customerSectretStripeKey;
  bool cbDirectToAdvisor;
  bool isMenuActive;
  bool isBoissonActive;
  // bool discount;//
  String logo; //imageURL
  String couvertureMobile;
  String couvertureWeb;
  bool deliveryFixed;
  // String? minPriceIsDelivery;
  // bool discountIsPrice; //
  bool hasCodePromo;
  bool discountAEmporter;
  bool discountDelivery;

  Restaurant(
      this.id,
      this.priority,
      this.category,
      this.name,
      this.description,
      // this.foodType,
      this.distanceMax,
      // this.imageURL,
      this.discountType,
      // this.type,
      this.address,
      this.city,
      this.postalCode,
      // this.foods,
      // this.menus,
      this.admin,
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
      // this.livraison,
      this.paiementCB,
      // this.customerStripeKey,
      // this.customerSectretStripeKey,
      this.cbDirectToAdvisor,
      this.isMenuActive,
      this.isBoissonActive,
      // this.discount, //
      this.logo,
      this.couvertureMobile,
      this.couvertureWeb,
      this.deliveryFixed,
      // this.minPriceIsDelivery,
      // this.discountIsPrice,
      this.hasCodePromo,
      this.discountAEmporter,
      this.discountDelivery);

  factory Restaurant.fromJson(dynamic json) {
    return Restaurant(
        json['_id'] as String,
        json['priority'] as int,
        FoodCategory.list(json['category']),
        json['name'] as String,
        json['description'] ?? "",
        // FoodType.list(json['foodTypes']),
        json['DistanceMax'] ?? "",
        // json['imageURL'] as String,
        json['discount']['delivery']['discountType'] ?? "",
        // json['type'] as String,
        json['address'] as String,
        json['city'] as String,
        json['postalCode'] ?? "",
        // DynamicToString.list(json['foods']),
        // json['menus'],
        User.fromJson(json['admin']),
        json['qrcodeLink'] ?? "",
        json['qrcodePricelessLink'] ?? "",
        json['delivery'] as bool,
        json['surPlace'] as bool,
        json['aEmporter'] as bool,
        json['phoneNumber'] ?? "",
        json['fixedLinePhoneNumber'] ?? "",
        json['deliveryPrice'] != null
            ? Price.fromJson(json['deliveryPrice'])
            : Price.vide(),
        json['priceByMiles'] ?? 0,
        json['name_resto_code'] ?? "",
        OpeningTime.list(json['openingTimes']),
        Location.fromJson(json['location']),
        json['status'] as bool,
        json['referencement'] as bool,
        json['paiementLivraison'] as bool,
        // Livraison.fromJson(json['livraison']),
        json['paiementCB'] as bool,
        // json['customerStripeKey'] as String,
        // json['customerSectretStripeKey'] as String,
        json['cbDirectToAdvisor'] as bool,
        json['isMenuActive'] as bool,
        json['isBoissonActive'] as bool,
        // json['discount'], //
        json['logo'] ?? "",
        json['couvertureMobile'] ?? "",
        json['couvertureWeb'] ?? "",
        json['deliveryFixed'] as bool,
        // json['minPriceIsDelivery'],
        // json['discountIsPrice'],
        json['hasCodePromo'] as bool,
        json['discountAEmporter'] as bool,
        json['discountDelivery'] as bool);
  }

  @override
  String toString() {
    return '{$id,$priority,$category,$name,$description,$distanceMax,$discountType,$address,$city,$postalCode,$admin,$qrcodeLink,$qrcodePricelessLink,$delivery,$surPlace,$aEmporter,$phoneNumber,$fixedLinePhoneNumber,$deliveryPrice,$priceByMiles,$name_resto_code,$openingTimes,$location,$status,$referencement,$paiementLivraison,$paiementCB,$cbDirectToAdvisor,$isMenuActive,$isBoissonActive,$logo,$couvertureMobile,$couvertureWeb,$deliveryFixed,$hasCodePromo,$discountAEmporter,$discountDelivery}';
  }
}

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
