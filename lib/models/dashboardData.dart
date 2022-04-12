class DashboardData {
  int day;
  int week;
  int month;
  int year;
  int affaireDay;
  int affaireWeek;
  int affaireMonth;
  int affaireYear;
  DashboardData(this.day, this.week, this.month, this.year, this.affaireDay,
      this.affaireWeek, this.affaireMonth, this.affaireYear);

  factory DashboardData.vide() {
    return DashboardData(0, 0, 0, 0, 0, 0, 0, 0);
  }

  factory DashboardData.fromJson(dynamic json) {
    return DashboardData(
        json["dashboard_day"],
        json["dashboard_week"],
        json["dashboard_month"],
        json["dashboard_year"],
        json["chiffre_affaire_day"],
        json["chiffre_affaire_week"],
        json["chiffre_affaire_month"],
        json["chiffre_affaire_year"]);
  }
  @override
  String toString() {
    return '{$day,$week,$month,$year,$affaireDay,$affaireWeek,$affaireMonth,$affaireYear}';
  }
}
