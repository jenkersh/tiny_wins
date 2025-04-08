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
      builder: (_) =>
          Confetti(
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
      builder: (_) =>
          Confetti(
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


  List<List<Widget>> _buildWeekRows() {
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final totalDays = DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);

    final List<List<Widget>> weeks = [];
    int startingWeekday = firstDayOfMonth.weekday % 7;

    for (int i = 0; i < 42; i++) {
      int dayNumber = i - startingWeekday + 1;
      DateTime date = DateTime(_selectedMonth.year, _selectedMonth.month, 1).add(Duration(days: dayNumber - 1));

      Widget dayWidget;
      if (dayNumber < 1 || dayNumber > totalDays) {
        dayWidget = const SizedBox(width: 40);
      } else if (winsByDate[date] != null) {
        final win = winsByDate[date]!;
        dayWidget = GestureDetector(
          onTap: () {
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
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
              Text('$dayNumber', style: const TextStyle(fontSize: 16)),
            ],
          ),
        );
      } else {
        dayWidget = const SizedBox(width: 40);
      }

      int weekIndex = i ~/ 7;
      if (weeks.length <= weekIndex) {
        weeks.add([]);
      }
      weeks[weekIndex].add(dayWidget);
    }

    return weeks;
  }



  @override
  Widget build(BuildContext context) {
    final weekRows = _buildWeekRows();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🔼 Month Selector with Arrows
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _goToPreviousMonth,
                  ),
                  Text(
                    DateFormat.yMMMM().format(_selectedMonth),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _goToNextMonth,
                  ),
                ],
              ),
            ),

            // 🏆 Trophy Shelves
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final rowHeight = constraints.maxHeight / 6;

                    return Column(
                      children: List.generate(weekRows.length, (i) {
                        final row = weekRows[i];

                        return SizedBox(
                          height: rowHeight,
                          child: Column(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: row,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 8,
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
                            ],
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToLogWinScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}