import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

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

  void _submitWin() {
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/log_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
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
                                color: Colors.grey.shade500,
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
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      maxLength: 200,
                    ),
                  ],
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
        ),
      ),
    );
  }
}
