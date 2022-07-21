// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:movie_scoring_application/src/viewmodels/edit_movie_genre_viewmodel.dart';
import 'package:movie_scoring_application/src/views/edit_movie_genre_page_args.dart';
import 'package:provider/provider.dart';

import '../util/constants.dart';
import '../models/movie_repository.dart';

class EditMovieGenreWidget extends StatefulWidget {
  const EditMovieGenreWidget({super.key});

  // ***** REQUIRED tag used by Navigator: see MaterialApp's 'routes' property for use *****
  static const routeName = '/edit_movie_genre_args';

  @override
  State<EditMovieGenreWidget> createState() => EditMovieGenreWidgetState();
}

// Had to change this from private (_) to public in order to allow
// the static text controllers to be visible from the viewModel.

class EditMovieGenreWidgetState extends State<EditMovieGenreWidget> {
  //
  // One of these is needed for each text field, and the dispose() method
  // is needed to do cleanup per each object.
  //
  // NOTE: These had to be marked 'static' because the compiler complained.
  // There just was no other way to pass these in to the VM.

  static var txtMovieGenre = TextEditingController();

  //static var txtMovieGenre = TextEditingController();   // replaced with dropdown box

  EditMovieGenreViewModel editMovieGenreVM = EditMovieGenreViewModel();

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
    final args =
        ModalRoute.of(context)!.settings.arguments as EditMovieGenreArgs;

    gEventInx = args.id;

    // args.eventInx = if negative, new (insert); if positive int, edit (update)
    // deletes: do after exited screen
    String title = (args.id == -1) ? "New Movie Genre" : "Edit Movie Genre";

    // get previously defined event
    if (args.id > 0) {
      var movieModelGenreValues = MovieRepository.realmMovieGenres
          .firstWhere((element) => element.id == args.id);

      print(">>> entry found with id = ${args.id}");

      // Fill the text controllers
      txtMovieGenre.text = movieModelGenreValues.movieGenreName.toString();
      //
    } else {
      // no index found (id == -1); start with blank fields
      editMovieGenreVM.clearInputFields();
    }

    var moreThanOneEntry = (MovieRepository.realmMovieGenres.length > 1);

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
          create: (context) => editMovieGenreVM,
          child: Center(
            child: Consumer<EditMovieGenreViewModel>(
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
                                    'Genre',
                                    style: Constants.defaultTextStyle,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20.0),
                                  child: TextField(
                                    textCapitalization:
                                        TextCapitalization.words,
                                    controller: txtMovieGenre,
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
                                  if (args.id == -1) {
                                    var success = await editMovieGenreVM
                                        .createNewMovieGenre(context);
                                    print(">>> Save/New - success = $success");
                                    if (success) {
                                      Navigator.pop(context);
                                    }
                                  } else {
                                    print(">>> running update and popping");
                                    var success = await editMovieGenreVM
                                        .updateExistingMovieGenre(
                                            args.id, context);
                                    print(
                                        ">>> Save/Update - success = $success");
                                    if (success) {
                                      Navigator.pop(context);
                                    }
                                  }
                                },
                                child: Text('Save',
                                    style: Constants.buttonTextStyle),
                              ),
                              ElevatedButton(
                                style: Constants.closeButtonStyle,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel',
                                    style: Constants.buttonTextStyle),
                              ),
                              ElevatedButton(
                                style: (args.id == -1 || !moreThanOneEntry)
                                    ? Constants.redButtonDisabledStyle
                                    : Constants.redButtonStyle,
                                onPressed: () {
                                  print(">>> Delete button pressed");
                                  print(
                                      ">>> moreThanOneEntry = $moreThanOneEntry");
                                  if (moreThanOneEntry) {
                                    if (args.id > -1) {
                                      editMovieGenreVM.showDeleteDialog(
                                          "Are you sure you mean to delete this entry?",
                                          args.id,
                                          context);
                                    }
                                  }
                                },
                                child: Text('Delete',
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
