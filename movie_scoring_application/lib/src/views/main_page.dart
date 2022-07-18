// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../viewmodels/main_viewmodel.dart';

import 'about_page.dart';
import 'edit_movie_page.dart';
import 'edit_movie_page_args.dart';
import 'settings_page.dart';

import '../models/movie_model.dart';
import '../models/movie_repository.dart';

import '../util/constants.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  //
  final mainVM = MainViewModel(); // set further down by ChangeNotifyProvider<T>
  //
  LocalConfiguration? config;

  Object triggerRedraw = Object();

  @override
  void initState() {
    super.initState();

    print(">>> _MainPageState - initState() fired");

    // Init Realm here, as early as possible, should be the very first thing
    // NOTE: the local argument is a LIST of schema objects
    // No need to move to VM; this is a base-level thing, and the repository
    // is already its own "thing"
    //
    print(">>> initState()");
    config = Configuration.local([MovieModel.schema],
        initialDataCallback: initDataCallback);
    print(">>> config = $config");
    MovieRepository.realm = Realm(config!);
    print(">>> MovieRepository.realm = ${MovieRepository.realm.toString()}");

    MovieRepository.realmMovies = MovieRepository.realm.all<MovieModel>();

    // Comment out these lines to start with a clean database.
    //MovieRepository.deleteAllMovies();
    //mainVM.generateTestData();

    mainVM.refreshMovies(context);
  }

  void initDataCallback(Realm localRealm) {
    print(">>> initDataCallback()");
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
              ).whenComplete(() => mainVM.refreshMovies(context));
            } else if (value == 1) {
              print(">>> Settings");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsWidget()),
              );
            } else if (value == 2) {
              print(">>> Clear All Movies");
              mainVM.showConfirmDeleteDialog(
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
      // INSERT ChangeNotifierProvier<SomeViewModelName> HERE
      body: ChangeNotifierProvider<MainViewModel>(
          create: (context) => mainVM,
          child: Consumer<MainViewModel>(builder: (context, mainVM, _) {
            //
            // IMPORTANT: MUST RETURN THE *WHOLE* LAYOUT HERE, AFTER 'return'
            // LET THE 'OUTER' WIDGET FROM THE LAYOUT IMMEDIATELY FOLLOW 'return'
            //
            return Center(
                child: ListView.builder(
                    key: ValueKey<Object>(triggerRedraw),
                    itemCount:
                        MovieRepository.realmMovies.length, // List<Map<...>>
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: Material(
                          color: Colors.blue,
                          child: InkWell(
                            onTap: () {
                              var inx = MovieRepository.realmMovies[index].id;
                              print(
                                  ">>> NAVIGATE TO EDIT SCREEN - tapped inx = $inx");
                              Navigator.pushNamed(
                                context,
                                EditMovieWidget.routeName,
                                arguments: EditMovieArgs(inx!),
                              ).whenComplete(
                                  () => mainVM.refreshMovies(context));
                            },
                            child: Card(
                                color: Colors.transparent,
                                child: SizedBox(
                                  height: 100.0,
                                  child: MovieItemWidget(
                                      MovieRepository.realmMovies[
                                          index]), // pass just one object
                                )),
                          ),
                        ),
                      );
                    }));
          })),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            EditMovieWidget.routeName,
            arguments: EditMovieArgs(-1),
          ).whenComplete(() => mainVM.refreshMovies(context));
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
  // will not go to VM
  //
  late final MovieModel _movieModel;

  // Single object passed, output fields look at properties of _movieModel (above)
  MovieItemWidget(MovieModel movieModel, {Key? key}) : super(key: key) {
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
