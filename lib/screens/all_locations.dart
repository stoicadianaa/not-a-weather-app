import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:not_a_weather_app/assets/app_colors.dart';
import 'package:not_a_weather_app/screens/all_locations_bloc.dart';
import 'package:not_a_weather_app/screens/city_weather.dart';
import 'package:not_a_weather_app/screens/weather_widget.dart';
import 'package:provider/provider.dart';
import 'package:not_a_weather_app/CityWeatherData.dart';

class AllLocations extends StatelessWidget {
  const AllLocations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return ChangeNotifierProvider(
      create: (context) => AllLocationsBloc(),
      child: Consumer<AllLocationsBloc>(
        builder: (context, bloc, child) {
          if (bloc.isError) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: Padding(
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
                          bloc.loadCurrentLocation();
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
                  'Yesterday\'s weather',
                  style: GoogleFonts.sourceSansPro(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                  ),
                ),
                // centerTitle: true,
                backgroundColor: AppColors.background,
                elevation: 0,
                actions: [
                  IconButton(
                    onPressed: () {
                      bloc.toggleSearchBar();
                    },
                    icon: const Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  await bloc.loadScreen();
                },
                child: SizedBox(
                  height: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top,
                  child: ListView(
                    children: [
                      Visibility(
                        visible: bloc.showSearchBar,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) => {},
                            onSubmitted: (value) async {
                              var citydata = await bloc.loadWeatherByCity(value);

                              if (citydata == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Couldn't find the city you were looking for.",
                                    ),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CityWeather(citydata),
                                ),
                              );
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              labelText: 'Search cities',
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your location',
                                style: GoogleFonts.sourceSansPro(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.0,
                                ),
                              ),
                              MaterialButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CityWeather(bloc.currentCity!),
                                    ),
                                  );
                                },
                                child: WeatherWidget(
                                  city: bloc.currentCity!.city,
                                  maxTemp: bloc.currentCity!.maxTemp,
                                  condition: bloc.currentCity!.condition,
                                ),
                              ),
                              Text(
                                'Saved locations',
                                style: GoogleFonts.sourceSansPro(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.0,
                                ),
                              ),
                              SizedBox(
                                height: bloc.cityWeatherData.length * 200,
                                child: ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    CityWeatherData favoritedCity =
                                        bloc.cityWeatherData.elementAt(index);
                                    return MaterialButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CityWeather(favoritedCity),
                                          ),
                                        );
                                      },
                                      child: WeatherWidget(
                                        city: favoritedCity.city,
                                        maxTemp: favoritedCity.maxTemp,
                                        condition: favoritedCity.condition,
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return const SizedBox(
                                      height: 16.0,
                                    );
                                  },
                                  itemCount: bloc.cityWeatherData.length,
                                ),
                              )
                            ],
                          ),
                        ),
                      )
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
