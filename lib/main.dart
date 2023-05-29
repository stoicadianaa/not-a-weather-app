import 'package:flutter/material.dart';
import 'package:not_a_weather_app/screens/all_locations.dart';
import 'package:not_a_weather_app/screens/city_weather.dart';
import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: AllLocations(),
    );
  }
}