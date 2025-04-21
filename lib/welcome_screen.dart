import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiny_wins/trophy_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'images/welcome.png',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(.5),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.center,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(.3),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              children: [
                const Expanded(
                  flex: 1, // Adjusts space above the title
                  child: SizedBox(),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipPath(
                      clipper: CloudClipper(),
                      child: Container(
                        height: 275,
                        color: Theme.of(context).colorScheme.surface.withOpacity(.5),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Tiny Wins",
                            style: TextStyle(fontSize: 43, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Gratitude Journal",
                            style: TextStyle(fontSize: 30, height: 1.0, letterSpacing: 4),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),


                const Expanded(
                  flex: 8, // Proportional spacing in the middle
                  child: SizedBox(),
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                      minimumSize: const Size(double.infinity, 50),
                      elevation: 10,
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TrophyScreen()),
                      );
                    },
                    child: Text("Let's go!", style: TextStyle(color: Colors.black, fontSize: 20)),
                  ),
                ),
                const Expanded(
                  flex: 1, // Adjusts space below the button
                  child: SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CloudClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;

    final path = Path();

    path.moveTo(width * 0.2, height * 0.6);
    path.cubicTo(0, height * 0.6, 0, height * 0.25, width * 0.15, height * 0.25);
    path.cubicTo(width * 0.25, 0, width * 0.45, 0, width * 0.5, height * 0.2);
    path.cubicTo(width * 0.55, 0, width * 0.75, 0, width * 0.8, height * 0.25);
    path.cubicTo(width, height * 0.25, width, height * 0.6, width * 0.85, height * 0.6);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

