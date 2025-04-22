import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ShareButton extends StatefulWidget {
  final BuildContext context;
  final ScreenshotController screenshotController;
  final Widget screenshotContainer;
  final String winText;

  const ShareButton({
    super.key,
    required this.context,
    required this.screenshotController,
    required this.screenshotContainer,
    required this.winText,
  });

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  bool isLoading = false;

  Future<void> handleShare() async {
    HapticFeedback.mediumImpact();
    setState(() => isLoading = true);

    try {
      final image = await widget.screenshotController.captureFromWidget(
        pixelRatio: 2.5,
        InheritedTheme.captureAll(
          widget.context,
          Material(
            child: SizedBox(
              width: 400,
              height: 400,
              child: widget.screenshotContainer,
            ),
          ),
        ),
      );

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/tiny_win_share.png';
      final file = await File(imagePath).writeAsBytes(image);

      setState(() => isLoading = false);

      await Share.shareXFiles(
        [XFile(file.path)],
        //text: '🎉 I logged a Tiny Win: "${widget.winText}" via the Tiny Wins app!',
      );
    } catch (e) {
      debugPrint('Error sharing tiny win: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 45,
      child: ElevatedButton(
        onPressed: isLoading ? null : handleShare,
        style: ElevatedButton.styleFrom(
          elevation: 3,
          backgroundColor: Colors.amber[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("Share"),
                  SizedBox(width: 8),
                  Icon(Icons.share, size: 20, color: Colors.white),
                ],
              ),
      ),
    );
  }
}
