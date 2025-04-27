import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
import 'package:tiny_wins/notification_service.dart';
import 'package:tiny_wins/tiny_win_model.dart';
import 'package:tiny_wins/tiny_win_storage.dart';
import 'package:tiny_wins/track_wins.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<String> suggestions = [
    'laughed really hard today',
    'learned something new',
    'checked something off my list',
    'had a great conversation',
    'took a moment for myself',
    'helped someone out'
  ];


  bool get _showSuggestions =>
      !_focusNode.hasFocus && _controller.text.isEmpty;

  void _submitWin() async {
    HapticFeedback.mediumImpact();
    final winText = _controller.text.trim();
    final encouragements = [
      "Enter a win in the box! I know you can think of something that went well today.",
      "Enter a win in the box! Even the tiniest win counts!",
      "Enter a win in the box! You’ve made it this far — that’s already a win.",
      "Enter a win in the box! You’re doing better than you think.",
      "Enter a win in the box! Give yourself some credit — anything positive goes!",
    ];

    final random = (encouragements..shuffle()).first;

    if (winText.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("You’ve got this 💪"),
          content: Text(random),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Okay, I'll try!"),
            ),
          ],
        ),
      );
      return;
    }

    // Check if the win is being logged before 8 PM
    final now = DateTime.now();
    if (now.hour < 20) {
      // If it's before 8 PM, cancel today's notification
      await NotificationService().cancelNotificationForToday();
    }

    // Proceed to log the win
    await TinyWinStorage.addWin(TinyWin(date: DateTime.now(), message: winText));

    // Increment win count after successfully adding
    await incrementWinCount();

    // Pop the win and dismiss the dialog
    Navigator.pop(context, winText);
  }



  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {}); // rebuild to show/hide animated hint
    });
    _controller.addListener(() {
      setState(() {}); // rebuild to show/hide animated hint
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows the body to extend behind the AppBar
      appBar: AppBar(
        toolbarHeight: 40,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back when tapped
          },
        ),
        //title: Text('Log Tiny Win'),
        backgroundColor: Colors.transparent, // Make the AppBar transparent
        elevation: 0, // Remove the shadow under the AppBar
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand, // Ensures the Stack expands to fill the available space
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/log_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content of the screen
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today I...',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      if (_showSuggestions)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: SizedBox(
                            height: 60, // approximate height to fit inside TextField
                            child: AnimatedTextKit(
                              animatedTexts: suggestions
                                  .map((text) => TypewriterAnimatedText(
                                text,
                                textStyle: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 16,
                                ),
                                speed: const Duration(milliseconds: 30),
                              ))
                                  .toList(),
                              isRepeatingAnimation: true,
                              repeatForever: true,
                              pause: const Duration(seconds: 1),
                              displayFullTextOnTap: false,
                            ),
                          ),
                        ),
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          filled: true, // This enables the background color
                          fillColor: Colors.white.withOpacity(0.2), // Adjust opacity (0.1 for 10% opacity)
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        maxLength: 100,
                      )

                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitWin,
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        backgroundColor: Color(0xFFA7D6E7), // Set the background color// Set the text (foreground) color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Optional: Rounded corners
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Text('Hooray! 🎉', style: TextStyle(fontSize: 18)),
                      ),
                    )

                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
