import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ConfettiScreen extends StatefulWidget {
  final String winText;
  final int streakCount; // For the streak popup

  const ConfettiScreen({
    super.key,
    required this.winText,
    required this.streakCount,
  });

  @override
  State<ConfettiScreen> createState() => _ConfettiScreenState();
}


class _ConfettiScreenState extends State<ConfettiScreen> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
    _controller.play();

    // Show streak popup after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showStreakPopup();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _shareWin(BuildContext context) {
    final text = "Today I... ${widget.winText} 🏆 #TinyWin";
    Share.share(text);
  }

  void _showStreakPopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🔥 Streak Alert!"),
        content: Text("You're on a ${widget.streakCount}-day streak! Keep it up!"),
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

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _controller,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  numberOfParticles: 30,
                  colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
                ),
              ),
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
                'Today I... ${widget.winText}',
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
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("Back to Calendar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
