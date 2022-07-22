// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../models/movie_repository.dart';

import '../util/constants.dart';
import '../util/dialog_helpers.dart';

class MovieGenreListViewModel extends ChangeNotifier {
  MovieModel movieModel = MovieModel();

  // TIP: notifyListeners() calls = setState() calls

  Future<void> refreshMovieGenres(BuildContext context) async {
    print(">>> refreshMovieGenres() fired");
    print(
        ">>>===================================================================");

    MovieRepository.realmMovieGenres = MovieRepository.getMovieGenres();
    notifyListeners();

    showMessageIfNoEntries(context);
  }

  void showMessageIfNoEntries(BuildContext context) {
    Future.delayed(
        const Duration(seconds: 1), () => checkForEmptyList(context));
  }

  void checkForEmptyList(BuildContext context) {
    //
    // In actuality, this will never be true, but it's left here if I spin off this page
    // into another data entity.
    //
    if (MovieRepository.realmMovieGenres.isEmpty) {
      DialogHelpers.showAlertDialog("No movie genres entered.", context);
    }
  }

  Future<void> showConfirmDeleteDialog(
      String msgText, BuildContext buildContext) async {
    showDialog<String>(
      // <String> is the data type returned
      context: buildContext,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          Constants.dialogAppTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(msgText),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'Y');
            },
            child: const Text('Yes, Reset'),
          ),
          TextButton(
            onPressed: () {
              // Stay
              Navigator.pop(context, 'N');
            },
            child: const Text('No, Cancel'),
          ),
        ],
      ),
      // don't really use the 'value' passed next to context at this point
    ).then((value) {
      print(">>> value is $value");
      if (value == 'Y') {
        MovieRepository.deleteAllMovieGenres();
        MovieRepository.generateMovieGenres();
        notifyListeners();
        showMessageIfNoEntries(buildContext);
      }
    });
  }

  Future<void> generateTestData() async {
    print(">>> generateTestData() fired");
  }
}
