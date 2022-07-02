// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../models/movie_repository.dart';
import '../util/constants.dart';
import '../util/dialog_helpers.dart';

class EditMovieViewModel extends ChangeNotifier {
  MovieModel movieModel = MovieModel();

  // This is as close as we get to bound UI controls - they had to be
  // passed in, in this clumsy way
  //
  TextEditingController _txtMovieTitle = TextEditingController();
  TextEditingController _txtMovieGenre = TextEditingController();
  TextEditingController _txtMovieScore = TextEditingController();

  EditMovieViewModel(
      TextEditingController txtMovieTitle,
      TextEditingController txtMovieGenre,
      TextEditingController txtMovieScore) {
    _txtMovieTitle = txtMovieTitle;
    _txtMovieGenre = txtMovieGenre;
    _txtMovieScore = txtMovieScore;
  }

  int validateInputs(BuildContext context) {
    int result = 0;

    // Note: no args; just use the text controllers passed in (see above).
    print(">>> validateInputs() fired");

    // Code 1: at least one missing input
    if (_txtMovieTitle.text.trim().isEmpty) {
      result = 1;
    }
    if (_txtMovieGenre.text.trim().isEmpty) {
      result = 1;
    }
    if (_txtMovieScore.text.trim().isEmpty) {
      result = 1;
    }

    // Code 2: non-numeric input
    if (result == 0) {
      int? score = int.tryParse(_txtMovieScore.text);
      if (score == null) {
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
            "Please complete all inputs before saving.", context);
        break;
      case 2:
        DialogHelpers.showAlertDialog(
            "Whole numbers allowed for numeric inputs only. Please enter a valid number.",
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

  Future<bool> createNewMovie(BuildContext context) async {
    print(">>> createNewMovie");
    bool successResult = true;
    int validationResultCode = validateInputs(context);
    String result = ""; // hope this means new String("")

    print(">>> validationResultCode = $validationResultCode");

    if (validationResultCode == 0) {
      int score = int.parse(_txtMovieScore.text);

      result = MovieRepository.createMovie(
          _txtMovieTitle.text.trim(), score, _txtMovieGenre.text.trim());
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

  Future<bool> updateExistingMovie(int updateId, BuildContext context) async {
    print(">>> updateExistingMovie");
    bool successResult = true;

    int validationResultCode = validateInputs(context);
    if (validationResultCode == 0) {
      MovieRepository.updateMovie(updateId, _txtMovieTitle.text,
          _txtMovieGenre.text, _txtMovieScore.text);

      notifyListeners();
      //
    } else {
      showErrorMessage(validationResultCode, context);
      successResult = false;
    }

    print(">>> successResult = $successResult");
    return successResult;
  }

  void deleteExistingMovie(int deleteId) {
    MovieRepository.deleteMovie(deleteId);

    // no call to listeners needed; this is a database operation
    // list on home page will update on return
  }

  Future<void> showDeleteDialog(
      String msgText, int eventInx, BuildContext context) async {
    showDialog<String>(
      // <String> is the data type returned
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(Constants.dialogAppTitle),
        content: Text(msgText),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              deleteExistingMovie(eventInx);
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
      // don't really use the 'value' passed next to context at this point
    ).then((value) => {if (value == 'Y') Navigator.pop(context, 'Y')});
  }

  void fillInputFields(MovieModel movieModel) {
    _txtMovieTitle.text = movieModel.movieTitle.toString();
    _txtMovieGenre.text = movieModel.movieGenre.toString();
    _txtMovieScore.text = movieModel.movieScore.toString();
    notifyListeners();
  }

  void clearInputFields() {
    _txtMovieTitle.clear();
    _txtMovieGenre.clear();
    _txtMovieScore.clear();
    notifyListeners();
  }
}
