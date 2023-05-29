class CityWeatherData {
  CityWeatherData({
    required this.city,
    required this.maxTemp,
    required this.condition,
    required this.wind,
    required this.humidity,
    required this.precipitations,
    required this.latitude,
    required this.longitude,
  });

  String city;
  int maxTemp;
  String condition;
  double wind;
  double humidity;
  double precipitations;
  double latitude;
  double longitude;
}
