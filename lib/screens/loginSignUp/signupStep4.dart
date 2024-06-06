// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, no_leading_underscores_for_local_identifiers, unused_local_variable

import 'dart:convert';

import 'package:country_picker/country_picker.dart';
import 'package:dio/dio.dart';
import 'package:doctoguidedoctorapp/screens/loginSignUp/signupStep3.dart';
import '../../constants/endpoints.dart';
import 'login.dart';
import 'signupStep5.dart';
import '../../theme/theme.dart';
import '../../widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

final dio = Dio();
final supabase = Supabase.instance.client;
FirebaseAuth auth = FirebaseAuth.instance;
bool correct = true;
String? verifyId;
late String verificationFailedMsg;

Country selectedCountry = Country(
    phoneCode: "213",
    countryCode: "DZ",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Algeria",
    example: "Algeria",
    displayName: "Algeria",
    displayNameNoCountryCode: "DZ",
    e164Key: "");

class SignupScreen4 extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String birthDate;
  final String gender;
  final String speciality;
  //final String price;
  final String diploma;
  final String proNum;
  final Map<String, String> typePriceMap;
  final String basicPrice;

  SignupScreen4({
    required this.name,
    required this.email,
    required this.password,
    required this.birthDate,
    required this.gender,
    //required this.price,
    required this.proNum,
    required this.speciality,
    required this.diploma,
    required this.typePriceMap,
    required this.basicPrice,
  });

  @override
  State<SignupScreen4> createState() => _SignupScreen2State();
}

class _SignupScreen2State extends State<SignupScreen4> {
  final TextEditingController phoneController = TextEditingController();

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

  void phoneAuth() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+" + selectedCountry.phoneCode + phoneController.text,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Handle verification completion if needed
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            verificationFailedMsg = e.message!; // Store error message
          });
          showToast('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          // Navigate to the next screen with verification ID
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignupScreen5(
                verificationId: verificationId,
                email: widget.email,
                password: widget.password,
                name: widget.name,
                phone: phoneController.text.trim(),
                birthDate: widget.birthDate,
                gender: widget.gender,
                //price: widget.price,
                proNum: widget.proNum,
                speciality: widget.speciality,
                diploma: widget.diploma,
                basicPrice : widget.basicPrice,
                typePriceMap : widget.typePriceMap,
              ),
            ),
          );
        },
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
    void onPressedSendCode() {
      phoneAuth();
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
      body: Container(
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
                    'Enter your Phone Number',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Enter your phone number, we will send\nyou confirmation code',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  cursorColor: AppColors.primaryColor,
                  controller: phoneController,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (value) {
                    phoneController.text = value;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter phone number",
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide:
                          const BorderSide(color: AppColors.primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                    prefixIcon: Container(
                        padding: EdgeInsets.all(20),
                        child: InkWell(
                          onTap: () {
                            showCountryPicker(
                                context: context,
                                countryListTheme: CountryListThemeData(
                                  bottomSheetHeight: 550,
                                ),
                                onSelect: (value) {
                                  setState(() {
                                    selectedCountry = value;
                                    print(
                                        "<<<<<<<<<<<<<<<<<<<< slected ! ${"+" + selectedCountry.phoneCode + phoneController.text}");
                                  });
                                });
                          },
                          child: Text(
                              "${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              )),
                        )),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              ButtonGreen(text: 'Send Code', onPressed: onPressedSendCode),
              const SizedBox(height: 40),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
