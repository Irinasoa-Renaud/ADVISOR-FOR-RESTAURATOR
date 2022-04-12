class Price {
  int amount;
  String currency;
  Price(this.amount, this.currency);

  factory Price.fromJson(dynamic json) {
    return Price(json['amount'] ?? 0, json['currency'] ?? "eur");
  }

  factory Price.vide() {
    return Price(0, "eur");
  }

  @override
  String toString() {
    return '{$amount,$currency}';
  }
}
