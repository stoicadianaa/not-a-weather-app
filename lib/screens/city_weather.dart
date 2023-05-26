import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:not_a_weather_app/assets/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:not_a_weather_app/screens/city_weather_bloc.dart';

class CityWeather extends StatelessWidget {
  const CityWeather({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return ChangeNotifierProvider(
      create: (context) => CityWeatherBloc(),
      child: Consumer<CityWeatherBloc>(
        builder: (context, bloc, child) {
          if (bloc.isError) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'There was an error while loading the weather data.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.sourceSansPro(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        bloc.loadLocation();
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.black),
                      ),
                      child: Text(
                        'Try again',
                        style: GoogleFonts.sourceSansPro(
                          color: AppColors.background,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (!bloc.isLoadingDone) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ),
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: Text(
                  bloc.city,
                  style: GoogleFonts.sourceSansPro(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                  ),
                ),
                centerTitle: true,
                backgroundColor: AppColors.background,
                elevation: 0,
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SizedBox(
                  width: double.infinity,
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
                        bloc.condition,
                        style: const TextStyle(fontSize: 20.0),
                      ),
                      FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: width * 0.3),
                          child: Text(
                            '${bloc.maxTemp}°',
                            style: GoogleFonts.sourceSansPro(fontSize: 400.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
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
                                  bloc.wind.round().toString(),
                                  'Wind',
                                ),
                              ),
                              Expanded(
                                child: weatherData(
                                  Icons.water_drop_outlined,
                                  bloc.humidity.round().toString(),
                                  'Humidity',
                                ),
                              ),
                              Expanded(
                                child: weatherData(
                                  Icons.remove_red_eye_outlined,
                                  bloc.precipitations.floor().toString(),
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
                              'https://www.weatherapi.com/weather/q/${bloc.city}',
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
            );
          }
        },
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
