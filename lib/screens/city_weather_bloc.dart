import 'dart:convert';
import 'package:location/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class CityWeatherBloc extends ChangeNotifier {
  CityWeatherBloc() {
    notifyListeners();
    loadLocation();
  }

  final String _apiKey = 'da3dfef509c14bfdb3395425232605';
  bool isLoadingDone = false;
  bool isError = false;
  int maxTemp = 0;
  String condition = '';
  double wind = 0;
  double humidity = 0;
  double precipitations = 0;
  String city = '';

  loadLocation() async {
    isError = false;
    isLoadingDone = false;
    notifyListeners();

    LocationData locationData;
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
    location.onLocationChanged.listen((LocationData currentLocation) {
      locationData = currentLocation;
      isLoadingDone = false;
      _loadWeather(locationData);
    });

    _loadWeather(locationData);
  }

  _loadWeather(LocationData locationData) async {
    String yesterdayDate = DateTime.now()
        .subtract(const Duration(days: 1))
        .toString()
        .split(' ')[0];

    try {
      var response = await http.get(
        Uri.parse(
          'http://api.weatherapi.com/v1/history.json?key=$_apiKey&q=${locationData.latitude},${locationData.longitude}&dt=$yesterdayDate',
        ),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var weatherData = data['forecast']['forecastday'][0]['day'];
        maxTemp = weatherData['maxtemp_c'].round();
        condition = weatherData['condition']['text'];
        wind = weatherData['maxwind_kph'];
        humidity = weatherData['avghumidity'];
        precipitations = weatherData['totalprecip_mm'];
        city = data['location']['name'];
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } on Exception {
      isError = true;
    }

    isLoadingDone = true;
    notifyListeners();
  }
}
