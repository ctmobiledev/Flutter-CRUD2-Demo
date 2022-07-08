// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'src/util/constants.dart';
import 'src/views/edit_movie_page.dart';
import 'src/views/home_page.dart';

void main() {
  print(">>> main() fired");

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MovieRatingApp());
}

class MovieRatingApp extends StatelessWidget {
  const MovieRatingApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print(">>> MovieRatingApp/StatelessWidget - build() fired");
    return MaterialApp(
      home: HomePage(title: Constants.dialogAppTitle), // main_page.dart
      title: Constants.dialogAppTitle,
      initialRoute: '/',
      routes: {
        EditMovieWidget.routeName: (context) => const EditMovieWidget(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'OpenSans',
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue,
      ),
    );
  }
}
