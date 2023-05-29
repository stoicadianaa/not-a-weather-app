import 'package:flutter/cupertino.dart';
import 'package:localstore/localstore.dart';

class CityWeatherBloc extends ChangeNotifier {
  CityWeatherBloc(String city) {
    _cityName = city;
    loadScreen();
    notifyListeners();
  }

  bool isFavorite = false;
  final CollectionRef _favoriteCities =
      Localstore.instance.collection('favorites');
  String _cityName = '';

  toggleFavorite() async {
    if (!isFavorite) {
      await _favoriteCities.doc(_cityName).set({'city': _cityName});
    } else {
      await _favoriteCities.doc(capitalize(_cityName)).delete();
    }
    isFavorite = !isFavorite;
    notifyListeners();
  }

  loadScreen() async {
    await _favoriteCities.doc(capitalize(_cityName)).get().then((value) {
      if (value != null) {
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
