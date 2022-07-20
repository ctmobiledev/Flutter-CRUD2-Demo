// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_genre_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class MovieGenreModel extends _MovieGenreModel with RealmEntity, RealmObject {
  static var _defaultsSet = false;

  MovieGenreModel({
    int? id = -1,
    String? movieGenreName,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObject.setDefaults<MovieGenreModel>({
        'id': -1,
      });
    }
    RealmObject.set(this, 'id', id);
    RealmObject.set(this, 'movieGenreName', movieGenreName);
  }

  MovieGenreModel._();

  @override
  int? get id => RealmObject.get<int>(this, 'id') as int?;
  @override
  set id(int? value) => RealmObject.set(this, 'id', value);

  @override
  String? get movieGenreName =>
      RealmObject.get<String>(this, 'movieGenreName') as String?;
  @override
  set movieGenreName(String? value) =>
      RealmObject.set(this, 'movieGenreName', value);

  @override
  Stream<RealmObjectChanges<MovieGenreModel>> get changes =>
      RealmObject.getChanges<MovieGenreModel>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(MovieGenreModel._);
    return const SchemaObject(MovieGenreModel, 'MovieGenreModel', [
      SchemaProperty('id', RealmPropertyType.int, optional: true),
      SchemaProperty('movieGenreName', RealmPropertyType.string,
          optional: true),
    ]);
  }
}
