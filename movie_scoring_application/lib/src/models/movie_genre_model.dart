import 'package:realm/realm.dart';
part 'movie_genre_model.g.dart';

@RealmModel()
class _MovieGenreModel {
  int? id = -1;
  String? movieGenreName;
}
