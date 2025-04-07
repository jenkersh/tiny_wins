import 'package:flutter/material.dart';
import 'log_tiny_win_screen.dart';
import 'tiny_win_model.dart'; // Your model for logged wins
import 'package:intl/intl.dart';

class TrophyShelfScreen extends StatefulWidget {
  const TrophyShelfScreen({super.key});

  @override
  State<TrophyShelfScreen> createState() => _TrophyShelfScreenState();
}

class _TrophyShelfScreenState extends State<TrophyShelfScreen> {
  DateTime _selectedMonth = DateTime.now();
  Map<DateTime, TinyWin> winsByDate = {
    DateTime(2025, 4, 1): TinyWin(date: DateTime(2025, 4, 1), message: "Completed a new project task!"),
    DateTime(2025, 4, 3): TinyWin(date: DateTime(2025, 4, 3), message: "Took a 30-minute walk today!"),
    DateTime(2025, 4, 5): TinyWin(date: DateTime(2025, 4, 5), message: "Ate a healthy lunch!"),
    DateTime(2025, 4, 7): TinyWin(date: DateTime(2025, 4, 7), message: "Read a chapter of a book!"),
    DateTime(2025, 4, 10): TinyWin(date: DateTime(2025, 4, 10), message: "Completed a workout session!"),
    DateTime(2025, 4, 12): TinyWin(date: DateTime(2025, 4, 12), message: "Meditated for 10 minutes!"),
    DateTime(2025, 4, 14): TinyWin(date: DateTime(2025, 4, 14), message: "Had a productive workday!"),
    DateTime(2025, 4, 17): TinyWin(date: DateTime(2025, 4, 17), message: "Organized my workspace!"),
    DateTime(2025, 4, 20): TinyWin(date: DateTime(2025, 4, 20), message: "Took a break and stretched!"),
    DateTime(2025, 4, 22): TinyWin(date: DateTime(2025, 4, 22), message: "Learned something new today!"),
    DateTime(2025, 4, 28): TinyWin(date: DateTime(2025, 4, 28), message: "Completed a challenging task at work!"),
  };

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

  void _navigateToLogWinScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LogTinyWinScreen()),
    );

    if (result != null && result is TinyWin) {
      setState(() {
        winsByDate[result.date] = result;
      });
    }
  }

  List<Widget> _buildTrophyShelves() {
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final totalDays = DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);

    final List<Widget> shelves = [];
    List<Widget> currentShelf = [];

    // Calculate the weekday for the first day of the month (1 = Monday, 7 = Sunday)
    int startingWeekday = firstDayOfMonth.weekday % 7;
    startingWeekday = startingWeekday == 0 ? 7 : startingWeekday;

    // Add trophies for each day of the month
    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);

      // Add a trophy for each day that has a "tiny win"
      currentShelf.add(
        winsByDate[date] != null
            ? GestureDetector(
          onTap: () {
            // Navigate to the details screen for the logged win
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
              Text('${date.day}', style: const TextStyle(fontSize: 16)),
            ],
          ),
        )
            : const SizedBox(width: 50), // Empty slot for the day with no win
      );

      // If it's the end of the week (Saturday) or the end of the month, process the row
      if ((startingWeekday + day) % 7 == 0 || day == totalDays) {
        // For the first row (week), align to the right if needed
        MainAxisAlignment rowAlignment = MainAxisAlignment.end;

        if (day == 1) {
          // First row: Add leading empty slots based on startingWeekday
          rowAlignment = MainAxisAlignment.end; // Align to the right for the first week
        } else if (day == totalDays) {
          // Last row: Align to the left for the last week
          rowAlignment = MainAxisAlignment.start;
        }

        // Add the row of trophies (shelf) to the shelves list
        shelves.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: rowAlignment,
                  children: currentShelf,
                ),
                // Add shelf container beneath the trophies
                Container(
                  alignment: Alignment.topRight,
                  height: 8,
                  width: currentShelf.length * 50.0, // Match shelf width to the number of days in the row
                  //margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.brown[200], // Shelf color
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                    boxShadow: const [
                      BoxShadow(blurRadius: 4, color: Colors.black26, offset: Offset(0, 4)),
                    ], // Shadow effect
                  ),
                ),
              ],
            ),
          ),
        );

        // Reset for the next row
        currentShelf = [];
      }
    }

    return shelves;
  }



  @override
  Widget build(BuildContext context) {
    final monthFormat = DateFormat('MMMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiny Wins'),
        centerTitle: true,
      ),
      body: Column(
        children: [
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
          Column(
            children: _buildTrophyShelves(),
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