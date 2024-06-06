// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, no_leading_underscores_for_local_identifiers, unused_local_variable, unnecessary_brace_in_string_interps

import 'dart:convert';

import 'package:country_picker/country_picker.dart';
import 'package:dio/dio.dart';
import 'package:doctoguidedoctorapp/screens/loginSignUp/signupStep4.dart';
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
late String _userId;

// Map to store type-price entries
Map<String, String> typePriceMap = {};

final TextEditingController typeController = TextEditingController();

final TextEditingController priceController = TextEditingController();

final TextEditingController basicPriceController = TextEditingController();

class SignupScreen3 extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String birthDate;
  final String gender;
  final String speciality;
  //final String price;
  final String diploma;
  final String proNum;

  SignupScreen3({
    required this.name,
    required this.email,
    required this.password,
    required this.birthDate,
    required this.gender,
    //required this.price,
    required this.proNum,
    required this.speciality,
    required this.diploma,
  });

  @override
  State<SignupScreen3> createState() => _SignupScreen2State();
}

class _SignupScreen2State extends State<SignupScreen3> {
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

  @override
  Widget build(BuildContext context) {
    void onPressedSendCode() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignupScreen4(
            email: widget.email,
            password: widget.password,
            name: widget.name,
            birthDate: widget.birthDate,
            gender: widget.gender,
            //price: widget.price,
            proNum: widget.proNum,
            speciality: widget.speciality,
            diploma: widget.diploma,
            basicPrice : basicPriceController.text,
            typePriceMap : typePriceMap,

          ),
        ),
      );
    }

    void onPressedAddTypePrice() async {
      String type = typeController.text;
      String price = priceController.text;

      // Check if type and price are not empty
      if (type.isNotEmpty && price.isNotEmpty) {
        // Add to map
        typePriceMap[type] = price;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added successfully: $type - ${price}'),
            duration: Duration(seconds: 2),
          ),
        );

        print('<<<<<<<<<<<<<<<$typePriceMap');

        // Clear text fields
        typeController.clear();
        priceController.clear();
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
                            color: Colors.white,
                            // Adjust color as needed
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

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter your Consultation Prices',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Enter all your consultation types with there prices',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    InputButton(
                      hintText: 'Enter basic consultation price',
                      controller: basicPriceController,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                smallInputButton(
                  hintText: 'Type',
                  controller: typeController,
                ),
                smallInputButton(
                  hintText: 'Price',
                  controller: priceController,
                ),
              ]),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  ButtonAdd(
                    text: "+",
                    onPressed: onPressedAddTypePrice,
                  ),
                ]),
              ),

              const SizedBox(height: 40),
              ButtonGreen(text: 'Next', onPressed: onPressedSendCode),
              const SizedBox(height: 40),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
