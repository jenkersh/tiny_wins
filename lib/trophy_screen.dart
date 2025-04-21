import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tiny_wins/share_button.dart';
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
    // DateTime(2025, 4, 8): TinyWin(date: DateTime(2025, 4, 8), message: "Listened to a podcast."),
    // DateTime(2025, 4, 9): TinyWin(date: DateTime(2025, 4, 9), message: "Tried a new recipe."),
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
  final ScreenshotController _screenshotController = ScreenshotController();

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

  Widget buildScreenshotContainer(String winText) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          color: Colors.white,
          alignment: Alignment.center,
          height: 400,
          width: 400,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🏆 Tiny Win!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '"$winText"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/trophy.png',
                    height: 80,
                  ),
                ],
              ),
            ],
          ),
        ),
        const Positioned(
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Made with ❤️', style: TextStyle(fontSize: 10)),
              Text('Tiny Wins', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
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
                Navigator.pop(context);
                if (streakCount >= 1) {
                  _showStreakDialog(streakCount);
                }
              },
              child: const Text("Awesome!"),
            ),
            ShareButton(
              winText: winText,
              screenshotController: _screenshotController,
              context: context,
              screenshotContainer: buildScreenshotContainer(winText),
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


  List<List<Widget>> _buildWeekRows(double cellWidth) {
    final year = _selectedMonth.year;
    final month = _selectedMonth.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);

    // Determine the first visible day (start of the calendar grid)
    final int startOffset = firstDayOfMonth.weekday % 7; // Sunday = 0
    DateTime current = firstDayOfMonth.subtract(Duration(days: startOffset));

    final List<List<Widget>> weekRows = [];

    while (current.isBefore(lastDayOfMonth) || current.isAtSameMomentAs(lastDayOfMonth)) {
      final List<Widget> week = [];

      for (int i = 0; i < 7; i++) {
        if (current.month != month) {
          // Fill in blank spaces for days outside current month
          week.add(SizedBox(width: cellWidth));
        } else if (winsByDate[current] != null) {
          final win = winsByDate[current]!;
          week.add(
            GestureDetector(
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
                        ShareButton(context: context, winText: win.message, screenshotController: _screenshotController, screenshotContainer: buildScreenshotContainer(win.message),),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                width: cellWidth,
                height: cellWidth,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      bottom: cellWidth * -0.1,
                        child: Icon(Icons.emoji_events, color: Colors.amber, size: cellWidth)),
                    Positioned(
                      bottom: cellWidth * 0.32,
                      child: Text(
                        '${current.day}',
                        style: TextStyle(
                          fontSize: cellWidth * 0.3,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // or white for contrast
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ),
          );
        } else {
          week.add(SizedBox(width: cellWidth));
        }

        current = current.add(const Duration(days: 1));
      }

      weekRows.add(week);
    }

    return weekRows;
  }


  List<Widget> _buildTrophyShelves(List<List<Widget>> weekRows, double cellWidth) {
    final List<Widget> shelves = [];

    final year = _selectedMonth.year;
    final month = _selectedMonth.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);

    final int startOffset = firstDayOfMonth.weekday % 7;
    final int endWeekday = lastDayOfMonth.weekday % 7;

    //const double cellWidth = 40.0;

    for (int weekIndex = 0; weekIndex < weekRows.length; weekIndex++) {
      int leftPadding = 0;
      int rightPadding = 0; // Padding for the last shelf

      int visibleDays = 7;

      if (weekIndex == 0) {
        // First week: pad from the left based on the weekday of the 1st
        leftPadding = startOffset;
        visibleDays = 7 - startOffset;
      } else if (weekIndex == weekRows.length - 1) {
        // Last week: show only up to the last date's weekday
        leftPadding = 0;
        visibleDays = endWeekday + 1;

        // Add right padding to align the shelf properly when it's a shorter week
        rightPadding = 7 - visibleDays;
      }

      shelves.add(
        Padding(
          padding: EdgeInsets.only(left: leftPadding * cellWidth, right: rightPadding * cellWidth),
          child: Container(
            width: visibleDays * cellWidth,
            height: cellWidth * 0.2,
            color: Colors.brown,
            //margin: const EdgeInsets.only(top: 0),
          ),
        ),
      );
    }

    return shelves;
  }

  void _handleHorizontalSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    if (details.primaryVelocity! < 0) {
      // Swipe left → go to next month
      _goToNextMonth();
    } else if (details.primaryVelocity! > 0) {
      // Swipe right → go to previous month
      _goToPreviousMonth();
    }
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double totalWidth = constraints.maxWidth - 80; // 40 padding each side
          double cellWidth = totalWidth / 7;

          final weekRows = _buildWeekRows(cellWidth);
          final trophyShelves = _buildTrophyShelves(weekRows, cellWidth);

          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
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
                    child: Column(
                      children: List.generate(weekRows.length, (index) {
                        return Column(
                          children: [
                            SizedBox(height: cellWidth * .6),
                            Container(
                              height: cellWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: weekRows[index],
                              ),
                            ),
                            trophyShelves[index],
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToLogWinScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}