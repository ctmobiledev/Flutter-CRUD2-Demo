// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:movie_scoring_application/src/models/movie_genre_model.dart';
import 'package:movie_scoring_application/src/views/edit_movie_genre_page.dart';

import '../models/movie_repository.dart';
import '../util/constants.dart';
import '../util/dialog_helpers.dart';

class EditMovieGenreViewModel extends ChangeNotifier {
  MovieGenreModel movieGenreModel = MovieGenreModel();

  // This cannot be null or blank, or compiler says, "Hey! I don't see that value in the list!"
  // When doing an insertion to Realm, read this value, not the text controller from before.
  // NOTE: This cannot be made private, as it's accessed from 'edit_movie_page'.
  //
  static List<String> movieGenres = [];

  // The TextEditingController for the genre has been replaced with a DropDownButton.
  //
  // Nothing passed in for now; text controller values are read remotely as static objects.
  //
  EditMovieGenreViewModel() {
    print(">>> EditMovieGenreViewModel() constructor fired");
    var realmMovieGenres = MovieRepository.realm.all<MovieGenreModel>();
    movieGenres.clear();
    for (var g in realmMovieGenres) {
      movieGenres.add(g.movieGenreName.toString());
    }
  }

  int validateInputs(BuildContext context) {
    int result = 0;

    // Note: no args; just use the text controllers passed in (see above).
    print(">>> validateInputs() fired");

    // Code 1: at least one missing input
    if (EditMovieGenreWidgetState.txtMovieGenre.text.trim().isEmpty) {
      result = 1;
    } else {
      // To prevent a genre value from hosing the sort order - "(No Selection)" should always be element 0 -
      // a regular expression will ensure values can only have [A-Z][a-z][0-9] as the first character. It
      // must start with a letter or a number.
      final firstCharAlphaNumericTest = RegExp(r'^[a-zA-Z0-9]');
      var firstCharIsAlphaNumeric = firstCharAlphaNumericTest
          .hasMatch(EditMovieGenreWidgetState.txtMovieGenre.text.trim());
      if (firstCharIsAlphaNumeric == false) {
        result = 2;
      }
    }

    return result;
  }

  void showErrorMessage(int errorCode, BuildContext context) {
    print(">>> showErrorMessage, errorCode = $errorCode");
    switch (errorCode) {
      case 1:
        DialogHelpers.showAlertDialog(
            "Please enter a movie genre before saving.", context);
        break;
      case 2:
        DialogHelpers.showAlertDialog(
            "The value must start with a letter (A to Z, a to z) or a number.",
            context);
        break;
      case 99:
        DialogHelpers.showAlertDialog(
            "Error code 99. Please contact the developer.", context);
        break;
    }
  }

  // Can the create/insert and update operations be moved so they can be
  // called from the repository directly?

  Future<bool> createNewMovieGenre(BuildContext context) async {
    print(">>> createNewMovieGenre");
    bool successResult = true;
    int validationResultCode = validateInputs(context);
    String result = ""; // hope this means new String("")

    print(">>> validationResultCode = $validationResultCode");

    if (validationResultCode == 0) {
      result = MovieRepository.createMovieGenre(
          EditMovieGenreWidgetState.txtMovieGenre.text.trim());

      print(">>> result from MovieRepository.createNewMovie = $result");

      if (result != "OK") {
        validationResultCode = 99;
        successResult = false;
      }
    } else {
      showErrorMessage(validationResultCode, context);
      successResult = false;
    }

    print(">>> successResult = $successResult");
    return successResult;
  }

  Future<bool> updateExistingMovieGenre(
      int updateId, BuildContext context) async {
    print(">>> updateExistingMovie");
    bool successResult = true;

    int validationResultCode = validateInputs(context);
    if (validationResultCode == 0) {
      MovieRepository.updateMovieGenre(
          updateId, EditMovieGenreWidgetState.txtMovieGenre.text);
      notifyListeners();
      //
    } else {
      showErrorMessage(validationResultCode, context);
      successResult = false;
    }

    print(">>> successResult = $successResult");
    return successResult;
  }

  void deleteExistingMovieGenre(int deleteId) {
    // First, do a cascading change to all movie entries so they have the default "(No Selection)" value

    MovieRepository.deleteMovieGenre(deleteId);
    //
    // No call to listeners needed; this is a database operation:
    // list on home page will update on return
    //
  }

  Future<void> showDeleteDialog(
      String msgText, int eventInx, BuildContext context) async {
    showDialog<String>(
      // <String> is the data type returned
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          Constants.dialogAppTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(msgText),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              deleteExistingMovieGenre(eventInx);
              Navigator.pop(context, 'Y');
            },
            child: const Text('Yes, Delete'),
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
    ).then((value) => {if (value == 'Y') Navigator.pop(context, 'Y')});
  }

  void fillInputFields(MovieGenreModel movieGenreModel) {
    EditMovieGenreWidgetState.txtMovieGenre.text =
        movieGenreModel.movieGenreName.toString();
    notifyListeners();
  }

  void clearInputFields() {
    EditMovieGenreWidgetState.txtMovieGenre.clear();
    notifyListeners();
  }
}
