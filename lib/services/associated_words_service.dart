import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/associated_word.dart';

/// Manages the Associated Word Database.
///
/// Contains built-in associated words (protected) and user-added associated words
/// (persisted in [SharedPreferences]). Does NOT store player names.
class AssociatedWordsService extends ChangeNotifier {
  static const String _storageKey = 'user_associated_words_data';

  /// Built-in generic words that can be associated with any player.
  /// These cannot be edited or deleted by the user.
  static final List<AssociatedWord> _builtInWords = [
    'Bike',
    'Car',
    'Phone',
    'Laptop',
    'House',
    'Dog',
    'Room',
    'College',
    'School',
    'Watch',
    'Shoes',
    'Gaming PC',
    'Backpack',
    'Secret',
    'Crush',
    'Diary',
    'Playlist',
    'Jacket',
    'Glasses',
    'Camera',
    'Perfume',
    'Headphones',
    'Wallet',
    'Guitar',
    'Key',
    'Bicycle',
  ]
      .asMap()
      .entries
      .map(
        (entry) => AssociatedWord(
          id: 'builtin_assoc_${entry.key}',
          text: entry.value,
          isBuiltIn: true,
          createdAt: DateTime(2025, 1, 1),
        ),
      )
      .toList();

  final List<AssociatedWord> _userWords = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<AssociatedWord> get builtInWords => List.unmodifiable(_builtInWords);
  List<AssociatedWord> get userWords => List.unmodifiable(_userWords);

  /// All associated words (built-in + user-added).
  List<AssociatedWord> get allWords =>
      List.unmodifiable([..._userWords, ..._builtInWords]);

  int get totalCount => _builtInWords.length + _userWords.length;
  int get userCount => _userWords.length;

  /// Load custom words from local storage.
  Future<void> loadWords() async {
    if (_isLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _userWords.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _userWords.add(AssociatedWord.fromJson(item));
          }
        }
      }
    } catch (e) {
      debugPrint('AssociatedWordsService: Error loading words: $e');
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Save user-added words to local storage.
  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_userWords.map((w) => w.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('AssociatedWordsService: Error saving words: $e');
    }
  }

  /// Check if a word already exists in built-in or user-added words (case-insensitive).
  bool hasWord(String text, {String? excludeId}) {
    final trimmed = text.trim().toLowerCase();
    final inBuiltIn = _builtInWords.any(
      (w) => w.id != excludeId && w.text.trim().toLowerCase() == trimmed,
    );
    if (inBuiltIn) return true;

    return _userWords.any(
      (w) => w.id != excludeId && w.text.trim().toLowerCase() == trimmed,
    );
  }

  /// Add a new user-created associated word. Returns null on success or an error message.
  Future<String?> addUserWord(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return 'Word cannot be empty';
    }
    if (hasWord(trimmed)) {
      return 'Word already exists in Associated Words';
    }

    final id =
        'user_assoc_${DateTime.now().millisecondsSinceEpoch}_${_userWords.length}';
    final newWord = AssociatedWord(
      id: id,
      text: trimmed,
      isBuiltIn: false,
      createdAt: DateTime.now(),
    );

    _userWords.insert(0, newWord);
    await _save();
    notifyListeners();
    return null;
  }

  /// Edit an existing user-created word by ID. Returns null on success or an error message.
  Future<String?> editUserWord(String id, String newText) async {
    final trimmed = newText.trim();
    if (trimmed.isEmpty) {
      return 'Word cannot be empty';
    }

    // Protect built-in words
    if (_builtInWords.any((w) => w.id == id)) {
      return 'Cannot edit built-in words';
    }

    if (hasWord(trimmed, excludeId: id)) {
      return 'Word already exists in Associated Words';
    }

    final index = _userWords.indexWhere((w) => w.id == id);
    if (index == -1) {
      return 'Word not found';
    }

    _userWords[index] = _userWords[index].copyWith(text: trimmed);
    await _save();
    notifyListeners();
    return null;
  }

  /// Delete a user-created word by ID. Cannot delete built-in words.
  Future<bool> deleteUserWord(String id) async {
    // Protect built-in words
    if (_builtInWords.any((w) => w.id == id)) {
      return false;
    }

    final index = _userWords.indexWhere((w) => w.id == id);
    if (index == -1) return false;

    _userWords.removeAt(index);
    await _save();
    notifyListeners();
    return true;
  }
}
