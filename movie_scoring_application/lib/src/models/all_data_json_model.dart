// NOTE: This class is NOT marked as a Realm Object, so Realm happily ignored it.
// It only exists for one purpose, and that's the backup/restore of data from a Realm object/table.
// It will NOT be used to display anything in the UI.
// It DOES have the exact same properties as _MovieModel (private) and MovieModel (public).
//
import 'package:movie_scoring_application/src/models/movie_json_model.dart';

class AllDataModelJson {
  List<MovieModelJson>? movies;

  AllDataModelJson(List<MovieModelJson> pMovies) {
    movies = pMovies;
  }

  Map toJson() => {
        //
        'movies': movies
        //
      };

  factory AllDataModelJson.fromJson(dynamic json) {
    return AllDataModelJson(json['movies'] as List<MovieModelJson>);
  }

  @override
  String toString() {
    return '{ $movies }';
  }
}
