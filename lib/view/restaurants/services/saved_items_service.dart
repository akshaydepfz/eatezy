import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _savedProductIdsKey = 'saved_product_ids';

class SavedItemsService extends ChangeNotifier {
  Set<String> _savedIds = {};
  bool _loaded = false;

  Set<String> get savedIds => Set.unmodifiable(_savedIds);

  bool isSaved(String productId) => _savedIds.contains(productId);

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_savedProductIdsKey);
    _savedIds = list != null ? list.toSet() : {};
    _loaded = true;
  }

  Future<void> toggleSaved(String productId) async {
    await _ensureLoaded();
    if (_savedIds.contains(productId)) {
      _savedIds.remove(productId);
    } else {
      _savedIds.add(productId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedProductIdsKey, _savedIds.toList());
    notifyListeners();
  }

  Future<void> loadIfNeeded() async {
    await _ensureLoaded();
    notifyListeners();
  }
}
