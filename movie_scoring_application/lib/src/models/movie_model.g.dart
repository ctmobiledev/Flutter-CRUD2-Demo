// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class MovieModel extends _MovieModel with RealmEntity, RealmObject {
  static var _defaultsSet = false;

  MovieModel({
    int? id = -1,
    String? entryTimestamp,
    String? entryDayOfWeek,
    String? movieTitle,
    String? movieGenre,
    int movieScore = -1,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObject.setDefaults<MovieModel>({
        'id': -1,
        'movieScore': -1,
      });
    }
    RealmObject.set(this, 'id', id);
    RealmObject.set(this, 'entryTimestamp', entryTimestamp);
    RealmObject.set(this, 'entryDayOfWeek', entryDayOfWeek);
    RealmObject.set(this, 'movieTitle', movieTitle);
    RealmObject.set(this, 'movieGenre', movieGenre);
    RealmObject.set(this, 'movieScore', movieScore);
  }

  MovieModel._();

  @override
  int? get id => RealmObject.get<int>(this, 'id') as int?;
  @override
  set id(int? value) => RealmObject.set(this, 'id', value);

  @override
  String? get entryTimestamp =>
      RealmObject.get<String>(this, 'entryTimestamp') as String?;
  @override
  set entryTimestamp(String? value) =>
      RealmObject.set(this, 'entryTimestamp', value);

  @override
  String? get entryDayOfWeek =>
      RealmObject.get<String>(this, 'entryDayOfWeek') as String?;
  @override
  set entryDayOfWeek(String? value) =>
      RealmObject.set(this, 'entryDayOfWeek', value);

  @override
  String? get movieTitle =>
      RealmObject.get<String>(this, 'movieTitle') as String?;
  @override
  set movieTitle(String? value) => RealmObject.set(this, 'movieTitle', value);

  @override
  String? get movieGenre =>
      RealmObject.get<String>(this, 'movieGenre') as String?;
  @override
  set movieGenre(String? value) => RealmObject.set(this, 'movieGenre', value);

  @override
  int get movieScore => RealmObject.get<int>(this, 'movieScore') as int;
  @override
  set movieScore(int value) => RealmObject.set(this, 'movieScore', value);

  @override
  Stream<RealmObjectChanges<MovieModel>> get changes =>
      RealmObject.getChanges<MovieModel>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(MovieModel._);
    return const SchemaObject(MovieModel, 'MovieModel', [
      SchemaProperty('id', RealmPropertyType.int, optional: true),
      SchemaProperty('entryTimestamp', RealmPropertyType.string,
          optional: true),
      SchemaProperty('entryDayOfWeek', RealmPropertyType.string,
          optional: true),
      SchemaProperty('movieTitle', RealmPropertyType.string, optional: true),
      SchemaProperty('movieGenre', RealmPropertyType.string, optional: true),
      SchemaProperty('movieScore', RealmPropertyType.int),
    ]);
  }
}
