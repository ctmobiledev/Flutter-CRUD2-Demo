// NOTE: This class is NOT marked as a Realm Object, so Realm happily ignored it.
// It only exists for one purpose, and that's the backup/restore of data from a Realm object/table.
// It will NOT be used to display anything in the UI.
// It DOES have the exact same properties as _MovieModel (private) and MovieModel (public).
//
class MovieModelJson {
  int? id = -1;
  String? entryTimestamp;
  String? entryDayOfWeek;
  String? movieTitle;
  String? movieGenre;
  int movieScore = -1;

  MovieModelJson(int pId, String pTimestamp, String pDay, String pTitle,
      String pGenre, int pScore) {
    id = pId;
    entryTimestamp = pTimestamp;
    entryDayOfWeek = pDay;
    movieTitle = pTitle;
    movieGenre = pGenre;
    movieScore = pScore;
  }

  Map toJson() => {
        'id': id,
        'entryTimestamp': entryTimestamp,
        'entryDayOfWeek': entryDayOfWeek,
        'movieTitle': movieTitle,
        'movieGenre': movieGenre,
        'movieScore': movieScore
      };

  factory MovieModelJson.fromJson(dynamic json) {
    return MovieModelJson(
        json['id'] as int,
        json['entryTimestamp'] as String,
        json['entryDayOfWeek'] as String,
        json['movieTitle'] as String,
        json['movieGenre'] as String,
        json['movieScore'] as int);
  }

  @override
  String toString() {
    return '{ $id, $entryTimestamp, $entryDayOfWeek, $movieTitle, $movieGenre, $movieScore }';
  }
}
