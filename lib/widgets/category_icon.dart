import 'package:flutter/material.dart';

/// Maps word categories to Material icons.
///
/// Every category gets an icon. If a new category is added
/// to the database and has no explicit mapping, the fallback
/// icon is used.
class CategoryIcon {
  CategoryIcon._();

  static const IconData _fallback = Icons.category_rounded;

  static const Map<String, IconData> _map = {
    'Food': Icons.restaurant_rounded,
    'Animals': Icons.pets_rounded,
    'Technology': Icons.devices_rounded,
    'Sports': Icons.sports_soccer_rounded,
    'Nature': Icons.eco_rounded,
    'Vehicles': Icons.directions_car_rounded,
    'School': Icons.menu_book_rounded,
    'Internet': Icons.language_rounded,
    'College': Icons.school_rounded,
    'Human Behaviour': Icons.psychology_rounded,
    'Movies': Icons.movie_rounded,
    'Music': Icons.music_note_rounded,
    'Places': Icons.place_rounded,
    'Professions': Icons.work_rounded,
    'Jobs': Icons.work_rounded,
    'Clothing': Icons.checkroom_rounded,
    'Household': Icons.home_rounded,
    'Games': Icons.sports_esports_rounded,
    'Weather': Icons.cloud_rounded,
    'Body': Icons.accessibility_new_rounded,
    'Emotions': Icons.emoji_emotions_rounded,
    'Colors': Icons.palette_rounded,
    'Science': Icons.science_rounded,
    'Random': Icons.shuffle_rounded,
    'Heroes & Superpowers': Icons.bolt_rounded,
    'Famous People': Icons.star_rounded,
    'Brands': Icons.local_offer_rounded,
    'Brand': Icons.local_offer_rounded,
  };

  /// Get the icon for a category name, case-insensitive.
  static IconData forCategory(String category) {
    // Try exact match first
    if (_map.containsKey(category)) return _map[category]!;

    // Try case-insensitive match
    final lower = category.toLowerCase();
    for (final entry in _map.entries) {
      if (entry.key.toLowerCase() == lower) return entry.value;
    }

    return _fallback;
  }
}
