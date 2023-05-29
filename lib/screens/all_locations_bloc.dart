import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:localstore/localstore.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:not_a_weather_app/CityWeatherData.dart';

class AllLocationsBloc extends ChangeNotifier {
  AllLocationsBloc() {
    loadScreen();
    notifyListeners();
  }

  bool isLoadingDone = false;
  bool isError = false;
  late LocationData locationData;
  final String _apiKey = 'da3dfef509c14bfdb3395425232605';
  final db = Localstore.instance;
  bool showSearchBar = false;

  List<CityWeatherData> cityWeatherData = [];
  CityWeatherData? currentCity;

  loadCurrentLocation() async {
    isError = false;
    isLoadingDone = false;
    notifyListeners();

    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();

    currentCity = await _loadWeather(
      locationData.latitude!,
      locationData.longitude!,
    );

    if (currentCity == null) {
      isError = true;
    }
  }

  loadScreen() async {
    isLoadingDone = false;
    await loadCurrentLocation();
    // db.collection('favorites').delete();
    cityWeatherData.clear();
    db.collection('favorites').stream.forEach((element) async {
      CityWeatherData? newCity;
      if (element["latitude"] != null && element["longitude"] != null) {
        newCity = await _loadWeather(element["latitude"], element["longitude"]);
      } else if (element["city"] != null) {
        newCity = await loadWeatherByCity(element["city"]);
      }
      if (newCity != null) {
        cityWeatherData.add(newCity);
        notifyListeners();
      }
    });
    isLoadingDone = true;
    notifyListeners();
  }

  Future<CityWeatherData?> _loadWeather(
      double latitude, double longitude) async {
    String yesterdayDate = DateTime.now()
        .subtract(const Duration(days: 1))
        .toString()
        .split(' ')[0];

    try {
      var response = await http.get(
        Uri.parse(
          'http://api.weatherapi.com/v1/history.json?key=$_apiKey&q=$latitude,$longitude&dt=$yesterdayDate',
        ),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var weatherData = data['forecast']['forecastday'][0]['day'];
        var maxTemp = weatherData['maxtemp_c'].round();
        var condition = weatherData['condition']['text'];
        var currentCity = data['location']['name'];
        var wind = weatherData['maxwind_kph'];
        var humidity = weatherData['avghumidity'];
        var precipitations = weatherData['totalprecip_mm'];

        return CityWeatherData(
          maxTemp: maxTemp,
          condition: condition,
          city: currentCity,
          latitude: latitude,
          longitude: longitude,
          wind: wind,
          humidity: humidity,
          precipitations: precipitations,
        );
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } on Exception {
      isError = true;
    }

    isLoadingDone = true;
    notifyListeners();
    return null;
  }

  Future<CityWeatherData?> loadWeatherByCity(String cityName) async {
    String yesterdayDate = DateTime.now()
        .subtract(const Duration(days: 1))
        .toString()
        .split(' ')[0];

    try {
      var response = await http.get(
        Uri.parse(
          'http://api.weatherapi.com/v1/history.json?key=$_apiKey&q=${cityName.toUpperCase()}&dt=$yesterdayDate',
        ),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var weatherData = data['forecast']['forecastday'][0]['day'];
        var maxTemp = weatherData['maxtemp_c'].round();
        var condition = weatherData['condition']['text'];
        var wind = weatherData['maxwind_kph'];
        var humidity = weatherData['avghumidity'];
        var precipitations = weatherData['totalprecip_mm'];
        var latitude = data['location']['lat'];
        var longitude = data['location']['lon'];

        return CityWeatherData(
          maxTemp: maxTemp,
          condition: condition,
          city: capitalize(cityName),
          latitude: latitude,
          longitude: longitude,
          wind: wind,
          humidity: humidity,
          precipitations: precipitations,
        );
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } on Exception {
      isError = true;
    }

    isLoadingDone = true;
    notifyListeners();
    return null;
  }

  toggleSearchBar() {
    showSearchBar = !showSearchBar;
    notifyListeners();
  }

  String capitalize(String input) {
    List<String> words = input.split(' ');
    List<String> capitalizedWords = [];

    for (String word in words) {
      if (word.isNotEmpty) {
        String capitalizedWord = '${word[0].toUpperCase()}${word.substring(1)}';
        capitalizedWords.add(capitalizedWord);
      }
    }

    return capitalizedWords.join(' ');
  }
}
