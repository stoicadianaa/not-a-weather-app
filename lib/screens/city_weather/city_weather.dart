import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:not_a_weather_app/model/city_weather_model.dart';
import 'package:not_a_weather_app/assets/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:not_a_weather_app/screens/city_weather/city_weather_bloc.dart';

class CityWeather extends StatelessWidget {
  const CityWeather(this._cityData, {super.key});

  final CityWeatherModel _cityData;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return ChangeNotifierProvider(
      create: (context) => CityWeatherBloc(_cityData.city),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            _cityData.city,
            style: GoogleFonts.sourceSansPro(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.background,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_outlined,
              color: Colors.black,
            ),
          ),
          actions: [
            Consumer<CityWeatherBloc>(
              builder: (context, bloc, child) {
                return IconButton(
                  onPressed: () {
                    bloc.toggleFavorite();
                  },
                  icon: Icon(
                    bloc.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border_outlined,
                    color: Colors.black,
                  ),
                );
              },
            )
          ],
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 16,
                ),
                Container(
                  height: 30,
                  width: width * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    "Yesterday's weather",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sourceSansPro(
                      fontSize: 20.0,
                      color: AppColors.background,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  _cityData.condition,
                  style: const TextStyle(fontSize: 20.0),
                ),
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.3),
                    child: Text(
                      '${_cityData.maxTemp}°',
                      style: GoogleFonts.sourceSansPro(fontSize: 400.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: weatherData(
                            Icons.waves_outlined,
                            '${_cityData.wind.round().toString()}km/h',
                            'Wind',
                          ),
                        ),
                        Expanded(
                          child: weatherData(
                            Icons.water_drop_outlined,
                            '${_cityData.humidity.round().toString()}%',
                            'Humidity',
                          ),
                        ),
                        Expanded(
                          child: weatherData(
                            Icons.remove_red_eye_outlined,
                            '${_cityData.precipitations.floor().toString()}km',
                            'Visibility',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                MaterialButton(
                  onPressed: () {
                    launchUrl(
                      Uri.parse(
                        'https://www.weatherapi.com/weather/q/${_cityData.city}',
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'open today\'s weather',
                        style: GoogleFonts.sourceSansPro(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_outlined,
                        size: 32.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget weatherData(IconData iconData, String data, String info) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 24.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(
          iconData,
          color: AppColors.background,
          size: 36.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              data,
              style: const TextStyle(
                color: AppColors.background,
                fontSize: 24.0,
              ),
            ),
            Text(
              info,
              style: const TextStyle(
                color: AppColors.background,
                fontSize: 16.0,
              ),
            ),
          ],
        )
      ],
    ),
  );
}
