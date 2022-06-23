// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../util/constants.dart';
import '../util/dialog_helpers.dart';
import 'edit_movie_args.dart';
import '../models/movie_repository.dart';

class EditMovieWidget extends StatefulWidget {
  const EditMovieWidget({super.key});

  // ***** REQUIRED tag used by Navigator: see MaterialApp's 'routes' property for use *****
  static const routeName = '/edit_movie_args';

  @override
  State<EditMovieWidget> createState() => _EditMovieWidgetState();
}

class _EditMovieWidgetState extends State<EditMovieWidget> {
  // One of these is needed for each text field, and the dispose() method
  // is needed to do cleanup per each object.
  final txtMovieTitle = TextEditingController();
  final txtMovieGenre = TextEditingController();
  final txtMovieScore = TextEditingController();

  int gEventInx = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree. Required.
    txtMovieTitle.dispose();
    txtMovieGenre.dispose();
    txtMovieScore.dispose();
    super.dispose();
  }

  Future<bool> createNewMovie() async {
    int errorCode = 0;
    String result = ""; // hope this means new String("")
    bool allRequiredInputs = true;

    // Note: no args; just use the text controllers
    // as they sit.
    print(">>> createNewEvent() fired");
    int? score = int.tryParse(txtMovieScore.text);

    if (txtMovieScore.text.isNotEmpty) {
      if (score == null) {
        await DialogHelpers.showAlertDialog(
            "Non-numeric input for Score. Please enter a valid number.",
            context);

        allRequiredInputs = false;
        return allRequiredInputs;
      }
    }

    if (txtMovieTitle.text.trim().isEmpty) {
      allRequiredInputs = false;
    }
    if (txtMovieGenre.text.trim().isEmpty) {
      allRequiredInputs = false;
    }
    if (txtMovieScore.text.trim().isEmpty) {
      allRequiredInputs = false;
    }

    if (allRequiredInputs) {
      //setState(() {});
      result = MovieRepository.createMovie(
          txtMovieTitle.text.trim(), score!, txtMovieGenre.text.trim());
      print(">>> result from createMoodEvent = $result");
      if (result != "OK") {
        errorCode = 1;
      }
    } else {
      errorCode = 2;
    }

    print(">>> errorCode = $errorCode");
    switch (errorCode) {
      case 1:
        // This refuses to fire - why?
        await DialogHelpers.showAlertDialog(
            "Error in createNewEvent(): $result. Please contact the developer.",
            context);
        break;
      case 2:
        print(">>> allRequiredInputs false; should do else leg");
        await DialogHelpers.showAlertDialog(
            "Please complete all inputs before saving.", context);
        break;
      default:
        break;
    }

    print(">>> returning allRequiredInputs = $allRequiredInputs");
    return allRequiredInputs;
  }

  void updateExistingMovie(int updateId) {
    var moodEventMovieToUpdate = MovieRepository.realmMovies
        .firstWhere((element) => element.id == updateId);
    print(">>> updateExistingEvent - entry found with id = $updateId");
    setState(() {
      MovieRepository.realm.write(() {
        // update individual properties; we only care about the first found
        int? score = int.tryParse(txtMovieScore.text);
        moodEventMovieToUpdate.movieTitle = txtMovieTitle.text.trim();
        moodEventMovieToUpdate.movieGenre = txtMovieGenre.text.trim();
        moodEventMovieToUpdate.movieScore = score ?? 0;
      });
    });
  }

  void deleteExistingMovie(int deleteId) {
    var movieModelToDelete = MovieRepository.realmMovies
        .firstWhere((element) => element.id == deleteId);
    print(">>> deleteExistingMovie - entry found with id = $deleteId");
    // no refresh of this UI needed; we're leaving
    MovieRepository.realm.write(() {
      MovieRepository.realm.delete(movieModelToDelete);
    });
  }

  // Would need to restructure to allow onPressed to
  // fire an action
  Future<void> showDeleteDialog(
      String msgText, BuildContext buildContext) async {
    showDialog<String>(
      // <String> is the data type returned
      context: buildContext,
      builder: (BuildContext context) => AlertDialog(
        title: Text(Constants.dialogAppTitle),
        content: Text(msgText),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              deleteExistingMovie(gEventInx);
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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as EditMovieArgs;

    gEventInx = args.movieId;

    // args.eventInx = if negative, new (insert); if positive int, edit (update)
    // deletes: do after exited screen
    String title = (args.movieId == -1) ? "New Movie" : "Edit Movie";

    // get previously defined event
    if (args.movieId > 0) {
      var moodEventModelValues = MovieRepository.realmMovies
          .firstWhere((element) => element.id == args.movieId);
      print(">>> entry found with id = ${args.movieId}");
      setState(() {
        // update the input fields
        txtMovieTitle.text = moodEventModelValues.movieTitle.toString();
        txtMovieGenre.text = moodEventModelValues.movieGenre.toString();
        txtMovieScore.text = moodEventModelValues.movieScore.toString();
      });
    }

    // Want these to stay "local" for the moment
    var inputCursorColor = Colors.black;
    var inputBorderColor = Colors.white;
    var inputDecoration = InputDecoration(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(
          width: 0,
          style: BorderStyle.none,
        ),
      ),
      fillColor: Colors.white,
    );

    var closeButtonStyle = ElevatedButton.styleFrom(
        textStyle: Constants.defaultTextStyle,
        primary: Colors.black,
        fixedSize: const Size(100.0, 50.0));

    var redButtonStyle = ElevatedButton.styleFrom(
        textStyle: Constants.defaultTextStyle,
        primary: Colors.red,
        fixedSize: const Size(100.0, 50.0));

    var redButtonDisabledStyle = ElevatedButton.styleFrom(
        textStyle: Constants.defaultTextStyle,
        primary: Colors.grey,
        fixedSize: const Size(100.0, 50.0));

    var greenButtonStyle = ElevatedButton.styleFrom(
        textStyle: Constants.defaultTextStyle,
        primary: Colors.green,
        fixedSize: const Size(100.0, 50.0));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          // be sure to make the Title a local property
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.only(
              left: 30.0, right: 30.0, top: 20.0, bottom: 20.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            // Credit: https://flutteragency.com/singlechildscrollview-widget/
            // This allows for a block of text as long as desired, with vertical scrolling
            // that adjusts properly for any vertical screen size.
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
                          'Movie Title',
                          style: Constants.defaultTextStyle,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        child: TextField(
                          textCapitalization: TextCapitalization.words,
                          controller: txtMovieTitle,
                          decoration: inputDecoration,
                          cursorColor: inputCursorColor,
                          style: Constants.blackTextStyle,
                        ),
                      ),
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
                          textCapitalization: TextCapitalization.words,
                          controller: txtMovieGenre,
                          decoration: inputDecoration,
                          cursorColor: inputCursorColor,
                          style: Constants.blackTextStyle,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          'Score',
                          style: Constants.defaultTextStyle,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: txtMovieScore,
                          decoration: inputDecoration,
                          cursorColor: inputCursorColor,
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
                      style: greenButtonStyle,
                      onPressed: () async {
                        if (args.movieId == -1) {
                          var result = await createNewMovie();
                          print(">>> SAVE - result = $result");
                          if (result == true) {
                            Navigator.pop(context);
                          }
                        } else {
                          print(">>> running update and popping");
                          updateExistingMovie(args.movieId);
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Save', style: Constants.buttonTextStyle),
                    ),
                    ElevatedButton(
                      style: closeButtonStyle,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel', style: Constants.buttonTextStyle),
                    ),
                    ElevatedButton(
                      style: (args.movieId == -1)
                          ? redButtonDisabledStyle
                          : redButtonStyle,
                      onPressed: () {
                        print(">>> Delete button pressed");
                        if (args.movieId > -1) {
                          //confirmDelete(args.eventInx);
                          showDeleteDialog(
                              "Are you sure you mean to delete this entry?",
                              context);
                        }
                        // Can only delete an existing entry
                        // Navigate back to first route when tapped.
                        //Navigator.pop(context);
                      },
                      child: Text('Delete', style: Constants.buttonTextStyle),
                    ),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}
