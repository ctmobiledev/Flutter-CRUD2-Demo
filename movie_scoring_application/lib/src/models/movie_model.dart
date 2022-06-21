import 'package:realm/realm.dart';
part 'movie_model.g.dart'; // created when cmd window: "flutter pub run realm generate" is executed

@RealmModel()
class _MovieModel {
  int? id = -1;
  String? entryTimestamp;
  String? entryDayOfWeek;
  String? movieTitle;
  String? movieGenre;
  int movieScore = -1;
}
