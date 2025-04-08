import 'package:flutter/material.dart';
import 'package:tiny_wins/confetti_screen.dart';

class LogTinyWinScreen extends StatefulWidget {
  const LogTinyWinScreen({super.key});

  @override
  State<LogTinyWinScreen> createState() => _LogTinyWinScreenState();
}

class _LogTinyWinScreenState extends State<LogTinyWinScreen> {
  final TextEditingController _controller = TextEditingController();

  void _submitWin() {
    final winText = _controller.text.trim();
    if (winText.isEmpty) return;

    Navigator.pop(context, winText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Log Tiny Win'),
      //   centerTitle: true,
      // ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            const Text(
              'Today I...',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Write your tiny win...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _submitWin,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('Hooray! 🎉', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
