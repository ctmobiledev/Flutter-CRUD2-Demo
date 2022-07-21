// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:movie_scoring_application/src/models/movie_genre_model.dart';
import 'package:movie_scoring_application/src/views/edit_movie_page.dart';

import '../models/movie_model.dart';
import '../models/movie_repository.dart';
import '../util/constants.dart';
import '../util/dialog_helpers.dart';

class EditMovieViewModel extends ChangeNotifier {
  MovieModel movieModel = MovieModel();

  // This cannot be null or blank, or compiler says, "Hey! I don't see that value in the list!"
  // When doing an insertion to Realm, read this value, not the text controller from before.
  // NOTE: This cannot be made private, as it's accessed from 'edit_movie_page'.
  //
  static List<String> movieGenres = [];
  String strMovieGenreSelected = "";

  // The TextEditingController for the genre has been replaced with a DropDownButton.
  //
  // Nothing passed in for now; text controller values are read remotely as static objects.
  //
  EditMovieViewModel() {
    print(">>> EditMovieViewModel() constructor fired");
    var realmMovieGenres = MovieRepository.realm.all<MovieGenreModel>();
    movieGenres.clear();
    for (var g in realmMovieGenres) {
      movieGenres.add(g.movieGenreName.toString());
    }
    strMovieGenreSelected = movieGenres[0];
  }

  int validateInputs(BuildContext context) {
    int result = 0;

    // Note: no args; just use the text controllers passed in (see above).
    print(">>> validateInputs() fired");

    // Code 1: at least one missing input
    if (EditMovieWidgetState.txtMovieTitle.text.trim().isEmpty) {
      result = 1;
    }
    // Genre doesn't have to be validated because it's one choice
    // from a pre-set array. (How will combo boxes be done?)
    if (EditMovieWidgetState.txtMovieScore.text.trim().isEmpty) {
      result = 1;
    }

    // Code 2: non-numeric input
    if (result == 0) {
      int? score = int.tryParse(EditMovieWidgetState.txtMovieScore.text);
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
      int score = int.parse(EditMovieWidgetState.txtMovieScore.text);

      result = MovieRepository.createMovie(
          EditMovieWidgetState.txtMovieTitle.text.trim(),
          score,
          strMovieGenreSelected);

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
      MovieRepository.updateMovie(
          updateId,
          EditMovieWidgetState.txtMovieTitle.text,
          strMovieGenreSelected,
          EditMovieWidgetState.txtMovieScore.text);

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
    ).then((value) => {if (value == 'Y') Navigator.pop(context, 'Y')});
  }

  void fillInputFields(MovieModel movieModel) {
    EditMovieWidgetState.txtMovieTitle.text = movieModel.movieTitle.toString();

    //
    // If the previously selected movie genre has disappeared or been previously deleted,
    // this resets the dropdown value for this column to the default.
    //
    /*
    if (EditMovieViewModel.movieGenres.contains(movieModel.movieGenre) ==
        false) {
      print(
          ">>> Genre ${movieModel.movieGenre} was deleted, replacing with default");
      strMovieGenreSelected = Constants.noDropdownValueSelected;
    } else {
      strMovieGenreSelected =
          movieModel.movieGenre.toString(); // for the drop-down button
    }
    */

    strMovieGenreSelected =
        movieModel.movieGenre.toString(); // for the drop-down button

    EditMovieWidgetState.txtMovieScore.text = movieModel.movieScore.toString();

    notifyListeners();
  }

  void clearInputFields() {
    EditMovieWidgetState.txtMovieTitle.clear();
    EditMovieWidgetState.txtMovieScore.clear();
    // Genre is reset to index 0 each call to "new" item each time the page is opened.
    notifyListeners();
  }

  void updateGenreDropdown(String selectedValue) {
    print(">>> updateGenreDropdown, selectedValue = $selectedValue");
    strMovieGenreSelected = selectedValue;
    notifyListeners(); //   this may be superfluous since setState() actually saves selected index
  }
}
