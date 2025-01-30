// lib/storage/storage_userdata.dart

import 'package:shared_preferences/shared_preferences.dart';

class UserDataStorage {
  static const String _languageKey = 'selectedLanguage';
  static const String _categoryKey = 'selectedCategory';

  // Singleton instance
  static UserDataStorage? _instance;
  static SharedPreferences? _preferences;

  // Private constructor
  UserDataStorage._();

  // Getter for singleton instance
  static Future<UserDataStorage> getInstance() async {
    if (_instance == null) {
      _instance = UserDataStorage._();
      _preferences = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Save selected language
  Future<bool> saveLanguage(String language) async {
    return await _preferences?.setString(_languageKey, language) ?? false;
  }

  // Get selected language
  String getLanguage() {
    return _preferences?.getString(_languageKey) ?? 'en-IN';
  }

  // Save selected category
  Future<bool> saveCategory(String category) async {
    return await _preferences?.setString(_categoryKey, category) ?? false;
  }

  // Get selected category
  String? getCategory() {
    return _preferences?.getString(_categoryKey);
  }

  // Clear all stored data
  Future<bool> clearAll() async {
    return await _preferences?.clear() ?? false;
  }
}
