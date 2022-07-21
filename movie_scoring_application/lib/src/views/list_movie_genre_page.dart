// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:movie_scoring_application/src/models/movie_genre_model.dart';
import 'package:movie_scoring_application/src/util/dialog_helpers.dart';
import 'package:movie_scoring_application/src/views/edit_movie_genre_page.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../viewmodels/list_movie_genre_viewmodel.dart';

import 'edit_movie_genre_page_args.dart';

import '../models/movie_model.dart';
import '../models/movie_repository.dart';

import '../util/constants.dart';

double cardHeight = 60.0;

class MovieGenreListWidget extends StatefulWidget {
  const MovieGenreListWidget({super.key});

  // Any 'final' variables must have values like 'title' which was removed
  // from a replication of the home page.

  @override
  State<MovieGenreListWidget> createState() => MovieGenreListWidgetState();
}

class MovieGenreListWidgetState extends State<MovieGenreListWidget> {
  //
  // NOTE: this had static final for the declaration and for some reason (maybe the 'final' marking?)
  // it wasn't allowing dispose() to be called, so processing from ChangeNotifier complained it had
  // already been disposed/destroyed. Going forward, for lists like this page, use an ordinary declaration
  // (not a var dynamic, either, the actual type).
  //
  MovieGenreListViewModel listMovieGenreVM =
      MovieGenreListViewModel(); // set further down by ChangeNotifyProvider<T>
  //
  LocalConfiguration? config;

  static Object triggerRedraw = Object();

  static late BuildContext mainContext;

  String pageTitle = "Movie Genres";

  @override
  void initState() {
    super.initState();

    print(">>> MovieGenreListWidgetState - initState() fired");

    // Init Realm here, as early as possible, should be the very first thing
    //
    // NOTE: the local argument is a LIST of schema objects
    // Add one [xxxx.schema] for each call to Configuration
    // No need to move to VM; this is a base-level thing, and the repository
    // is already its own "thing"
    //
    print(">>> initState()");
    config = Configuration.local([MovieModel.schema, MovieGenreModel.schema],
        initialDataCallback: initDataCallback);
    print(">>> config = $config");

    // This was initialized (static) via HomePage; no need to do it again here.
    //MovieRepository.realm = Realm(config!);
    //print(">>> MovieRepository.realm = ${MovieRepository.realm.toString()}");

    MovieRepository.realmMovieGenres =
        MovieRepository.realm.all<MovieGenreModel>();

    // Comment out these lines to start with a clean database.
    //MovieRepository.deleteAllMovies();
    //generateTestData();

    listMovieGenreVM.refreshMovieGenres(context);
  }

  @override
  void dispose() {
    // Text controllers were being disposed of here, but for the viewModel
    // object, they had to be made 'static'. Attempting to dispose of them
    // on their second, third, etc., uses resulted in an exception. So now
    // they're left alone.
    super.dispose();
  }

  void initDataCallback(Realm localRealm) {
    print(">>> initDataCallback()");
  }

  @override
  Widget build(BuildContext context) {
    print(">>> MovieGenreListWidget/StatefulWidget - build() fired");
    mainContext = context;
    print(">>> mainContext saved");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return const [
              PopupMenuItem<int>(
                value: 0,
                child: Text("New Movie Genre"),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Text("Reset Movie Genres"),
              ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
              print(">>> New Movie Genre");
              // inx of -1 = New, inx > 0 = Edit
              Navigator.pushNamed(
                context,
                EditMovieGenreWidget.routeName,
                arguments: EditMovieGenreArgs(-1),
              ).whenComplete(
                  () => listMovieGenreVM.refreshMovieGenres(context));
            } else if (value == 1) {
              print(">>> Reset All Movie Genres");

              // may need a special index to pass for the onPressed action to follow
              listMovieGenreVM.showConfirmDeleteDialog(
                  "This will reset all movie genre entries. Are you sure?",
                  context);
            }
          }),
        ],
      ),
      // INSERT ChangeNotifierProvier<SomeViewModelName> HERE
      body: ChangeNotifierProvider<MovieGenreListViewModel>(
          create: (context) => listMovieGenreVM,
          child:
              Consumer<MovieGenreListViewModel>(builder: (context, listVM, _) {
            //
            // IMPORTANT: MUST RETURN THE *WHOLE* LAYOUT HERE, AFTER 'return'
            // LET THE 'OUTER' WIDGET FROM THE LAYOUT IMMEDIATELY FOLLOW 'return'
            //
            return Center(
                child: ListView.builder(
                    key: ValueKey<Object>(triggerRedraw),
                    itemCount: MovieRepository
                        .realmMovieGenres.length, // List<Map<...>>
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: Material(
                          color: Colors.blue,
                          child: InkWell(
                            onTap: () {
                              // User is not allowed to modify the very top entry, as it's the default
                              // value indicating no selection has been made.
                              if (index == 0) {
                                //
                                DialogHelpers.showAlertDialog(
                                    "This entry cannot be changed.", context);
                              } else {
                                //
                                var inx =
                                    MovieRepository.realmMovieGenres[index].id;
                                print(
                                    ">>> NAVIGATE TO EDIT SCREEN - tapped inx = $inx");
                                Navigator.pushNamed(
                                  context,
                                  EditMovieGenreWidget.routeName,
                                  arguments: EditMovieGenreArgs(inx!),
                                ).whenComplete(
                                    () => listVM.refreshMovieGenres(context));
                              }
                            },
                            child: Card(
                                color: Colors.transparent,
                                child: SizedBox(
                                  height: cardHeight,
                                  child: MovieGenreItemWidget(
                                      MovieRepository.realmMovieGenres[
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
            EditMovieGenreWidget.routeName,
            arguments: EditMovieGenreArgs(-1),
          ).whenComplete(() => listMovieGenreVM.refreshMovieGenres(context));
          print(">>> New Movie Genre - FAB");
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.create),
      ),
    );
  }
}

class MovieGenreItemWidget extends StatelessWidget {
  //
  // will not go to VM
  //
  late final MovieGenreModel _movieGenreModel;

  // Single object passed, output fields look at properties of _movieModel (above)
  MovieGenreItemWidget(MovieGenreModel movieGenreModel, {Key? key})
      : super(key: key) {
    print(
        ">>> MovieItemWidget constructor - movieGenreModel = ${movieGenreModel.movieGenreName}");
    _movieGenreModel = movieGenreModel;
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
      height: cardHeight,
      child: SizedBox(
        height: cardHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_movieGenreModel.movieGenreName}',
              style: Constants.defaultTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}
