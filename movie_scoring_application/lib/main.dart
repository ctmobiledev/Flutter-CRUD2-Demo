// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'src/models/movie_model.dart';
import 'src/models/movie_repository.dart';
import 'src/util/constants.dart';
import 'src/util/dialog_helpers.dart';
import 'src/views/about.dart';
import 'src/views/edit_movie.dart';
import 'src/views/edit_movie_args.dart';
import 'src/views/settings.dart';

// Realm support
import 'package:realm/realm.dart';

void main() {
  print(">>> main() fired");
  runApp(const MovieRatingApp());
}

class MovieRatingApp extends StatelessWidget {
  const MovieRatingApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print(">>> MovieRatingApp/StatelessWidget - build() fired");
    return MaterialApp(
      initialRoute: '/',
      routes: {
        EditMovieWidget.routeName: (context) => const EditMovieWidget(),
      },
      title: Constants.dialogAppTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue,
      ),
      home: MainPage(title: Constants.dialogAppTitle),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  //
  LocalConfiguration? config;

  Object triggerRedraw = Object();

  @override
  void initState() {
    super.initState();

    print(">>> _MainPageState - initState() fired");

    // Init Realm here, as early as possible, should be the very first thing
    // NOTE: the local argument is a LIST of schema objects
    print(">>> initState()");
    config = Configuration.local([MovieModel.schema],
        initialDataCallback: initDataCallback);
    print(">>> config = $config");
    MovieRepository.realm = Realm(config!);
    print(">>> MovieRepository.realm = ${MovieRepository.realm.toString()}");

    MovieRepository.realmMovies = MovieRepository.realm.all<MovieModel>();

    // Comment out these lines to start with a clean database.
    //MovieRepository.deleteAllMovies();
    //generateTestData();

    refreshMovies();
  }

  void initDataCallback(Realm localRealm) {
    print(">>> initDataCallback()");
  }

  void showMessageIfNoEntries() {
    if (MovieRepository.realmMovies.isEmpty) {
      DialogHelpers.showAlertDialog("No movies entered.", context);
    }
  }

  Future<void> generateTestData() async {
    print(">>> generateTestData() fired");
    // a few rows
    MovieRepository.createMovie("Big", 10, "Comedy");
    MovieRepository.createMovie("Moonstruck", 10, "Comedy");
    MovieRepository.createMovie("Broadcast News", 8, "Drama");
    MovieRepository.createMovie("Ordinary People", 8, "Drama");
    MovieRepository.createMovie("The Last Word", 7, "Documentary");
  }

  Future<void> refreshMovies() async {
    print(">>> refreshMovies() fired");
    print(
        ">>>===================================================================");

    setState(() {
      // same as a call to NotifyPropertyChanged() in C#
      // returns: List<Map<String, dynamic>>
      MovieRepository.realmMovies = MovieRepository.getMovies();
    });

    Future.delayed(const Duration(seconds: 1), () => showMessageIfNoEntries());
  }

  // Would need to restructure to allow onPressed to
  // fire an action
  Future<void> showConfirmDeleteDialog(
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
              Navigator.pop(context, 'Y');
            },
            child: const Text('Yes, Delete All'),
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
        setState(() {
          MovieRepository.deleteAllMovies();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(">>> MainPage/StatefulWidget - build() fired");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return const [
              PopupMenuItem<int>(
                value: 0,
                child: Text("New Movie"),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Text("Settings"),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: Text("Clear All Movies"),
              ),
              PopupMenuItem<int>(
                value: 3,
                child: Text("About This App"),
              ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
              print(">>> New Movie");
              // inx of -1 = New, inx > 0 = Edit
              Navigator.pushNamed(
                context,
                EditMovieWidget.routeName,
                arguments: EditMovieArgs(-1),
              ).whenComplete(() => refreshMovies());
            } else if (value == 1) {
              print(">>> Settings");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsWidget()),
              );
            } else if (value == 2) {
              print(">>> Clear All Movies");
              showConfirmDeleteDialog(
                  "This will delete all movie entries. Are you sure?", context);
            } else if (value == 3) {
              print(">>> About");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutAppWidget()),
              );
            }
          }),
        ],
      ),
      body: Center(
          child: ListView.builder(
              key: ValueKey<Object>(triggerRedraw),
              itemCount: MovieRepository.realmMovies.length, // List<Map<...>>
              itemBuilder: (context, index) {
                return GestureDetector(
                  child: Material(
                    color: Colors.blue,
                    child: InkWell(
                      onTap: () {
                        var inx = MovieRepository.realmMovies[index].id;
                        print(
                            ">>> NAVIGATE TO EDIT SCREEN - tapped inx = $inx");
                        //showAlertDialog(item, context);
                        Navigator.pushNamed(
                          context,
                          EditMovieWidget.routeName,
                          arguments: EditMovieArgs(inx!),
                        ).whenComplete(() => refreshMovies());
                      },
                      child: Card(
                          color: Colors.transparent,
                          child: SizedBox(
                            height: 100.0,
                            child: MovieItemWidget(MovieRepository
                                .realmMovies[index]), // pass just one object
                          )),
                    ),
                  ),
                );
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            EditMovieWidget.routeName,
            arguments: EditMovieArgs(-1),
          ).whenComplete(() => refreshMovies());
          print(">>> New Movie - FAB");
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.create),
      ),
    );
  }
}

class MovieItemWidget extends StatelessWidget {
  //
  late MovieModel _movieModel;

  MovieItemWidget(MovieModel movieModel) {
    print(
        ">>> MovieItemWidget constructor - movieModel = ${movieModel.movieTitle}");
    _movieModel = movieModel;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.pink, // comment in to see area where text fields are shown
      // One blog said that constraints aren't always "respected"...pity
      constraints: const BoxConstraints(minWidth: 100, maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      margin:
          const EdgeInsets.only(left: 30.0, right: 30.0, top: 3.0, bottom: 3.0),
      height: 300.0,
      child: SizedBox(
        height: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${_movieModel.movieTitle}',
              style: Constants.defaultTextStyle,
            ),
            Text(
              'Genre: ${_movieModel.movieGenre}',
              style: Constants.defaultTextStyle,
            ),
            Text(
              'Score: ${_movieModel.movieScore}',
              style: Constants.defaultTextStyle,
            ),
            Text(
              'Entry Date: ${_movieModel.entryTimestamp}',
              style: Constants.defaultTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}
