import 'dart:async';
import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/utils/uuid.dart';
import 'package:chatify/src/utils/value_notifiers.dart';

class SearchController {
  final query = ''.obs;
  final isSearching = false.obs;
  final results = <ChatifyUser>[].obs;
  final history = <ChatifyUser>[].obs;

  Timer? _debounceTimer;

  SearchController() {
    _search('');
    query.addListener(() {
      if (_debounceTimer != null && _debounceTimer!.isActive) {
        _debounceTimer!.cancel();
      }
      _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
        _search(query.value);
      });
    });
  }

  String _currentId = '';

  _search(String query) async {
    print(query);
    isSearching.value = true;
    final id = Uuid.generate();
    _currentId = id;
    results.value.clear();
    final res = await Chatify.config.getUsersBySearch!(query);
    if (_currentId == id) {
      results.value = res;
      isSearching.value = false;
    }
  }

  dispose() {
    query.dispose();
    isSearching.dispose();
    results.dispose();
    history.dispose();
    _debounceTimer?.cancel();
  }
}
