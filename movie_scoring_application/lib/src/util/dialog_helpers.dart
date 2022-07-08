// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'constants.dart';

class DialogHelpers {
  //
  static Future<void> showAlertDialog(
      String msgText, BuildContext buildContext) async {
    showDialog<String>(
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
              Navigator.pop(context, 'OK');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  //
}
