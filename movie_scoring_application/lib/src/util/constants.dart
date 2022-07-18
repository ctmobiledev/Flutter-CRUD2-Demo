//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Constants {
  //
  // Strings
  static String dialogAppTitle = "Movie Score App (CRUD Demo)";
  static var weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static var movieGenres = [
    'Comedy',
    'Drama',
    'Documentary',
    'Action',
    'Rom-Com',
    'Horror',
    'Sci-Fi',
    'Other'
  ];

  // Styles
  static TextStyle defaultTextStyle = const TextStyle(
      color: Colors.white, fontSize: 16.0, fontFamily: 'OpenSans');

  static TextStyle buttonTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      fontFamily: 'OpenSans');

  static TextStyle blackTextStyle = const TextStyle(
      color: Colors.black, fontSize: 16.0, fontFamily: 'OpenSans');

  static TextStyle jsonBoxTextStyle = const TextStyle(
      color: Colors.black, fontSize: 16.0, fontFamily: 'OpenSans');

  static var closeButtonStyle = ElevatedButton.styleFrom(
      textStyle: Constants.defaultTextStyle,
      primary: Colors.black,
      fixedSize: const Size(100.0, 50.0));

  static var redButtonStyle = ElevatedButton.styleFrom(
      textStyle: Constants.defaultTextStyle,
      primary: Colors.red,
      fixedSize: const Size(100.0, 50.0));

  static var redButtonDisabledStyle = ElevatedButton.styleFrom(
      textStyle: Constants.defaultTextStyle,
      primary: Colors.grey,
      fixedSize: const Size(100.0, 50.0));

  static var greenButtonStyle = ElevatedButton.styleFrom(
      textStyle: Constants.defaultTextStyle,
      primary: Colors.green,
      fixedSize: const Size(100.0, 50.0));

  // Colors
  static var inputCursorColor = Colors.black;
  static var inputBorderColor = Colors.white;
  static var inputDecoration = InputDecoration(
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: const BorderSide(
        width: 0,
        style: BorderStyle.none,
      ),
    ),
    fillColor: Colors.white,
  );
}
