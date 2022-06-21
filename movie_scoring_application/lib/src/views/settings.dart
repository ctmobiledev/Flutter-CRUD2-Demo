import 'package:flutter/material.dart';

import '../util/constants.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var closeButtonStyle = ElevatedButton.styleFrom(
        primary: Colors.black, fixedSize: const Size(180.0, 50.0));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                        'Settings\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
                        'Settings Widgets can be stacked here.\n\n'
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
