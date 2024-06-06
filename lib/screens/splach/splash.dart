import 'dart:async';
import 'dart:ui';  // Import dart:ui for FontFeature
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import 'getStarted.dart'; // Import the screen you want to navigate to

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate after 5 seconds
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GetStartedScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor, // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo or centered widget
            Image.asset(
              'lib/assets/images/logoWhite.png', // Replace 'your_logo.png' with your logo image path
              width: 200,
              height: 200,
              // You can customize width and height according to your logo size
            ),
            SizedBox(height: 16), // Space below the logo
            
          ],
        ),
      ),
    );
  }
}
