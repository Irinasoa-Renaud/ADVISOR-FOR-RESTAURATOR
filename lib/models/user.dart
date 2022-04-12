class Name {
  String first;
  String last;
  Name(this.first, this.last);
  factory Name.fromJson(dynamic json) {
    return Name(json['first'] as String, json['last'] as String);
  }
  @override
  String toString() {
    return '{ $first, $last }';
  }
}

class User {
  Name name;
  List<dynamic> favoriteRestaurants;
  // List<String> favoriteFoods;
  // List<String> roles;
  bool validated;
  // List<String> paymentCards;
  String id;
  String email;
  String phoneNumber;
  String createdAt;
  String updatedAt;

  User(
      this.name,
      this.favoriteRestaurants,
      // this.favoriteFoods,
      // this.roles,
      this.validated,
      // this.paymentCards,
      this.id,
      this.email,
      this.phoneNumber,
      this.createdAt,
      this.updatedAt);

  factory User.fromJson(dynamic json) {
    return User(
        Name.fromJson(json['name']),
        json['favoriteRestaurants'],
        // json['favoriteFoods'],
        // json['roles'],
        json['validated'],
        // json['paymentCards'],
        json['_id'],
        json['email'],
        json['phoneNumber'],
        json['createdAt'],
        json['updatedAt']);
  }
  @override
  String toString() {
    // return '{ $name, $favoriteRestaurants,$favoriteFoods,$roles,$validated,$paymentCards,$_id,$email,$phoneNumber,$createdAt,$updatedAt }';
    return '{$name, $favoriteRestaurants,$validated,$id,$email,$phoneNumber,$createdAt,$updatedAt }';
  }
}
