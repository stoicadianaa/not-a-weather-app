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
  List<CityWeatherData> cityWeatherData = [
    CityWeatherData(
      maxTemp: 0,
      condition: 'Clear',
      city: 'London',
      latitude: 51.5085,
      longitude: -0.1257,
      wind: 0,
      humidity: 0,
      precipitations: 0,
    ),
    CityWeatherData(
      maxTemp: 0,
      condition: 'Clear',
      city: 'Paris',
      latitude: 48.8534,
      longitude: 2.3488,
      wind: 0,
      humidity: 0,
      precipitations: 0,
    ),
    CityWeatherData(
      maxTemp: 0,
      condition: 'Clear',
      city: 'New York',
      latitude: 40.7128,
      longitude: -74.006,
      wind: 0,
      humidity: 0,
      precipitations: 0,
    ),
  ];
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

    // location.onLocationChanged.listen((LocationData currentLocation) {
    //   locationData = currentLocation;
    //   notifyListeners();
    // });
  }

  loadScreen() async {
    db.collection("favorites").doc('Bucharest').set({
      'latitude': 51.5085,
      'longitude': -0.1257,
    });
    await loadCurrentLocation();
    db.collection('favorites').stream.forEach((element) async {
      print(element);
      CityWeatherData? newCity =
          await _loadWeather(element["latitude"], element["longitude"]);
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
}
