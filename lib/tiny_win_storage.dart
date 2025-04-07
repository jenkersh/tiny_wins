import 'package:shared_preferences/shared_preferences.dart';
import 'tiny_win_model.dart';

class TinyWinStorage {
  static const String _key = 'tiny_wins';

  // Save a list of TinyWin
  static Future<void> saveWins(List<TinyWin> wins) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = wins.map((win) => win.toJson()).toList();
    await prefs.setStringList(_key, jsonList);
  }

  // Load saved wins
  static Future<List<TinyWin>> loadWins() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_key);
    if (jsonList == null) return [];

    return jsonList.map((json) => TinyWin.fromJson(json)).toList();
  }

  // Add a new win
  static Future<void> addWin(TinyWin newWin) async {
    final wins = await loadWins();
    wins.add(newWin);
    await saveWins(wins);
  }

  // Optional: clear all
  static Future<void> clearWins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
