// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_element, dead_code

import 'dart:core'; // Import the core library

import 'package:dio/dio.dart';
import 'login.dart';
import 'signupStep2.dart';
import '../../theme/theme.dart';
import '../../widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final dio = Dio();
final supabase = Supabase.instance.client;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  String selectedCategory = 'Men';

  bool selectDate = false;
  bool agreedToTerms = false;
  // Function to show date picker and update selectedDate
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor, // Change primary color of the calendar
              onPrimary: Colors.white, // Change text color of selected date
              surface: Colors.white, // Change background color of calendar
              onSurface: Colors.black, // Change text color of unselected dates
            ),
            dialogBackgroundColor: Colors.white, // Change background color of dialog
          ),
          child: child!,
        );
      },
    
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      // Extract the date part (year, month, day) and set time to midnight (00:00:00)
      setState(() {
        selectedDate =
            DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
        // selectedDate.toString().split(' ')[0];
      });
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      textColor: const Color.fromARGB(255, 0, 0, 0),
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    void onPressedNext() async {
  String name = nameController.text;
  String email = emailController.text;
  String password = passwordController.text;
  String gender = selectedCategory;
  
  // Validate that required fields are not empty or null
  if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
    String date = selectedDate.toString().split(' ')[0];

    // Check if birthDate (date) is not null
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignupScreen2(
          name: name,
          email: email,
          password: password,
          gender: gender,
          birthDate: date,
        ),
      ),
    );
    } else {
    // Show SnackBar with required fields error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please fill out all required fields.'),
      ),
    );
  }
}


    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: 90.0), // Adjust left padding as needed
          child: Text(
            'Sign Up',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
               // Make text bold
               
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the previous screen (SplashScreen)
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Horizontal Line with "Or" Text
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors
                                .primaryColor, // Adjust color as needed
                            width: 2.0, // Adjust thickness as needed
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  ),
                  Expanded(
                    child: Container(
                      
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color:
                                AppColors.thirdColor, // Adjust color as needed
                            width: 2.0, // Adjust thickness as needed
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 60),
              //const SizedBox(height: 40),
              InputButton(
                hintText: 'Enter your full name',
                controller: nameController,
              ),

              const SizedBox(height: 20),
              genderButton(),

              DatePicker(),

              const SizedBox(height: 20),
              InputButton(
                hintText: 'Enter your email',
                controller: emailController,
              ),

              const SizedBox(height: 20),
              InputButton(
                hintText: 'Enter your password',
                icon: Icons.lock,
                controller: passwordController,
                //obscureText: true,
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: agreedToTerms,
                              onChanged: (newValue) {
                                // Update the state of the checkbox based on the new value
                                setState(() {
                                  agreedToTerms = newValue ?? false; // Use newValue, default to false if null
                                });
                              },
                              activeColor: AppColors.primaryColor,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'I agree to the doctoGuide Terms of Service\nand Privacy Policy',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ), // ... Radio button and 'Remember me' and 'Forgot password' texts
                ],
              ),
              const SizedBox(height: 40),
              ButtonGreen(text: 'Next', onPressed: onPressedNext),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      // Call the login function when the text is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    child: Text(
                      'Log In',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget genderButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 310.0,
          height: 55.0,
          margin: EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.0),
            border: Border.all(color: AppColors.primaryColor),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: InputDecoration(
              labelText: '',
              labelStyle: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: Colors.black.withOpacity(0.6),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              border: InputBorder.none,
            ),
            onChanged: (String? value) {
              setState(() {
                selectedCategory = value!;
              });
            },
            items: <String>['Men', 'Women'].map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget DatePicker() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 310.0,
          height: 55.0,
          margin: EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.0),
            border: Border.all(color: AppColors.primaryColor),
          ),
          child: ElevatedButton(
            onPressed: () {
              _selectDate(context);
              selectDate = true;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent, // Transparent button color
              elevation: 0, // No shadow
              padding: EdgeInsets.symmetric(horizontal: 16.0), // Adjust padding
              alignment: Alignment.centerLeft, // Align content to the left
    
            ),
            child: Align(
             alignment: Alignment.centerLeft,
            child: Text(
              selectDate != false
                  ? 'Selected Date: ${selectedDate.toString().split(' ')[0]}'
                  : 'Select Date',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 74, 74, 74),
                
                
              ),
              textAlign: TextAlign.left,
            ),),
          ),
        ),
      ],
    );
  }
}
