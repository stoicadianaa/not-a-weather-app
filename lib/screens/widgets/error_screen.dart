import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../assets/app_colors.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    Key? key,
    required this.onError,
  }) : super(key: key);

  final void Function() onError;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
              onPressed: () => onError(),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
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
  }
}
