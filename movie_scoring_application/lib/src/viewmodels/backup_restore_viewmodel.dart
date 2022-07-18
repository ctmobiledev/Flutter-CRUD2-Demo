// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:movie_scoring_application/src/models/backup_restore_model.dart';
import 'package:movie_scoring_application/src/views/backup_restore_page.dart';

import '../models/movie_model.dart';
import '../models/movie_repository.dart';
import '../util/constants.dart';
import '../util/dialog_helpers.dart';

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

  void backupAllData() {
    print(">>> backupAllData() fired");
    MovieRepository.backupAllMovies();
    if (MovieRepository.sbJSON.length > 0) {
      BackupRestoreWidgetState.txtDataJson.text =
          MovieRepository.sbJSON.toString();
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
  //
}
