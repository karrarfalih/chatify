import 'package:chatify/models/connection.dart';
import 'package:chatify/models/controller.dart';
import 'package:chatify/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kr_extensions/kr_extensions.dart';
import 'package:uuid/uuid.dart';

class SearchService {
  SearchService(
      {RxList<ChatUser>? selected, this.hasSuggestion = true, this.id})
      : selected = selected ?? <ChatUser>[].obs {
    init();
  }

  final bool hasSuggestion;
  final String? id;
  RxString searchTerm = ''.obs;
  RxBool isSearching = true.obs;

  RxList<ChatUser> suggestion = <ChatUser>[].obs;
  RxList<ChatUser> result = <ChatUser>[].obs;
  RxList<String> history = <String>[].obs;
  RxList<ChatUser> selected;

  init() async {
    if (hasSuggestion) {
      if (options.useConnections) {
        var res = await UserConnection.connections.limit(5).get();
        for (var e in res.docs.map((e) => e.data())) {
          ChatUser? account = await ChatUser.getById(e.targetUser);
          if (account != null) suggestion.add(account);
        }
      }
      if (suggestion.isEmpty) {
        var res = await options.userReference.limit(5).get();
        suggestion.addAll(res.docs.map((e) => e.data()));
      }
    }
    isSearching.value = false;
    if (id != null) loadHistory();
    searchTerm.listen((p0) {
      _search(p0);
    });
  }

  String _currentToken = '';
  _search(String searchTerm) async {
    isSearching.value = true;
    String token = const Uuid().v4();
    _currentToken = token;
    result.clear();
    if (searchTerm.isEmpty) {
      isSearching.value = false;
      return result.addAll(suggestion);
    }
    if (options.useConnections) {
      var res = await UserConnection.connectionsSearch(searchTerm.toLowerCase())
          .get();
      for (var e in res.docs.map((e) => e.data())) {
        if (_currentToken == token) {
          ChatUser? account = await ChatUser.getById(e.targetUser);
          if (account != null && _currentToken == token) result.add(account);
        }
      }
    }

    if (options.userData.searchTerms != null) {
      QuerySnapshot<ChatUser>? res2;
      if (_currentToken == token) {
        res2 =
            await UserConnection.accountSearch(searchTerm.toLowerCase()).get();
      }
      if (_currentToken == token) {
        result.addAll(res2!.docs
            .map((e) => e.data())
            .where((e) => !result.map((a) => a.id).contains(e.id)));
      }
      if (searchTerm.isPhoneNumber) {
        if (_currentToken == token) {
          res2 =
              await UserConnection.accountSearch(searchTerm.phoneLocally).get();
        }
        if (_currentToken == token) {
          result.addAll(res2!.docs
              .map((e) => e.data())
              .where((e) => !result.map((a) => a.id).contains(e.id)));
        }
      }
    } else {
      QuerySnapshot<ChatUser>? res2;
      if (_currentToken == token) {
        res2 = await options.userReference
            .where(options.userData.name, isEqualTo: searchTerm)
            .get();
      }
      if (_currentToken == token) {
        result.addAll(res2!.docs
            .map((e) => e.data())
            .where((e) => !result.map((a) => a.id).contains(e.id)));
      }
      if (options.userData.uid != null) {
        if (_currentToken == token) {
          res2 = await options.userReference
              .where(options.userData.uid!, isEqualTo: searchTerm)
              .get();
        }
        if (_currentToken == token) {
          result.addAll(res2!.docs
              .map((e) => e.data())
              .where((e) => !result.map((a) => a.id).contains(e.id)));
        }
      }
    }
    isSearching.value = false;
  }

  addResult(String id) {
    history.remove(id);
    history.insert(0, id);
    saveHistory();
  }

  clearResult(String id) {
    history.remove(id);
    saveHistory();
  }

  clearAll() {
    history.clear();
    saveHistory();
  }

  loadHistory() {
    List<String> e = List.from(GetStorage().read(id!) ?? []);
    if (e.length > 10) e = e.sublist(0, 10);
    history.addAll(e);
  }

  saveHistory() {
    GetStorage().write(id!, List.from(history.toSet()));
  }

  dispose() {
    searchTerm.close();
    result.close();
    history.close();
    isSearching.close();
    selected.close();
  }
}
