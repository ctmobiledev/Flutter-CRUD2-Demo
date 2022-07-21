// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_scoring_application/src/models/all_data_json_model.dart';
import 'package:movie_scoring_application/src/models/movie_genre_json_model.dart';
import 'package:movie_scoring_application/src/models/movie_genre_model.dart';
import 'movie_model.dart';
import 'movie_json_model.dart'; //           for backup & restore only, not for display
import '../util/dialog_helpers.dart';
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
  static late RealmResults<MovieGenreModel> realmMovieGenres;

  // Entries DB
  static List<Map<String, dynamic>> movieEntries = [];

  // Same entries but for JSON backup/restore (only filled when used)
  // Be sure to define all lists before invoking them in AllDataModelJson
  static List<MovieModelJson> movieJsonEntries = [];
  static List<MovieGenreModelJson> movieGenreJsonEntries = [];
  static AllDataModelJson allDataModelJson =
      AllDataModelJson(movieJsonEntries, movieGenreJsonEntries);

  // Output string for JSON
  static StringBuffer sbJSON = StringBuffer("");

  MovieRepository() {
    print(">>> MovieRepository constructor() fired");
    // may not need these
    realmMovies = realm.all<MovieModel>();
    realmMovieGenres = realm.all<MovieGenreModel>();
    print(">>> realmMovieGenres count: ${realmMovieGenres.length}");
  }

  static RealmResults<MovieModel> getMovies() {
    // consider a try/on at some point
    realmMovies = realm.all<MovieModel>();
    return realmMovies;
  }

  static RealmResults<MovieGenreModel> getMovieGenres() {
    // consider a try/on at some point
    // .all<MovieGenreModel>()
    realmMovieGenres =
        realm.query<MovieGenreModel>('TRUEPREDICATE SORT(movieGenreName ASC)');
    return realmMovieGenres;
  }

  //
  //****************** MAJOR DATABASE OPERATIONS **********************
  //

  //****************** Movies **********************

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

    print(">>> MovieRepository.realm = ${MovieRepository.realm.toString()}");

    MovieRepository.realm.write(() {
      movieModelToUpdate.movieTitle = newTitle.trim();
      movieModelToUpdate.movieGenre = newGenre.trim();
      int? score = int.parse(newScore);
      movieModelToUpdate.movieScore = score;
    });
  }

  static void updateMoviesDeletedGenre(String deletedGenre) {
    var moviesToUpdate = MovieRepository.realmMovies
        .where((element) => element.movieGenre == deletedGenre);
    print(">>> updateMoviesDeletedGenre - with genre = $deletedGenre");
    print(">>> count: ${moviesToUpdate.length}}");

    MovieRepository.realm.write(() {
      for (var m in moviesToUpdate) {
        m.movieGenre = Constants.noDropdownValueSelected;
        print(">>> ${m.movieTitle} now has genre of ${m.movieGenre}");
      }
    });
  }

  static void updateMoviesRenamedGenre(String oldName, String newName) {
    var moviesToUpdate = MovieRepository.realmMovies
        .where((element) => element.movieGenre == oldName);
    print(">>> updateMoviesRenamedGenre - with genre = $oldName");
    print(">>> count: ${moviesToUpdate.length}}");

    MovieRepository.realm.write(() {
      for (var m in moviesToUpdate) {
        m.movieGenre = newName;
        print(">>> ${m.movieTitle} now has genre of ${m.movieGenre}");
      }
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

  //****************** Movies **********************

  static String createMovieGenre(String pMovieGenre) {
    final today = DateTime.now(); // used for weekday

    int idDateInMs = today.microsecondsSinceEpoch;

    try {
      var newMovieGenre =
          MovieGenreModel(id: idDateInMs, movieGenreName: pMovieGenre);

      // 'write' method wraps all Realm operations
      realm.write(() {
        realm.add(newMovieGenre);
      });

      print(">>> insertion completed for $pMovieGenre, id value = $idDateInMs");
      return "OK";
    } catch (ex, stk) {
      // Pass back any error conditions in non-widget classes, let the Widgets dispatch
      // the results
      print(">>> createMovieGenre Exception: $ex");
      print(">>> Stack: $stk");
      return ex.toString();
    }
  }

  static void updateMovieGenre(int updateId, String newGenre) {
    var movieModelGenreToUpdate = MovieRepository.realmMovieGenres
        .firstWhere((element) => element.id == updateId);

    var oldGenre = movieModelGenreToUpdate.movieGenreName.toString();
    print(
        ">>> updateMovieGenre - entry found with id = $updateId, oldGenre = $oldGenre");

    MovieRepository.realm.write(() {
      movieModelGenreToUpdate.movieGenreName = newGenre.trim();
    });

    // Then, reset all the movies' genres from the old value to the new value
    print(
        ">>> updateMovieGenre - calling updateMoviesRenamedGenre, oldGenre = $oldGenre, newGenre = $newGenre");
    MovieRepository.updateMoviesRenamedGenre(oldGenre, newGenre);
  }

  static void deleteMovieGenre(int deleteId) {
    var movieModelGenreToDelete = MovieRepository.realmMovieGenres
        .firstWhere((element) => element.id == deleteId);
    print(
        ">>> deleteMovieGenre - entry found with id = $deleteId, genre is ${movieModelGenreToDelete.movieGenreName}");
    // no refresh of this UI needed; we're leaving

    // First, reset all the movies with the genre to be deleted to the default value
    MovieRepository.updateMoviesDeletedGenre(
        movieModelGenreToDelete.movieGenreName.toString());

    MovieRepository.realm.write(() {
      MovieRepository.realm.delete(movieModelGenreToDelete);
    });
  }

  static void deleteAllMovieGenres() {
    // 'write' method wraps all Realm operations
    realm.write(() {
      realm.deleteAll<MovieGenreModel>();
    });

    print(">>> deleteAllMovieGenres completed");
  }

  static Future<void> generateMovieGenres() async {
    print(">>> generateMovieGenres() fired");
    MovieRepository.realm.write(() {
      MovieRepository.realm.deleteAll<MovieGenreModel>();
      // if genre deleted, processing resets all values to 0
      MovieRepository.realm
          .add(MovieGenreModel(id: 0, movieGenreName: '(No Selection)'));
      MovieRepository.realm
          .add(MovieGenreModel(id: 1, movieGenreName: 'Comedy'));
      MovieRepository.realm
          .add(MovieGenreModel(id: 2, movieGenreName: 'Drama'));
      MovieRepository.realm
          .add(MovieGenreModel(id: 3, movieGenreName: 'Documentary'));
      MovieRepository.realm
          .add(MovieGenreModel(id: 4, movieGenreName: 'Action'));
      MovieRepository.realm
          .add(MovieGenreModel(id: 5, movieGenreName: 'Rom-Com'));
      MovieRepository.realm
          .add(MovieGenreModel(id: 6, movieGenreName: 'Horror'));
      MovieRepository.realm
          .add(MovieGenreModel(id: 7, movieGenreName: 'Sci-Fi'));
      MovieRepository.realm
          .add(MovieGenreModel(id: 8, movieGenreName: 'Other'));
    });
  }

  //
  //****************** BACKUP/RESTORE OPERATIONS **********************
  //

  // For each table/entity, I decided to take a slightly simpler approach:
  // rather than creating the object via the normal way, I'm just wrapping
  // each table - a list - within its own object

  static void backupAllMovies() {
    print(">>> Repos: backupAllMovies");
    sbJSON.clear();

    movieJsonEntries.clear();
    for (var m in realmMovies) {
      movieJsonEntries.add(MovieModelJson(m.id!, m.entryTimestamp!,
          m.entryDayOfWeek!, m.movieTitle!, m.movieGenre!, m.movieScore));
    }

    movieGenreJsonEntries.clear();
    for (var m in realmMovieGenres) {
      movieGenreJsonEntries.add(MovieGenreModelJson(m.id!, m.movieGenreName!));
    }

    // redefine this for the whole outer object
    allDataModelJson.movies = movieJsonEntries;
    allDataModelJson.movieGenres = movieGenreJsonEntries;

    sbJSON.write(
        jsonEncode(allDataModelJson)); // works in conjunction with .toJson()

    // also write the entry to the clipboard automatically
    Clipboard.setData(ClipboardData(text: sbJSON.toString()));

    print(">>> sbJSON:");
    print(sbJSON.toString());
  }

  static void restoreAllMovies(String inputJSON) {
    print(">>> Repos: restoreAllMovies");
    MovieRepository.sbJSON.clear();
    MovieRepository.sbJSON.write(inputJSON);
    print(">>> inputJSON: $inputJSON");
    //MovieRepository.sbJSON.write(txtJSON.text);
    //MovieRepository.convertJsonToEntriesList(); // **** SEE RIGHT BELOW ***
    MovieRepository.convertJsonToDataLists();
    //showAlertDialog("JSON converted to list data.", context);
  }

  static void convertJsonToDataLists() {
    print(">>> convertJsonToDataLists() fired");

    String allJsonText = sbJSON.toString();
    //String arrayObjsText = sbJSON.toString();
    //
    // There is no outer tag, so we just assume list is [   ].
    //
    // Wrapped this in a try/catch in case the JSON is not well-formed.
    // If the JSON is indeed ill-formed, the jsonDecode operation
    // will throw an exception, preventing the deletion of all
    // existing database entries.
    //
    try {
      print(">>> allJsonText = $allJsonText");

      // Anything that's not a List/array of objects is 'dynamic'
      var tagAllDataJson = jsonDecode(allJsonText) as dynamic;

      // Refer to each table/entity within an object by using the map's JSON tag in ['these']
      var tagMoviesJson = tagAllDataJson['movies'] as List;
      List<MovieModelJson> listMovies = tagMoviesJson
          .map((tagJson) => MovieModelJson.fromJson(tagJson))
          .toList();

      var tagMovieGenresJson = tagAllDataJson['movieGenres'] as List;
      List<MovieGenreModelJson> listMovieGenres = tagMovieGenresJson
          .map((tagJson) => MovieGenreModelJson.fromJson(tagJson))
          .toList();

      print(">>> ======= movie models in JSON =======");
      for (var m in listMovies) {
        print(">>> ${m.id}: ${m.movieTitle}");
      }
      print(">>> ======= movie genre models in JSON =======");
      for (var m in listMovieGenres) {
        print(">>> ${m.id}: ${m.movieGenreName}");
      }
      print(">>> ======= end =======");

      // move entries back into the "real" Realm object list;
      // if JSON is not well-formed, processing won't reach the point of deleting
      // all existing data

      //******************************************************************
      // Table 1: Movies
      //******************************************************************
      print(">>> RESTORING: Movies");
      MovieRepository.deleteAllMovies();
      for (var t in listMovies) {
        var newMovie = MovieModel(
            id: t.id,
            movieTitle: t.movieTitle,
            entryTimestamp: t.entryTimestamp,
            entryDayOfWeek: t.entryDayOfWeek,
            movieScore: t.movieScore,
            movieGenre: t.movieGenre);

        realm.write(() {
          realm.add(newMovie);
        });

        print(">>> restore completed for ${t.movieTitle}, id value = ${t.id}");
      }

      //******************************************************************
      // Table 2: Movie Genres (quick and dirty)
      //******************************************************************
      print(">>> RESTORING: Movie Genres");
      MovieRepository.realm.write(() {
        MovieRepository.realm.deleteAll<MovieGenreModel>();

        for (var t in listMovieGenres) {
          var newMovieGenre =
              MovieGenreModel(id: t.id, movieGenreName: t.movieGenreName);

          realm.add(newMovieGenre);
          print(
              ">>> restore completed for ${t.movieGenreName}, id value = ${t.id}");
        }
      });

      //
      DialogHelpers.showAlertDialog(
          "Restore successful.\n\n"
          "Movie entries restored: ${listMovies.length}.\n"
          "Movie Genre entries restored: ${listMovieGenres.length}.",
          context);
      //
    } on FormatException {
      DialogHelpers.showAlertDialog(
          "Restore failed due to ill-formed JSON string. This usually happens when a JSON string has been changed, "
          "but something has caused imbalanced delimiters such as braces, brackets or quotation marks. "
          "Please re-run the backup operation.",
          context);
    } catch (exc, stk) {
      // signal error to user
      DialogHelpers.showAlertDialog(
          "Restore failed: $exc"
          "Stack: $stk",
          context);
    }
  }
}
