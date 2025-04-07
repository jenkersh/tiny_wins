import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ConfettiScreen extends StatelessWidget {
  final String winText;
  final int streakCount; // For the streak popup

  const ConfettiScreen({
    super.key,
    required this.winText,
    required this.streakCount,
  });

  void _shareWin(BuildContext context) {
    final text = "Today I... $winText 🏆 #TinyWin";
    Share.share(text);
  }

  void _showStreakPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🔥 Streak Alert!"),
        content: Text("You're on a $streakCount-day streak! Keep it up!"),
        actions: [
          TextButton(
            child: const Text("Nice!"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show the streak popup as soon as the screen builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showStreakPopup(context);
    });

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "🎉 Congratulations!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Image.asset(
                'images/trophy.png', // Replace with your trophy image
                height: 120,
              ),
              const SizedBox(height: 30),
              Text(
                'Today I... $winText',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => _shareWin(context),
                icon: const Icon(Icons.share),
                label: const Text("Share My Win"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
