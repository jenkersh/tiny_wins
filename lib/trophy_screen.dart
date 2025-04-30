import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_bubble/speech_bubble.dart';
import 'package:tiny_wins/notification_service.dart';
import 'package:tiny_wins/share_button.dart';
import 'package:tiny_wins/tiny_win_storage.dart';
import 'package:tiny_wins/track_wins.dart';
import 'package:url_launcher/url_launcher.dart';
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
  Map<DateTime, TinyWin> winsByDate = {
    // DateTime(2025, 5, 1): TinyWin(date: DateTime(2025, 5, 1), message: 'Finished a big project! 🎯'),
    // DateTime(2025, 5, 2): TinyWin(date: DateTime(2025, 5, 2), message: 'Went for a run 🏃‍♂️'),
    // DateTime(2025, 5, 3): TinyWin(date: DateTime(2025, 5, 3), message: 'Helped a friend move 📦'),
    // DateTime(2025, 5, 4): TinyWin(date: DateTime(2025, 5, 4), message: 'Read a full book 📚'),
    // DateTime(2025, 5, 5): TinyWin(date: DateTime(2025, 5, 5), message: 'Cooked a new recipe 🍝'),
    // DateTime(2025, 5, 6): TinyWin(date: DateTime(2025, 5, 6), message: 'Started learning Spanish 🇪🇸'),
    // DateTime(2025, 5, 7): TinyWin(date: DateTime(2025, 5, 7), message: 'Cleaned my whole apartment 🧹'),
    // DateTime(2025, 5, 8): TinyWin(date: DateTime(2025, 5, 8), message: 'Had a great meeting at work 👩‍💻'),
    // DateTime(2025, 5, 9): TinyWin(date: DateTime(2025, 5, 9), message: 'Donated to a charity ❤️'),
    // DateTime(2025, 5, 10): TinyWin(date: DateTime(2025, 5, 10), message: 'Painted a landscape 🖼️'),
    // DateTime(2025, 5, 11): TinyWin(date: DateTime(2025, 5, 11), message: 'Meditated for 20 minutes 🧘‍♀️'),
    // DateTime(2025, 5, 12): TinyWin(date: DateTime(2025, 5, 12), message: 'Planted a garden 🌱'),
    // // DateTime(2025, 5, 13): TinyWin(date: DateTime(2025, 5, 13), message: 'Completed a workout challenge 💪'),
    // DateTime(2025, 5, 14): TinyWin(date: DateTime(2025, 5, 14), message: 'Caught up with an old friend ☎️'),
    // DateTime(2025, 5, 15): TinyWin(date: DateTime(2025, 5, 15), message: 'Fixed my bike 🚲'),
    // DateTime(2025, 5, 16): TinyWin(date: DateTime(2025, 5, 16), message: 'Wrote in my journal 📓'),
    // DateTime(2025, 5, 17): TinyWin(date: DateTime(2025, 5, 17), message: 'Tried a new restaurant 🍣'),
    // DateTime(2025, 5, 18): TinyWin(date: DateTime(2025, 5, 18), message: 'Watched an inspiring documentary 🎥'),
    // DateTime(2025, 5, 19): TinyWin(date: DateTime(2025, 5, 19), message: 'Helped someone at the grocery store 🛒'),
    // DateTime(2025, 5, 20): TinyWin(date: DateTime(2025, 5, 20), message: 'Organized my closet 👕'),
    // // DateTime(2025, 5, 21): TinyWin(date: DateTime(2025, 5, 21), message: 'Practiced guitar 🎸'),
    // DateTime(2025, 5, 22): TinyWin(date: DateTime(2025, 5, 22), message: 'Volunteered for a local event 👐'),
    // DateTime(2025, 5, 23): TinyWin(date: DateTime(2025, 5, 23), message: 'Learned a magic trick ✨'),
    // DateTime(2025, 5, 24): TinyWin(date: DateTime(2025, 5, 24), message: 'Went hiking 🥾'),
    // DateTime(2025, 5, 25): TinyWin(date: DateTime(2025, 5, 25), message: 'Took an online class 🎓'),
    // DateTime(2025, 5, 26): TinyWin(date: DateTime(2025, 5, 26), message: 'Made homemade ice cream 🍦'),
    // DateTime(2025, 5, 27): TinyWin(date: DateTime(2025, 5, 27), message: 'Drew a comic strip ✏️'),
    // DateTime(2025, 5, 28): TinyWin(date: DateTime(2025, 5, 28), message: 'Fixed a leaky faucet 🔧'),
    // DateTime(2025, 5, 29): TinyWin(date: DateTime(2025, 5, 29), message: 'Wrote a thank-you note 💌'),
    // // DateTime(2025, 5, 30): TinyWin(date: DateTime(2025, 5, 30), message: 'Learned a new dance move 💃'),
    // // DateTime(2025, 5, 31): TinyWin(date: DateTime(2025, 5, 31), message: 'Had a perfect chill day 😌'),
  };
  final ScreenshotController _screenshotController = ScreenshotController();
  final InAppReview _inAppReview = InAppReview.instance;

  @override
  void initState() {
    super.initState();
    _loadWins();
    _checkAndShowWelcomeDialog();
  }

  // Check if the user is eligible for a review prompt
  Future<void> _checkAndPromptReview() async {
    final winCount = await getWinCount();
    // final prefs = await SharedPreferences.getInstance();
    // bool hasRated = prefs.getBool('has_rated') ?? false;
    // print(hasRated);// Get the number of wins

    if (winCount == 2) {
      // Prompt for a review after the second win
      _requestReview();
    } else if (winCount % 10 == 0) {
      // Every 10 wins after the first, prompt for a review
      _requestReview();
    }
  }

  Future<void> _requestReview() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasRated = prefs.getBool('has_rated') ?? false;

    // Only show review prompt if the user hasn't rated yet
    if (!hasRated) {
      if (await _inAppReview.isAvailable()) {
        _inAppReview.requestReview();
        prefs.setBool('has_rated', true); // Mark that the user has rated
      }
    }
  }

  // Show information dialog
  _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("App Info"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Notifications can be turned off or on in iPhone settings."),
              SizedBox(height: 10),
              Text("Contact us at: jkershapps@gmail.com"),
              SizedBox(height: 10),
              Text(
                "If you dig this app, please leave a review on the App Store listing page.",
                //style: TextStyle(color: Colors.blue),
              ),
              SizedBox(height: 10),
              Text("Made with ❤️ by Jennifer."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop(); // Close the dialog
              },
              child:
                  Text("Close", style: TextStyle(color: Colors.deepOrange, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Check if the user has seen the welcome dialog and show it if not
  _checkAndShowWelcomeDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? hasSeenDialog = prefs.getBool('hasSeenTrophyDialog');

    if (hasSeenDialog == null || hasSeenDialog == false) {
      _showWelcomeDialog();
      prefs.setBool('hasSeenTrophyDialog', true); // Update the flag to prevent future dialogs
    }
  }

  // Show the welcome dialog
  _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Welcome to your trophy collection!"),
          content: Text("Your shelves are empty. Hit the 'Log Win' button to win your first trophy."),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Got it!",
                  style: TextStyle(color: Colors.deepOrange, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _handleLogWinTap() {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day); // Normalize to ignore time

    if (winsByDate.containsKey(todayKey)) {
      HapticFeedback.lightImpact();
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
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: const Text('OK',
                  style: TextStyle(color: Colors.deepOrange, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      HapticFeedback.lightImpact();
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
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      _editWin(win);
                    },
                    child: const Text('Edit', style: TextStyle(color: Colors.deepOrange, fontSize: 16)),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      _confirmDeleteWin(win); // Show confirmation before deleting
                    },
                    child: const Text('Delete', style: TextStyle(color: Colors.deepOrange, fontSize: 16)),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
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
              HapticFeedback.lightImpact();
              Navigator.pop(context); // Close confirm dialog
              _deleteWin(win); // Actually delete
            },
            child: const Text('Yes, Delete',
                style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            }, // Just close confirm dialog
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
          decoration: InputDecoration(
            filled: true, // This enables the background color
            fillColor: Colors.white.withOpacity(0.2), // Adjust opacity (0.1 for 10% opacity)
            border: OutlineInputBorder(),
            // suffixIcon: IconButton(
            //       icon: const Icon(Icons.clear, size: 24),
            //       onPressed: () {
            //         controller.clear(); // Clears the text
            //       },
            //     ),
            hintText: 'Edit your tiny win...',
          ),
          maxLines: 4,
          controller: controller,
          autofocus: true,
          maxLength: 100,
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context, controller.text);
            },
            child: const Text('Save', style: TextStyle(color: Colors.deepOrange, fontSize: 16)),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
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
              fit: BoxFit.cover,
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
          bottom: 15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Made with ❤️', style: TextStyle(fontSize: 10)),
              Text('Daily Journal: Tiny Wins', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        // App Store logo in the bottom-right corner
        Positioned(
          bottom: 15,
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
    showDialog<bool>(
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
                                const TextSpan(
                                  text: "Congratulations! I'd be psyched if I ",
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
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context, true); // User tapped close button
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
    ).then((_) {
      // Always show streak dialog after confetti dialog dismissed, no matter how
      if (streakCount >= 1) {
        _showStreakDialog(streakCount);
      }
    });
  }

  void _showStreakDialog(int streakCount) {
    showDialog<bool>(
      context: context,
      barrierDismissible: true, // Allow dismissing the dialog by tapping outside
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
                  HapticFeedback.lightImpact();
                  Navigator.pop(context); // Just close, no review prompt here
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
    ).then((_) async {
      // Add a slight delay before prompting for review
      await Future.delayed(const Duration(milliseconds: 300));
      _checkAndPromptReview();
    });
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
                      child: Icon(Icons.emoji_events, color: Colors.amber.shade800, size: cellWidth),
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
                            Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.yellow),
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
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: IconButton(
                        icon: Icon(Icons.info_outline, size: 30, color: Colors.amber.shade700),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _showInfoDialog(context); // Show the information dialog when the button is tapped
                        },
                      ),
                    ),
                  ),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     await NotificationService().listScheduledNotifications();
                  //   },
                  //   child: Text('List Notifications'),
                  // ),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     await NotificationService().scheduleTestNotification();
                  //   },
                  //   child: Text('Send Test Notification'),
                  // ),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     final confirm = await showDialog<bool>(
                  //       context: context,
                  //       builder: (context) => AlertDialog(
                  //         title: const Text('Clear All Wins?'),
                  //         content: const Text('Are you sure you want to delete ALL your logged wins? This cannot be undone.'),
                  //         actions: [
                  //           TextButton(
                  //             onPressed: () => Navigator.pop(context, false),
                  //             child: const Text('Cancel', style: TextStyle(color: Colors.deepOrange, fontSize: 16)),
                  //           ),
                  //           TextButton(
                  //             onPressed: () => Navigator.pop(context, true),
                  //             child: const Text('Delete All', style: TextStyle(color: Colors.deepOrange, fontSize: 16)),
                  //           ),
                  //         ],
                  //       ),
                  //     );
                  //
                  //     if (confirm == true) {
                  //       setState(() {
                  //         winsByDate.clear();
                  //       });
                  //       await TinyWinStorage.saveWins([]);
                  //     }
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.redAccent,
                  //   ),
                  //   child: const Text('Clear All Wins'),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 15.0, right: 10.0),
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
