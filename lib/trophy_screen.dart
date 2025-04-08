import 'package:flutter/material.dart';
import 'package:tiny_wins/tiny_win_storage.dart';
import 'log_screen.dart';
import 'tiny_win_model.dart'; // Your model for logged wins
import 'package:intl/intl.dart';
import 'package:tiny_wins/confetti.dart';

class TrophyScreen extends StatefulWidget {
  const TrophyScreen({super.key});

  @override
  State<TrophyScreen> createState() => _TrophyScreenState();
}

class _TrophyScreenState extends State<TrophyScreen> {
  DateTime _selectedMonth = DateTime.now();
  Map<DateTime, TinyWin> winsByDate = {
    DateTime(2025, 2, 28): TinyWin(date: DateTime(2025, 2, 28), message: "Completed a new project task!"),
    DateTime(2025, 3, 1): TinyWin(date: DateTime(2025, 3, 1), message: "Completed a new project task!"),
    DateTime(2025, 4, 1): TinyWin(date: DateTime(2025, 4, 1), message: "Completed a new project task!"),
    DateTime(2025, 4, 2): TinyWin(date: DateTime(2025, 4, 2), message: "Woke up early and stretched."),
    DateTime(2025, 4, 3): TinyWin(date: DateTime(2025, 4, 3), message: "Cooked a healthy breakfast."),
    DateTime(2025, 4, 4): TinyWin(date: DateTime(2025, 4, 4), message: "Took a 30-minute walk today!"),
    DateTime(2025, 4, 5): TinyWin(date: DateTime(2025, 4, 5), message: "Ate a healthy lunch!"),
    DateTime(2025, 4, 6): TinyWin(date: DateTime(2025, 4, 6), message: "Read a chapter of a book!"),
    DateTime(2025, 4, 7): TinyWin(date: DateTime(2025, 4, 7), message: "Cleaned out an email inbox."),
    DateTime(2025, 4, 8): TinyWin(date: DateTime(2025, 4, 8), message: "Listened to a podcast."),
    DateTime(2025, 4, 9): TinyWin(date: DateTime(2025, 4, 9), message: "Tried a new recipe."),
    DateTime(2025, 4, 10): TinyWin(date: DateTime(2025, 4, 10), message: "Completed a workout session!"),
    DateTime(2025, 4, 11): TinyWin(date: DateTime(2025, 4, 11), message: "Called a friend just to say hi."),
    DateTime(2025, 4, 12): TinyWin(date: DateTime(2025, 4, 12), message: "Decluttered my workspace."),
    DateTime(2025, 4, 13): TinyWin(date: DateTime(2025, 4, 13), message: "Meditated for 10 minutes!"),
    DateTime(2025, 4, 14): TinyWin(date: DateTime(2025, 4, 14), message: "Had a productive workday!"),
    DateTime(2025, 4, 15): TinyWin(date: DateTime(2025, 4, 15), message: "Helped someone today."),
    DateTime(2025, 4, 16): TinyWin(date: DateTime(2025, 4, 16), message: "Took a mindful break."),
    DateTime(2025, 4, 17): TinyWin(date: DateTime(2025, 4, 17), message: "Organized my workspace!"),
    DateTime(2025, 4, 18): TinyWin(date: DateTime(2025, 4, 18), message: "Did something creative."),
    DateTime(2025, 4, 19): TinyWin(date: DateTime(2025, 4, 19), message: "Went screen-free for an hour."),
    DateTime(2025, 4, 20): TinyWin(date: DateTime(2025, 4, 20), message: "Took a break and stretched!"),
    DateTime(2025, 4, 21): TinyWin(date: DateTime(2025, 4, 21), message: "Drank enough water today."),
    DateTime(2025, 4, 22): TinyWin(date: DateTime(2025, 4, 22), message: "Learned something new today!"),
    DateTime(2025, 4, 23): TinyWin(date: DateTime(2025, 4, 23), message: "Wrote in my journal."),
    DateTime(2025, 4, 24): TinyWin(date: DateTime(2025, 4, 24), message: "Tidied up the living room."),
    DateTime(2025, 4, 25): TinyWin(date: DateTime(2025, 4, 25), message: "Watched a sunset."),
    DateTime(2025, 4, 26): TinyWin(date: DateTime(2025, 4, 26), message: "Laughed really hard today."),
    DateTime(2025, 4, 27): TinyWin(date: DateTime(2025, 4, 27), message: "Planned something fun."),
    DateTime(2025, 4, 28): TinyWin(date: DateTime(2025, 4, 28), message: "Reflected on recent wins."),
    DateTime(2025, 4, 29): TinyWin(date: DateTime(2025, 4, 29), message: "Listened to my favorite song."),
    DateTime(2025, 4, 30): TinyWin(date: DateTime(2025, 4, 30), message: "Completed a challenging task at work!"),
  };


  @override
  void initState() {
    super.initState();
    _loadWins();
  }

  void _loadWins() async {
    final savedWins = await TinyWinStorage.loadWins();
    setState(() {
      for (var win in savedWins) {
        winsByDate[DateTime(win.date.year, win.date.month, win.date.day)] = win;
      }
    });
  }


  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  void _saveWin(DateTime date, String message) {
    final win = TinyWin(date: date, message: message);
    TinyWinStorage.addWin(win); // Save to shared preferences
    setState(() {
      winsByDate[DateTime(date.year, date.month, date.day)] = win; // Save locally for UI
    });
  }


  Future<void> _navigateToLogWinScreen() async {
    final winText = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LogScreen()),
    );

    if (winText != null && winText is String && winText.isNotEmpty) {
      _saveWin(DateTime.now(), winText); // Save the win
      final streak = calculateCurrentStreak(); // Your logic to calculate streak
      _showConfettiDialog(winText, streak);
    }
  }


  int calculateCurrentStreak() {
    DateTime today = DateTime.now();
    DateTime currentDay = DateTime(today.year, today.month, today.day);

    int streak = 0;

    while (winsByDate.containsKey(currentDay)) {
      streak++;
      currentDay = currentDay.subtract(const Duration(days: 1));
    }

    return streak;
  }

  void _showConfettiDialog(String winText, int streakCount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Confetti(
        child: AlertDialog(
          title: const Text("🎉 Congratulations!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 50, color: Colors.amber),
              const SizedBox(height: 16),
              Text("Today I... $winText", textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close confetti
                if (streakCount >= 1) {
                  _showStreakDialog(streakCount); // Then show streak
                }
              },
              child: const Text("Awesome!"),
            ),
          ],
        ),
      ),
    );
  }

  void _showStreakDialog(int streakCount) {
    showDialog(
      context: context,
      builder: (_) => Confetti(
        child: AlertDialog(
          title: const Text("🔥 Streak Alert!"),
          content: Text("You're on a $streakCount-day streak! Keep it going!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Keep Winning!"),
            ),
          ],
        ),
      ),
    );
  }


  List<Widget> _buildTrophyShelves() {
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final totalDays = DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);

    final List<Widget> shelves = [];

    int dayCounter = 1;
    int weekdayOffset = (firstDayOfMonth.weekday % 7); // 0 = Sunday, 6 = Saturday

    while (dayCounter <= totalDays) {
      List<Widget> currentRow = [];

      // Fill empty slots before the first day of the week (only for first row)
      if (shelves.isEmpty) {
        for (int i = 0; i < weekdayOffset; i++) {
          currentRow.add(const SizedBox(width: 50));
        }
      }

      // Fill the rest of the week
      for (int i = currentRow.length; i < 7; i++) {
        if (dayCounter > totalDays) {
          currentRow.add(const SizedBox(width: 50)); // End of month gap
        } else {
          final date = DateTime(_selectedMonth.year, _selectedMonth.month, dayCounter);
          currentRow.add(
            winsByDate[date] != null
                ? GestureDetector(
              onTap: () {
                final win = winsByDate[date];
                if (win != null) {
                  showDialog(
                    context: context,
                    builder: (_) => Confetti(
                      child: AlertDialog(
                        title: const Text("🏆 Tiny Win"),
                        content: Text(win.message),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Nice!"),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
                  Text('$dayCounter', style: const TextStyle(fontSize: 16)),
                ],
              ),
            )
                : const SizedBox(width: 50, height: 0), // No win
          );
          dayCounter++;
        }
      }

      // Is this the first or last row?
      final isFirstRow = shelves.isEmpty;
      final isLastRow = dayCounter > totalDays;

      shelves.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16), // padding from screen edge
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 7 * 50.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: currentRow,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: isFirstRow ? (weekdayOffset * 50.0) : 0,
                  right: isLastRow
                      ? ((7 - currentRow.where((w) => w is! SizedBox).length) * 50.0)
                      : 0,
                ),
                child: Container(
                  height: 8,
                  width: 7 * 50.0,
                  decoration: BoxDecoration(
                    color: Colors.brown[200],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 4,
                        color: Colors.black26,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      // Reset offset after first row
      weekdayOffset = 0;
    }

    return shelves;
  }



  @override
  Widget build(BuildContext context) {
    final monthFormat = DateFormat('MMMM yyyy');

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goToPreviousMonth),
                Text(monthFormat.format(_selectedMonth), style: const TextStyle(fontSize: 20)),
                IconButton(icon: const Icon(Icons.arrow_forward), onPressed: _goToNextMonth),
              ],
            ),
          ),
          // No scrolling here
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              children: _buildTrophyShelves(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToLogWinScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}