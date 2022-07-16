// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'movie_model.dart';
import 'movie_json_model.dart'; //           for backup & restore only, not for display
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
  static List<Map<String, dynamic>> movieEntries = [];

  // Same entries but for JSON backup/restore (only filled when used)
  static List<MovieModelJson> movieJsonEntries = [];

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
      var newMovie = MovieModel(
          id: idDateInMs,
          movieTitle: pMovieTitle,
          entryTimestamp: DateTime.now().toString(),
          entryDayOfWeek: Constants.weekdayNames[today.weekday - 1],
          movieScore: pMovieScore,
          movieGenre: pMovieGenre);

      // 'write' method wraps all Realm operations
      realm.write(() {
        realm.add(newMovie);
      });
      print(">>> insertion completed for $pMovieTitle, id value = $idDateInMs");
      return "OK";
    } catch (ex, stk) {
      // Pass back any error conditions in non-widget classes, let the Widgets dispatch
      // the results
      print(">>> createMovie Exception: $ex");
      print(">>> Stack: $stk");
      return ex.toString();
    }
  }

  static void updateMovie(
      int updateId, String newTitle, String newGenre, String newScore) {
    var movieModelToUpdate = MovieRepository.realmMovies
        .firstWhere((element) => element.id == updateId);
    print(">>> updateMovie - entry found with id = $updateId");

    MovieRepository.realm.write(() {
      movieModelToUpdate.movieTitle = newTitle.trim();
      movieModelToUpdate.movieGenre = newGenre.trim();
      int? score = int.parse(newScore);
      movieModelToUpdate.movieScore = score;
    });
  }

  static void deleteMovie(int deleteId) {
    var movieModelToDelete = MovieRepository.realmMovies
        .firstWhere((element) => element.id == deleteId);
    print(">>> deleteMovie - entry found with id = $deleteId");
    // no refresh of this UI needed; we're leaving

    MovieRepository.realm.write(() {
      MovieRepository.realm.delete(movieModelToDelete);
    });
  }

  static void deleteAllMovies() {
    // 'write' method wraps all Realm operations
    realm.write(() {
      realm.deleteAll<MovieModel>();
    });

    print(">>> deleteAllMovies completed");
  }

  // Backup and restore processes

  static void backupAllMovies() {
    for (var m in realmMovies) {
      movieJsonEntries.add(MovieModelJson(m.id!, m.entryTimestamp!,
          m.entryDayOfWeek!, m.movieTitle!, m.movieGenre!, m.movieScore));
    }
  }

  static void restoreAllMovies() {
    //  TBD
  }
}
