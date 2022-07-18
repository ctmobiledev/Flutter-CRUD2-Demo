// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/backup_restore_viewmodel.dart';
import '../util/constants.dart';
import '../models/movie_repository.dart';

class BackupRestoreWidget extends StatefulWidget {
  const BackupRestoreWidget({super.key});

  // ***** REQUIRED tag used by Navigator: see MaterialApp's 'routes' property for use *****
  static const routeName = '/backup_restore_args';

  @override
  State<BackupRestoreWidget> createState() => BackupRestoreWidgetState();
}

// Had to change this from private (_) to public in order to allow
// the static text controllers to be visible from the viewModel.

class BackupRestoreWidgetState extends State<BackupRestoreWidget> {
  //
  // One of these is needed for each text field, and the dispose() method
  // is needed to do cleanup per each object.
  //
  // NOTE: These had to be marked 'static' because the compiler complained.
  // There just was no other way to pass these in to the VM.

  static var txtDataJson = TextEditingController();

  BackupRestoreViewModel BackupRestoreVM = BackupRestoreViewModel();

  int gEventInx = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Text controllers were being disposed of here, but for the viewModel
    // object, they had to be made 'static'. Attempting to dispose of them
    // on their second, third, etc., uses resulted in an exception. So now
    // they're left alone.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // args.eventInx = if negative, new (insert); if positive int, edit (update)
    // deletes: do after exited screen
    String title = "Backup/Restore";

    // get previously defined event

    return Scaffold(
        appBar: AppBar(
          title: Text(
            // be sure to make the Title a local property
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: ChangeNotifierProvider(
          // This viewModel reference must be defined at the top of the class
          create: (context) => BackupRestoreVM,
          child: Center(
            child: Consumer<BackupRestoreViewModel>(
                // builder has three arguments - what does the second one actually do?
                // changing the name doesn't affect anything, it seems, and yet
                // the print message below returns an actual instance of the viewModel.
                // Changed the name to 'consumerVM' to distinguish from the 'real' one
                // at the top (since it's a parm name anyway).
                builder: (context, consumerVM, _) {
              //
              // IMPORTANT: MUST RETURN THE *WHOLE* LAYOUT HERE, AFTER 'return'
              // LET THE 'OUTER' WIDGET FROM THE LAYOUT IMMEDIATELY FOLLOW 'return'
              //
              print(">>> Consumer builder: consumerVM = $consumerVM");
              return Container(
                margin: const EdgeInsets.only(
                    left: 30.0, right: 30.0, top: 20.0, bottom: 20.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //Text(args.eventInx.toString()),
                            Center(
                                child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 10.0),
                                  child: Text(
                                    'Data as JSON',
                                    style: Constants.defaultTextStyle,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20.0),
                                  child: TextField(
                                    textCapitalization:
                                        TextCapitalization.words,
                                    controller: txtDataJson,
                                    decoration: Constants.inputDecoration,
                                    cursorColor: Constants.inputCursorColor,
                                    style: Constants.blackTextStyle,
                                  ),
                                ),
                              ],
                            ))
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 20.0),
                        alignment: Alignment.bottomCenter,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: Constants.greenButtonStyle,
                                onPressed: () async {
                                  // tbd
                                },
                                child: Text('Backup',
                                    style: Constants.buttonTextStyle),
                              ),
                              ElevatedButton(
                                style: Constants.redButtonStyle,
                                onPressed: () {
                                  // tbd
                                },
                                child: Text('Restore',
                                    style: Constants.buttonTextStyle),
                              ),
                            ]),
                      ),
                    ]),
              );
            }),
          ),
        ));
  }
}