import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/my_word.dart';

/// Manages local user-created custom words ("My Words").
///
/// Persists words in [SharedPreferences]. Empty by default.
class MyWordsService extends ChangeNotifier {
  static const String _storageKey = 'my_words_data';

  final List<MyWord> _words = [];
  bool _isLoaded = false;

  List<MyWord> get words => List.unmodifiable(_words);
  bool get isLoaded => _isLoaded;
  int get count => _words.length;

  /// Load words from local storage.
  Future<void> loadWords() async {
    if (_isLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _words.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _words.add(MyWord.fromJson(item));
          }
        }
      }
    } catch (e) {
      debugPrint('MyWordsService: Error loading words: $e');
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Save current words to local storage.
  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_words.map((w) => w.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('MyWordsService: Error saving words: $e');
    }
  }

  /// Check if a word already exists (case-insensitive).
  bool hasWord(String text, {String? excludeId}) {
    final trimmed = text.trim().toLowerCase();
    return _words.any(
      (w) => w.id != excludeId && w.text.trim().toLowerCase() == trimmed,
    );
  }

  /// Add a new custom word. Returns null on success or an error message.
  Future<String?> addWord(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return 'Word cannot be empty';
    }
    if (hasWord(trimmed)) {
      return 'Word already exists in My Words';
    }

    final id = 'my_word_${DateTime.now().millisecondsSinceEpoch}_${_words.length}';
    final newWord = MyWord(
      id: id,
      text: trimmed,
      createdAt: DateTime.now(),
    );

    _words.insert(0, newWord);
    await _save();
    notifyListeners();
    return null;
  }

  /// Edit an existing word by ID. Returns null on success or an error message.
  Future<String?> editWord(String id, String newText) async {
    final trimmed = newText.trim();
    if (trimmed.isEmpty) {
      return 'Word cannot be empty';
    }
    if (hasWord(trimmed, excludeId: id)) {
      return 'Word already exists in My Words';
    }

    final index = _words.indexWhere((w) => w.id == id);
    if (index == -1) {
      return 'Word not found';
    }

    _words[index] = _words[index].copyWith(text: trimmed);
    await _save();
    notifyListeners();
    return null;
  }

  /// Delete a word by ID.
  Future<bool> deleteWord(String id) async {
    final index = _words.indexWhere((w) => w.id == id);
    if (index == -1) return false;

    _words.removeAt(index);
    await _save();
    notifyListeners();
    return true;
  }
}
