import 'package:flutter/cupertino.dart';
import 'package:localstore/localstore.dart';

class CityWeatherBloc extends ChangeNotifier {
  bool isFavorite = false;
  final db = Localstore.instance;
  String cityName = '';

  CityWeatherBloc(String city) {
    cityName = city;
    loadScreen();
    notifyListeners();
  }

  toggleFavorite() async {
    if (!isFavorite) {
      await db.collection("favorites").doc(cityName).set({"city": cityName});
    } else {
      await db.collection("favorites").doc(capitalize(cityName)).delete();
    }
    isFavorite = !isFavorite;
    notifyListeners();
  }

  loadScreen() async {
    await db.collection("favorites").doc(capitalize(cityName)).get().then((value) {
      if (value != null) {
        print("in favorites");
        isFavorite = true;
        notifyListeners();
      }
    });
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
