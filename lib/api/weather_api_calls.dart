import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:not_a_weather_app/model/city_weather_model.dart';

class WeatherApiCalls {
  static const String _apiKey = 'da3dfef509c14bfdb3395425232605';
  static const String _baseUrl = 'http://api.weatherapi.com/v1';

  static Future<CityWeatherModel?> getHistoryWeatherByCoordinates(
      double latitude, double longitude, String date,) async {
    var response = await http.get(
      Uri.parse(
        '$_baseUrl/history.json?key=$_apiKey&q=$latitude,$longitude&dt=$date',
      ),
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      String currentCity = data['location']['name'];
      double latitude = data['location']['lat'];
      double longitude = data['location']['lon'];

      var weatherData = data['forecast']['forecastday'][0]['day'];
      int maxTemp = weatherData['maxtemp_c'].round();
      String condition = weatherData['condition']['text'];
      double wind = weatherData['maxwind_kph'];
      double humidity = weatherData['avghumidity'];
      double precipitations = weatherData['totalprecip_mm'];

      return CityWeatherModel(
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
    return null;
  }

  static Future<CityWeatherModel?> getHistoryWeatherByCity(String cityName, String date) async {
    var response = await http.get(
      Uri.parse(
        '$_baseUrl/history.json?key=$_apiKey&q=${cityName.toUpperCase()}&dt=$date',
      ),
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      String currentCity = data['location']['name'];
      double latitude = data['location']['lat'];
      double longitude = data['location']['lon'];

      var weatherData = data['forecast']['forecastday'][0]['day'];
      int maxTemp = weatherData['maxtemp_c'].round();
      String condition = weatherData['condition']['text'];
      double wind = weatherData['maxwind_kph'];
      double humidity = weatherData['avghumidity'];
      double precipitations = weatherData['totalprecip_mm'];

      return CityWeatherModel(
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
    return null;
  }
}
