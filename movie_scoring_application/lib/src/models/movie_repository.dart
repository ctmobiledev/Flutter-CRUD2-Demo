// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'movie_model.dart';
import '../util/constants.dart';

// Realm support
import 'package:realm/realm.dart';

//
class MovieRepository {
  // Realm declarations - set from main
  LocalConfiguration? config;

  // set by main
  static late BuildContext context;

  // This Realm instance is non-nullable and (assuming correct operation) will always
  // have an instance value. It is also set in initState() in main.dart.
  // All the RealmResults instances should be set IMMEDIATELY after.
  static late Realm realm;
  static late RealmResults<MovieModel> realmMovies;

  // Entries DB
  static List<Map<String, dynamic>> moodEntries = [];

  MovieRepository() {
    print(">>> MovieRepository constructor() fired");
    // may not need these
    realmMovies = realm.all<MovieModel>();
  }

  static RealmResults<MovieModel> getMovies() {
    // consider a try/on at some point
    realmMovies = realm.all<MovieModel>();
    return realmMovies;
  }

  //
  //****************** MAJOR DATABASE OPERATIONS **********************
  //

  static String createMovie(
      String pMovieTitle, int pMovieScore, String pMovieGenre) {
    //

    final today = DateTime.now(); // used for weekday

    int idDateInMs = today.microsecondsSinceEpoch;

    // This caught me on an add on an early Sunday morning:
    // weekday breaks the rules of normal C-oriented
    // languages, with indexes running from 1 to 7
    // instead of 0 to 6!  This error caused an add to
    // fail silently.

    try {
      var newMoodEvent = MovieModel(
          id: idDateInMs,
          movieTitle: pMovieTitle,
          entryTimestamp: DateTime.now().toString(),
          entryDayOfWeek: Constants.weekdayNames[today.weekday - 1],
          movieScore: pMovieScore,
          movieGenre: pMovieGenre);

      // 'write' method wraps all Realm operations
      realm.write(() {
        realm.add(newMoodEvent);
      });
      print(">>> insertion completed for $pMovieTitle, id value = $idDateInMs");
      return "OK";
    } catch (ex, stk) {
      // Pass back any error conditions in non-widget classes, let the Widgets dispatch
      // the results
      print(">>> createMoodEvent Exception: $ex");
      print(">>> Stack: $stk");
      return ex.toString();
    }
  }

  static void deleteAllMovies() {
    // 'write' method wraps all Realm operations
    realm.write(() {
      realm.deleteAll<MovieModel>();
    });

    print(">>> deleteAllMoodEvents completed");
  }

  //
  // Update and Delete operations are in the Edit screen
  // Operations are a little more natural there and don't
  // require a cramped approach to separating the layers.
  //

  // issues with DialogHelper

  static Future<void> showAlertDialog(
      String msgText, BuildContext buildContext) async {
    showDialog<String>(
      context: buildContext,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('CRUD Application'),
        content: Text(msgText),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
