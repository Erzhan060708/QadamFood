import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'favorite_bag_ids';

  static Future<Set<String>> getIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? <String>{};
  }

  static Future<bool> toggle(String bagId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key)?.toSet() ?? <String>{};
    final isFav = ids.contains(bagId);
    if (isFav) {
      ids.remove(bagId);
    } else {
      ids.add(bagId);
    }
    await prefs.setStringList(_key, ids.toList());
    return !isFav;
  }
}
