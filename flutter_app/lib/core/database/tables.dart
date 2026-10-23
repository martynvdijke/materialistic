import 'package:drift/drift.dart';

@DataClassName('FavoriteRow')
class Favorites extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId => integer().unique()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get url => text().nullable()();
  IntColumn get time => integer().withDefault(const Constant(0))();
}

@DataClassName('ReadItemRow')
class ReadItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId => integer().unique()();
}

@DataClassName('ReadableItemRow')
class ReadableItems extends Table {
  IntColumn get itemId => integer()();
  TextColumn get content => text()();

  @override
  Set<Column<Object>> get primaryKey => {itemId};
}

@DataClassName('SearchHistoryRow')
class SearchHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get query => text().unique()();
  IntColumn get time => integer().withDefault(const Constant(0))();
}
