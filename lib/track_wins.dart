import 'package:shared_preferences/shared_preferences.dart';

// Get the number of wins from SharedPreferences
Future<int> getWinCount() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('win_count') ?? 0; // Default to 0 if not set
}

// Increment the number of wins
Future<void> incrementWinCount() async {
  final prefs = await SharedPreferences.getInstance();
  int winCount = await getWinCount();
  await prefs.setInt('win_count', winCount + 1);
  print(winCount);
}
