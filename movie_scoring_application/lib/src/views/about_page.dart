import 'package:flutter/material.dart';

import '../util/constants.dart';

class AboutAppWidget extends StatelessWidget {
  const AboutAppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var closeButtonStyle = ElevatedButton.styleFrom(
        primary: Colors.black, fixedSize: const Size(180.0, 50.0));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          // be sure to make the Title a local property
          'About ${Constants.dialogAppTitle}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.only(
              left: 30.0, right: 30.0, top: 20.0, bottom: 20.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Credit: https://flutteragency.com/singlechildscrollview-widget/
            // This allows for a block of text as long as desired, with vertical scrolling
            // that adjusts properly for any vertical screen size.
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    SizedBox(
                      child: Text(
                        'Author: Charles Tatum II\n\n'
                        'Open Sans fonts used in this project are licensed under the Apache License, Version 2.0.\n\n'
                        'https://www.apache.org/licenses/LICENSE-2.0\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        'Put explanatory text about the app here.\n\n'
                        '\n',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: closeButtonStyle,
                onPressed: () {
                  // Navigate back to first route when tapped.
                  Navigator.pop(context);
                },
                child: Text(
                  'Back',
                  style: Constants.buttonTextStyle,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
