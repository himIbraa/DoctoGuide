// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_element, dead_code

import 'dart:convert';
import 'dart:core'; // Import the core library
import 'dart:io';
import 'package:doctoguidedoctorapp/screens/loginSignUp/signupStep3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../constants/endpoints.dart';
import 'login.dart';
import 'signupStep4.dart';
import '../../theme/theme.dart';
import '../../widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final dio = Dio();
final supabase = Supabase.instance.client;

class SignupScreen2 extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String birthDate;
  final String gender;

  SignupScreen2({
    required this.name,
    required this.email,
    required this.password,
    required this.birthDate,
    required this.gender,
  });
  @override
  State<SignupScreen2> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen2> {
  //final TextEditingController priceController = TextEditingController();

  final TextEditingController proNumberController = TextEditingController();

  late String filePath;

  // ignore: prefer_typing_uninitialized_variables
  late String fileUrlResponse;
  String selectedSpeciality = 'Cardiology';

  bool agreedToTerms = false;

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

  void uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        try {
          // Read file bytes
          final bytes = await File(filePath).readAsBytes();
          final fileExt = filePath.split('.').last;
          final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
          final storagePath = 'doctorfile/$fileName';

          // Upload the file to Supabase Storage
          await supabase.storage.from('doctorfile').uploadBinary(
                storagePath,
                bytes,
                fileOptions: FileOptions(contentType: 'application/$fileExt'),
              );

          print('Upload Successful');

          // Get the signed URL for the uploaded file
          fileUrlResponse = await supabase.storage
              .from('doctorfile')
              .createSignedUrl(storagePath, 60 * 60 * 24 * 365 * 10);

          print('File URL: $fileUrlResponse');
          setState(() {
            // Update UI if needed
          });
        } catch (error) {
          // Handle file upload errors
          print('Error uploading file: $error');
          // Show error message to the user if needed
        }
      } else {
        // Handle the case when filePath is null
        print('No file path available');
        // Show error message to the user if needed
      }
    } else {
      // Handle the case when result is null or files list is empty
      print('No file selected');
      // Show error message to the user if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    void onPressedNext() async {
      //String price = priceController.text;
      String proNum = proNumberController.text;
      String speciality = selectedSpeciality;
      String diploma = fileUrlResponse;

      // Validate that required fields are not empty or null
      if ( //price.isNotEmpty &&
          proNum.isNotEmpty && speciality.isNotEmpty && diploma != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignupScreen3(
              name: widget.name,
              email: widget.email,
              password: widget.password,
              gender: widget.gender,
              birthDate: widget.birthDate,
              //price: price,
              proNum: proNum,
              speciality: speciality,
              diploma: diploma,
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

              specialityButton(),
              const SizedBox(height: 20),

              InputButton(
                hintText: 'Enter your professional number',
                controller: proNumberController,
              ),
              const SizedBox(height: 20),

              filePicker(),
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
                                  agreedToTerms = newValue ??
                                      false; // Use newValue, default to false if null
                                });
                              },
                              activeColor: AppColors.primaryColor,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'I agree to the doctoGuide Terms of Service\nand Privacy Policy',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget specialityButton() {
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
            value: selectedSpeciality,
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
                selectedSpeciality = value!;
              });
            },
            items: <String>[
              'Cardiology',
              'Orthopedics',
              'Pediatrics',
              'Oncology'
            ].map((String speciality) {
              return DropdownMenuItem<String>(
                value: speciality,
                child: Text(speciality),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget filePicker() {
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
            onPressed: () async {
              uploadFile();
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
                'Select File',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 74, 74, 74),
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
