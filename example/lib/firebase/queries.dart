part of 'datasource.dart';

extension FirestoreQueries on Datasource {
  Query<User> get users => _collections.users;
  Query<User> userSearch(String searchTerms) =>
      _collections.users.where('searchTerms', arrayContains: searchTerms);
}
