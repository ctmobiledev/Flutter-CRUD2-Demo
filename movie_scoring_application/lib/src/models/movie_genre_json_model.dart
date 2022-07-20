// NOTE: This class is NOT marked as a Realm Object, so Realm happily ignored it.
// It only exists for one purpose, and that's the backup/restore of data from a Realm object/table.
// It will NOT be used to display anything in the UI.
// It DOES have the exact same properties as _MovieModel (private) and MovieModel (public).
//

class MovieGenreModelJson {
  int? id = -1;
  String? movieGenreName;

  MovieGenreModelJson(int pId, String pGenre) {
    id = pId;
    movieGenreName = pGenre;
  }

  Map toJson() => {
        //
        'id': id,
        //
        'movieGenreName': movieGenreName
        //
      };

  factory MovieGenreModelJson.fromJson(dynamic json) {
    return MovieGenreModelJson(
      json['id'] as int,
      json['movieGenreName'] as String,
    );
  }

  @override
  String toString() {
    return '{ $id, $movieGenreName }';
  }
}
