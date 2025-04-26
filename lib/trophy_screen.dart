import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:speech_bubble/speech_bubble.dart';
import 'package:tiny_wins/notification_service.dart';
import 'package:tiny_wins/share_button.dart';
import 'package:tiny_wins/tiny_win_storage.dart';
import 'log_screen.dart';
import 'tiny_win_model.dart'; // Your model for logged wins
import 'package:intl/intl.dart';
import 'package:tiny_wins/confetti.dart';
import 'package:intl/intl.dart';

class TrophyScreen extends StatefulWidget {
  const TrophyScreen({super.key});

  @override
  State<TrophyScreen> createState() => _TrophyScreenState();
}

class _TrophyScreenState extends State<TrophyScreen> {
  DateTime _selectedMonth = DateTime.now();
  Map<DateTime, TinyWin> winsByDate = {};
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _loadWins();
  }

  void _handleLogWinTap() {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day); // Normalize to ignore time

    if (winsByDate.containsKey(todayKey)) {
      // Already logged a win today
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Win Already Logged'),
          content: const Text(
            "You've already logged a win for today!\n\n"
                "Press and hold today's trophy if you'd like to edit or delete it.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.deepOrange, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      // No win today, allow user to log
      _navigateToLogWinScreen();
    }
  }

  void _showWinDialog(TinyWin win) {
    final formattedDate = DateFormat.yMMMMd().format(win.date);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Confetti(
        child: Stack(
          children: [
            AlertDialog(
              elevation: 0,
              contentPadding: const EdgeInsets.all(30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: SpeechBubble(
                          nipLocation: NipLocation.BOTTOM,
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: 12,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "On ${DateFormat('MMMM d').format(win.date)}, you logged: \n",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                ),
                                TextSpan(
                                  text: win.message,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                const TextSpan(
                                  text: "\n That was great!",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Image.asset('images/mascot.png', height: 120),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ShareButton(
                    context: context,
                    winText: win.message,
                    screenshotController: _screenshotController,
                    screenshotContainer: buildScreenshotContainer(win.message),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.black26,
                  child: Icon(Icons.close, size: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDeleteDialog(TinyWin win) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit or Delete Win'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose an option below!'),
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _editWin(win);
                    },
                    child: const Text('Edit', style: TextStyle(color: Colors.deepOrange, fontSize: 16)),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDeleteWin(win); // Show confirmation before deleting
                    },
                    child: const Text('Delete', style: TextStyle(color: Colors.deepOrange, fontSize: 16)),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.deepOrange, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteWin(TinyWin win) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Win?'),
        content: const Text('Are you sure you want to delete this tiny win?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close confirm dialog
              _deleteWin(win); // Actually delete
            },
            child: const Text('Yes, Delete', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context), // Just close confirm dialog
            child: const Text('Cancel', style: TextStyle(color: Colors.deepOrange, fontSize: 16)),
          ),
        ],
      ),
    );
  }


  void _editWin(TinyWin win) async {
    TextEditingController controller = TextEditingController(text: win.message);

    final newMessage = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Win'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 100,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 24),
              onPressed: () {
                controller.clear(); // Clears the text
              },
            ),
            hintText: 'Edit your tiny win...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save', style: TextStyle(color: Colors.deepOrange, fontSize: 16)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.deepOrange, fontSize: 16)),
          ),
        ],
      ),
    );

    if (newMessage != null && newMessage.trim().isNotEmpty) {
      final updatedWin = TinyWin(
        date: win.date,
        message: newMessage.trim(),
      );

      setState(() {
        // ✅ Normalize the date when updating the map
        winsByDate[normalizeDate(win.date)] = updatedWin;
      });

      // ✅ Save the updated wins list
      await TinyWinStorage.saveWins(winsByDate.values.toList());
    }
  }


  void _deleteWin(TinyWin win) async {
    winsByDate.remove(normalizeDate(win.date)); // ✅ Normalize before removing
    await TinyWinStorage.saveWins(winsByDate.values.toList());
    setState(() {});
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
    HapticFeedback.selectionClick();
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    HapticFeedback.selectionClick();
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
    HapticFeedback.lightImpact();
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
    // Clean up winText to remove trailing punctuation if any
    String cleanedWinText = winText.trim();
    if (cleanedWinText.isNotEmpty &&
        (cleanedWinText.endsWith('.') ||
            cleanedWinText.endsWith('!') ||
            cleanedWinText.endsWith(',') ||
            cleanedWinText.endsWith('?'))) {
      cleanedWinText = cleanedWinText.substring(0, cleanedWinText.length - 1);
    }

    // Determine text size based on length
    double textFontSize = cleanedWinText.length > 50 ? 20 : 24;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background container
        Container(
          height: 400,
          width: 400,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/screenshot_background.png'),
              fit: BoxFit.fill,
            ),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: textFontSize,
                        color: Colors.black87,
                      ),
                      children: [
                        const TextSpan(text: 'I '),
                        TextSpan(
                          text: cleanedWinText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: ' and all I got was this trophy!'),
                      ],
                    ),
                  ),

                  //const SizedBox(height: 10),
                  // Mascot image with slight rotation
                  Transform.rotate(
                    angle: -0.1, // Slight rotation for fun
                    child: Image.asset(
                      'images/mascot.png',
                      height: 160,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Bottom text (App name)
        const Positioned(
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Made with ❤️', style: TextStyle(fontSize: 10)),
              Text('Gratitude Journal: Tiny Wins', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        // App Store logo in the bottom-right corner
        Positioned(
          bottom: 20,
          right: 10,
          child: Image.asset(
            'images/app_store.png',
            height: 20,
          ),
        ),
      ],
    );
  }

  void _showConfettiDialog(String winText, int streakCount) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Confetti(
        child: Stack(
          children: [
            AlertDialog(
              elevation: 0,
              contentPadding: const EdgeInsets.all(30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Speech bubble + mascot
                  Column(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: SpeechBubble(
                          nipLocation: NipLocation.BOTTOM,
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: 12,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Congratulations! I'd be proud if I ",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                ),
                                TextSpan(
                                  text: "$winText",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                const TextSpan(
                                  text: " 🎉",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),

                        ),
                      ),
                      const SizedBox(height: 12),
                      Image.asset(
                        'images/mascot.png',
                        height: 120,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ShareButton(
                    winText: winText,
                    screenshotController: _screenshotController,
                    context: context,
                    screenshotContainer: buildScreenshotContainer(winText),
                  ),
                ],
              ),
            ),
            // Close icon in the corner
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  if (streakCount >= 1) {
                    _showStreakDialog(streakCount);
                  }
                },
                child: const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.black26,
                  child: Icon(Icons.close, size: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStreakDialog(int streakCount) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Confetti(
        child: Stack(
          children: [
            AlertDialog(
              elevation: 0,
              contentPadding: const EdgeInsets.all(30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "You're on a ",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                        TextSpan(
                          text: "$streakCount-day",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const TextSpan(
                          text: " streak! 🔥\nKeep it going!",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                },
                child: const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.black26,
                  child: Icon(Icons.close, size: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<List<Widget>> _buildWeekRows(double cellWidth) {
    final year = _selectedMonth.year;
    final month = _selectedMonth.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);

    final int startOffset = firstDayOfMonth.weekday % 7; // Sunday = 0
    DateTime current = firstDayOfMonth.subtract(Duration(days: startOffset));

    final List<List<Widget>> weekRows = [];

    while (current.isBefore(lastDayOfMonth) || current.isAtSameMomentAs(lastDayOfMonth)) {
      final List<Widget> week = [];

      for (int i = 0; i < 7; i++) {
        final normalizedDate = normalizeDate(current);

        if (normalizedDate.month != month) {
          // Dates outside the current month
          week.add(SizedBox(width: cellWidth));
        } else if (winsByDate[normalizedDate] != null) {
          final win = winsByDate[normalizedDate]!;

          week.add(
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showWinDialog(win);
              },
              onLongPress: () {
                HapticFeedback.heavyImpact();
                _showEditDeleteDialog(win);
              },
              child: Container(
                width: cellWidth,
                height: cellWidth,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      bottom: cellWidth * -0.1,
                      child: Icon(Icons.emoji_events, color: Colors.amber, size: cellWidth),
                    ),
                    Positioned(
                      bottom: cellWidth * 0.32,
                      child: Text(
                        '${current.day}',
                        style: TextStyle(
                          fontSize: cellWidth * 0.3,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          shadows: [
                            Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.white),
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
          // Empty cell (no win)
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
      resizeToAvoidBottomInset: false,
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
                  ElevatedButton(
                    onPressed: () async {
                      await NotificationService().scheduleTestNotification();
                    },
                    child: Text('Test Notification'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear All Wins?'),
                          content: const Text('Are you sure you want to delete ALL your logged wins? This cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel', style: TextStyle(color: Colors.deepOrange, fontSize: 16)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete All', style: TextStyle(color: Colors.deepOrange, fontSize: 16)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        setState(() {
                          winsByDate.clear();
                        });
                        await TinyWinStorage.saveWins([]);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text('Clear All Wins'),
                  ),

                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFFA7D6E7),
          onPressed: _handleLogWinTap, // Call a method when pressed
          label: Row(
            children: const [
              Icon(Icons.add),
              SizedBox(width: 5),
              Text('Log Win!'),
              SizedBox(width: 5),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Adjust the value to make the corners more rounded
          ),
        ),
      ),
    );
  }
}