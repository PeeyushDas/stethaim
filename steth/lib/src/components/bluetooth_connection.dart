import 'package:flutter/material.dart';
import 'dart:async';

import 'package:stethaim/constants/app_constants.dart';

class NeumorexConnectionDialogs {
  // First dialog - Connect with Neumorex
  static Future<void> showBluetoothPromptDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Connect with Neumorex',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),

                // Bluetooth icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.bluetooth,
                      color: Color(0xFF005F87),
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Instructions
                Text(
                  'Turn on your bluetooth',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                Text(
                  'Bluetooth is necessary to connect with\nthe stethoscope. Please turn it on.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                const SizedBox(height: 24),

                // OK button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Show connecting dialog
                      showAnimatedConnectingDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      'Ok',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Second dialog - Connecting to Stethoscope with animated progress
  static Future<void> showAnimatedConnectingDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _AnimatedConnectingDialog();
      },
    );
  }

  // Third dialog - Connection Success
  static Future<void> showSuccessDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        // Auto-close after 2 seconds
        Future.delayed(Duration(seconds: 2), () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Green tick icon
                Container(
                  width: 80,
                  height: 80,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                ),

                // Success text
                Text(
                  'Neumorex Connected',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                Text(
                  'Successfully!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method to demonstrate all three dialogs in sequence
  static void showAllDialogsInSequence(BuildContext context) {
    showBluetoothPromptDialog(context);
  }
}

// Animated connecting dialog with StatefulWidget to handle animation
class _AnimatedConnectingDialog extends StatefulWidget {
  const _AnimatedConnectingDialog({Key? key}) : super(key: key);

  @override
  _AnimatedConnectingDialogState createState() =>
      _AnimatedConnectingDialogState();
}

class _AnimatedConnectingDialogState extends State<_AnimatedConnectingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  Timer? _dialogTimer;

  @override
  void initState() {
    super.initState();

    // Set up animation controller for the progress bar
    _progressController = AnimationController(
      duration: Duration(seconds: 3), // Progress animation will take 3 seconds
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_progressController)..addListener(() {
      setState(() {}); // Rebuild on each animation frame
    });

    // Start the progress animation
    _progressController.forward();

    // Set timer to close this dialog and show the success dialog
    _dialogTimer = Timer(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
        NeumorexConnectionDialogs.showSuccessDialog(context);
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _dialogTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Connecting to Stethoscope...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            const Text(
              'Searching Neumo Rex device...',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // Progress indicator with animation
            LinearProgressIndicator(
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                AppConstants.secondaryColor,
              ),
              value: _progressAnimation.value,
            ),
            const SizedBox(height: 24),

            // Cancel button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _dialogTimer?.cancel();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppConstants.primaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
