// ignore_for_file: prefer_const_constructors

import '../loginSignUp/login.dart';
import '../loginSignUp/signupStep1.dart';
import '../../widgets/button.dart';
import 'package:flutter/material.dart';

class GetStartedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    void navigateToLoginScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }
  void navigateToSignupScreen(BuildContext context) {
    // Navigate to the LoginScreen using Navigator
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
    );
  }
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'lib/assets/images/logoGreen.png', // Replace with your logo asset path
                width: 150,
                height: 150,
                // Customize width and height as needed
              ),
              SizedBox(height: 30), // Spacer

              // Text: "Get Started"
              Text(
                'Lets get started!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20), // Spacer

              // Description Text
              Text(
                'From Symptoms to Specialists: Your Personalized Healthcare Guide!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 60), // Spacer


              ButtonGreen(text: 'Login', onPressed: () => navigateToLoginScreen(context)),
              SizedBox(height: 30), // Spacer
              ButtonWhite(text: 'Sign up', onPressed: () => navigateToSignupScreen(context)),

          
            ],
          ),
        ),
      ),
    );
  }
}
