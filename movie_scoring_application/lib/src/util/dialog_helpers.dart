// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'constants.dart';

class DialogHelpers {
  //
  //
  static Future<void> showAlertDialog(
      String msgText, BuildContext buildContext) async {
    showDialog<String>(
      context: buildContext,
      builder: (BuildContext context) => AlertDialog(
        title: Text(Constants.dialogAppTitle),
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

  static Future<int> showDeleteDialog(
      // 1 = yes, confirm
      String msgText,
      BuildContext buildContext) async {
    var result = 0;
    showDialog<int>(
      // <String> is the data type returned
      context: buildContext,
      builder: (BuildContext context) => AlertDialog(
        title: Text(Constants.dialogAppTitle),
        content: Text(msgText),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              result = 1;
              Navigator.pop(context, 1);
            },
            child: const Text('Yes, Delete'),
          ),
          TextButton(
            onPressed: () {
              // Stay
              result = 0;
              Navigator.pop(context, 0);
            },
            child: const Text('No, Cancel'),
          ),
        ],
      ),
      //
    ).then(
      (value) {
        result = value!;
        print(">>> showDialog<> result = $result");
        if (result == 1) Navigator.pop(buildContext, 1);
      },
    );

    print(">>> DialogHelpers.showDeleteDialog - returning $result");
    return Future.value(result);
  }
}
