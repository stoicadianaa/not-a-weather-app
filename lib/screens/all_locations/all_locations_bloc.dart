import 'package:flutter/cupertino.dart';
import 'package:localstore/localstore.dart';
import 'package:location/location.dart';
import 'package:not_a_weather_app/model/city_weather_model.dart';
import 'package:not_a_weather_app/api/weather_api_calls.dart';

class AllLocationsBloc extends ChangeNotifier {
  AllLocationsBloc() {
    loadScreen();
  }

  late LocationData locationData;
  final _db = Localstore.instance;

  bool isLoadingDone = false;
  bool isError = false;

  bool showSearchBar = false;
  final String _yesterdayDate =
      DateTime.now().subtract(const Duration(days: 1)).toString().split(' ')[0];

  Map<String, CityWeatherModel> cityWeatherData = {};
  CityWeatherModel? currentCity;

  void loadScreen() async {
    try {
      isError = false;
      isLoadingDone = false;
      notifyListeners();

      await _loadCurrentLocation();
      cityWeatherData.clear();
      _db.collection('favorites').stream.forEach((element) async {
        CityWeatherModel? newCity;
        if (element['latitude'] != null && element['longitude'] != null) {
          newCity =
              await _loadWeather(element['latitude'], element['longitude']);
        } else if (element['city'] != null) {
          newCity = await loadWeatherByCity(element['city']);
        }
        if (newCity != null) {
          cityWeatherData[newCity.city] = newCity;
          notifyListeners();
        }
      });

      isLoadingDone = true;
    } on Exception {
      isError = true;
    }

    notifyListeners();
  }

  _loadCurrentLocation() async {
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

    location.onLocationChanged.listen((LocationData currentLocation) {
      locationData = currentLocation;
      notifyListeners();
    });

    currentCity = await _loadWeather(
      locationData.latitude!,
      locationData.longitude!,
    );

    if (currentCity == null) {
      isError = true;
    }
  }

  Future<CityWeatherModel?> _loadWeather(
    double latitude,
    double longitude,
  ) async {
    try {
      return await WeatherApiCalls.getHistoryWeatherByCoordinates(
        latitude,
        longitude,
        _yesterdayDate,
      );
    } on Exception {
      isError = true;
    }

    isLoadingDone = true;
    notifyListeners();
    return null;
  }

  Future<CityWeatherModel?> loadWeatherByCity(String cityName) async {
    try {
      return await WeatherApiCalls.getHistoryWeatherByCity(
        cityName,
        _yesterdayDate,
      );
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
}
