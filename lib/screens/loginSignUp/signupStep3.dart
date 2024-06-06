// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_this, no_logic_in_create_state, use_key_in_widget_constructors

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pinput/pinput.dart';
import '../../constants/endpoints.dart';
import 'login.dart';
import '../../theme/theme.dart';
import '../../widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final dio = Dio();
final supabase = Supabase.instance.client;
FirebaseAuth auth = FirebaseAuth.instance;

bool correct = true;

String? otpCode;



class SignupScreen3 extends StatefulWidget {
  final String verificationId;
  final String name;
  final String email;
  final String password;
  final String birthDate;
  final String gender;
  final String phone;

  const SignupScreen3({
    required this.verificationId,
    required this.name,
    required this.email,
    required this.password,
    required this.birthDate,
    required this.gender,
    required this.phone,
  });

  @override
  State<SignupScreen3> createState() => _SignupScreen3State();
}

class _SignupScreen3State extends State<SignupScreen3> {
  @override
  void initState() {
    // TODO: implement initState

    print('init state');
    super.initState();
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

  Future<String> signupUser() async {
    String email = widget.email;
    String password = widget.password;
    String name = widget.name;
    String phone = widget.phone;
    String birthDate = widget.birthDate;
    String gender = widget.gender;
    String picture =
        "https://jzredydxgjflzlgkamhn.supabase.co/storage/v1/object/sign/item/item/2024-01-26T21:30:55.587640.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJpdGVtL2l0ZW0vMjAyNC0wMS0yNlQyMTozMDo1NS41ODc2NDAuanBnIiwiaWF0IjoxNzA2MzAxMDU5LCJleHAiOjIwMjE2NjEwNTl9.EQ8qCe_8uC6EGsNxzptM88Cy8xCKtzg6d0VIeO-aEj4";

    print(email);
    print(name);
    print(phone);
    print(password);
    print(birthDate);
    print(gender);

    try {
      print('before api');
      final response = await dio.get(
        '$api_endpoint_user_sign?name=$name&email=${Uri.encodeComponent(email.trim())}&password=$password&gender=$gender&phone=$phone&birthdate=$birthDate&picture=$picture',
      );
      print('after api');

      print("Response: ${response..toString()}");

      Map<String, dynamic> retData = jsonDecode(response.toString());

      if (retData['status'] == 200) {
        dynamic userData = retData['data'];

        if (userData is List) {
          // Assuming the first element in the list is the user data
          if (userData.isNotEmpty && userData[0] is Map<String, dynamic>) {
            userData = userData[0];
          }
        }

        if (userData is Map<String, dynamic>) {
          // Access the user data from the map
          print(userData);

          print("success");
          return 'success';
        } else {
          print("fail");
          return 'Error: Unexpected user data format';
        }
      } else {
        showToast(retData['message']);
        print("fail");
        String errorMsg = retData['message'] ?? 'Unknown error';
        return 'Error: $errorMsg';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  void phoneAuth() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+213${widget.phone}",
        verificationCompleted: (PhoneAuthCredential credential) {
          // Handle verification completion if needed
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            //verificationFailedMsg = e.message!; // Store error message
          });
          showToast('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {},
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout if needed
        },
      );
    } catch (e) {
      print('Phone authentication error: $e');
      showToast('Phone authentication error');
    }
  }

  @override
  Widget build(BuildContext context) {
    void onPressedVerifyCode() async {
      // Create a PhoneAuthCredential with the code
      String smsCode = otpCode!;
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId, smsCode: smsCode);

      try {
        // Sign in the user with the credential
        await FirebaseAuth.instance.signInWithCredential(credential);

        // Check if user is signed in successfully
        if (FirebaseAuth.instance.currentUser == null) {
          // Handle sign-in failure or null user
          showToast('firebase phone auth failed. Please try again.');
        }
      } catch (e) {
        // Handle sign-in error
        print('firebase phone auth error: $e');
        showToast('firebase phone auth error. Please try again.');
      }

      String signupResult = await signupUser();

      if (signupResult == 'success' &&
          FirebaseAuth.instance.currentUser != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      } else {
        // Handle signup failure
        print('Signup failed: $signupResult');
        // Display an error message or perform other actions accordingly
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
              fontWeight: FontWeight.bold, // Make text bold
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.start,
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
                              color: AppColors
                                  .primaryColor, // Adjust color as needed
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

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Verification Code',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Enter code that we have sent to your number : ${widget.phone}',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                Pinput(
                  length: 6,
                  showCursor: true,
                  defaultPinTheme: PinTheme(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryColor),
                      ),
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      )),
                      
                      
                  onCompleted: (value) {
                    setState(() {
                      otpCode = value;
                      print("<<<<<<<<<<<<<<<<<< otp code : $otpCode");
                    });
                  },
                ),

                const SizedBox(height: 50),
                ButtonGreen(
                    text: 'Verify',
                    onPressed: () {
                      print("___________________________________pressed verify $otpCode");
                      onPressedVerifyCode();
                    }),
                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Didnt receive the code?',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        // Call the login function when the text is tapped
                        phoneAuth();
                      },
                      child: Text(
                        'Resend',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
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
      ),
    );
  }
}

// Create a list of controllers for each code box (assuming you have multiple)



