// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:movie_scoring_application/src/models/backup_restore_model.dart';
import 'package:movie_scoring_application/src/views/backup_restore_page.dart';

import '../models/movie_model.dart';
import '../models/movie_repository.dart';
import '../util/constants.dart';
import '../util/dialog_helpers.dart';
import '../views/home_page.dart';

class BackupRestoreViewModel extends ChangeNotifier {
  BackupRestoreModel backupRestoreModel = BackupRestoreModel();

  BackupRestoreViewModel();

  int validateInputs(BuildContext context) {
    int result = 0;

    // Note: no args; just use the text controllers passed in (see above).
    print(">>> validateInputs() fired");

    // This method may be used to validate that the JSON is well-formed.

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

  void backupAllData(BuildContext buildContext) {
    print(">>> backupAllData() fired");
    MovieRepository.backupAllMovies();
    if (MovieRepository.sbJSON.length > 0) {
      BackupRestoreWidgetState.txtDataJson.text =
          MovieRepository.sbJSON.toString();
      DialogHelpers.showAlertDialog(
          "Data copied to clipboard. Paste into any application to save the text, then later "
          "paste back to the box in this window and tap Restore to restore all data.",
          buildContext);
    }
  }

  void restoreAllData() {
    print(">>> restoreAllData() fired");
  }

  void fillInputFields(MovieModel movieModel) {
    BackupRestoreWidgetState.txtDataJson.text =
        backupRestoreModel.dataAsJson.toString();
    notifyListeners();
  }

  void clearInputFields() {
    BackupRestoreWidgetState.txtDataJson.clear();
    notifyListeners();
  }

  Future<void> showConfirmRestoreDialog(
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
            child: const Text('Yes, Restore All'),
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
        MovieRepository.context = buildContext; // for popup messages
        MovieRepository.restoreAllMovies(
            BackupRestoreWidgetState.txtDataJson.text);

        notifyListeners();

        // This was tricky! Had to supply the home page context to the refresh routine:
        // using the context in THIS module didn't work.
        HomePageState.mainVM.refreshMovies(HomePageState.mainContext);
      }
    });
  }

  //
}
