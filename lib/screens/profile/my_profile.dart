// ProfilePage.dart
// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:doctoguidedoctorapp/constants/endpoints.dart';
import 'package:doctoguidedoctorapp/screens/loginSignUp/signupStep4.dart';
import 'package:doctoguidedoctorapp/screens/profile/professionalDocuments.dart';
import 'package:doctoguidedoctorapp/widgets/BottomNavBar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

import '../../models/map.dart';
import 'history.dart';
import 'myInformation.dart';
//import 'package:doctoguidedoctorapp/widgets/buttom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import 'package:doctoguidedoctorapp/widgets/Button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class MyProfile extends StatefulWidget {
  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }


  late double latitude;
  late double longitude;
  String? name = '';
  late String _userId;
  late bool isButtonEnabled = true;
  String? imagePath =
      "https://jzredydxgjflzlgkamhn.supabase.co/storage/v1/object/sign/item/item/2024-01-26T21:30:55.587640.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJpdGVtL2l0ZW0vMjAyNC0wMS0yNlQyMTozMDo1NS41ODc2NDAuanBnIiwiaWF0IjoxNzA2MzAxMDU5LCJleHAiOjIwMjE2NjEwNTl9.EQ8qCe_8uC6EGsNxzptM88Cy8xCKtzg6d0VIeO-aEj4"; // Variable to store the picked image path
 

Future<void> _loadUserData() async {
  try {
    _prefs = await SharedPreferences.getInstance();
    setState(() {});

    _userId = _prefs.getString('user_id') ?? '';
    name = _prefs.getString('user_name') ?? '';

    // Fetch doctor status
    final response = await dio.get('$api_endpoint_get_doctor_status?id_doctor=$_userId');

    //print('API Response: $response');

    // Parse the response
    if (response.statusCode == 200) {
      // Extract account_status from the response
      final responseData = jsonDecode(response.data);
      //print(responseData);
      final List<dynamic> accountStatusList = responseData;
      print("hola");
      if (accountStatusList.isNotEmpty) {
        final bool accountStatus = accountStatusList[0]['account_status'] ?? false;
        setState(() {
          isButtonEnabled = accountStatus;
        });
      }
    } else {
      print('Error fetching doctor status: ${response.statusCode}');
    }

    // Debug prints
    print('User ID: $_userId');
    print('Name: $name');
    print('isButtonEnabled: $isButtonEnabled');
  } catch (ex, st) {
    print('Error: $ex $st');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.primaryColor, // Change to your desired primary color
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 110.0),

            // User Profile Information
            CircleAvatar(
              radius: 60.0,
              backgroundImage: NetworkImage(imagePath!),
            ),
            SizedBox(height: 10.0),
            Text(
              '$name',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Birthstone',
                color: Colors.white,
              ),
            ),

            SizedBox(height: 20.0),
            buildSaveButton(),
            SizedBox(height: 20.0),

            // Action Buttons Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20.0),

                      // Profile Action Buttons
                      buildProfileButton(
                        'My Information',
                        Icons.info,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyInformationPage()),
                          );
                        },
                      ),
                      buildProfileButton(
                        'Professional Documents',
                        Icons.file_copy_rounded,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfessionalDoc(userId: _userId)),
                          );
                        },
                      ),
                      buildProfileButton(
                        'Password and Security',
                        Icons.security,
                        () {
                          // Add navigation logic for Password and Security page
                        },
                      ),
                      buildProfileButton(
                        'Language',
                        Icons.language,
                        () {
                          // Add navigation logic for Language page
                        },
                      ),
                      buildProfileButton(
                        'Log Out',
                        Icons.exit_to_app,
                        () {
                          // Add navigation logic for Log Out and show dialog
                          showLogoutDialog(context);
                        },
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  Widget buildSaveButton() {
    return Container(
      width: 150,
      height: 60.0,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Color(0xFF199A8E)),
        color: Color(0xFFE8F3F1),
      ),
      child: TextButton(
        onPressed:
            _onButtonPressed, // Enable/disable button based on isButtonEnabled state
        child: Text(
          isButtonEnabled == true
              ? 'STOP'
              : 'GO', // Change button text based on isButtonEnabled state
          style: TextStyle(
            color: Color(0xFF199A8E),
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }

  void _onButtonPressed() async {
    setState(() {
      isButtonEnabled = !isButtonEnabled; // Toggle the button state
    });
    try {
      // Example: Your API endpoint for updating user profile in Supabase
      

      final response = await dio.get(
        '$api_endpoint_update_doctor_status?id_doctor=$_userId&status=${isButtonEnabled}',
      );

      print('_userId: $_userId, name: $name');

      print(isButtonEnabled);
      

      Map<String, dynamic> retData = jsonDecode(response.toString());
      

      if (retData['status'] == 200) {
        print('Doctor status updated successfully');
        // Perform any additional actions if needed
      } else {
        print('Error updating Doctor status : ${retData['message']}');
        // Handle the error accordingly
      }

                     print('before');
                    Position position = await CurrentLocation.getCurrentLocation();
                    latitude = position.latitude ;
                    longitude = position.longitude;
                    print('get current location $latitude , $longitude');
                    UpdateLocation.updateLocalization(_userId, latitude, longitude);      

    } catch (e) {
      print('Error updating Doctor status : $e');
      // Handle unexpected errors
    }

    
  }
}

Widget buildProfileButton(String title, IconData icon, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.all(7.0),
    child: Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: AppColors.primaryColor, // Set the color of the icon to black
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.black, // Set the color of the text to black
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey, // Set the color of the arrow icon to black
              ),
            ],
          ),
          onTap: onTap,
        ),
        SizedBox(
          height: 7,
        ),
        Divider(
          color: AppColors.thirdColor,
          height: 1,
        ),
      ],
    ),
  );
}

// Function to show the logout confirmation dialog
void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Log Out?',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to\n log out?',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 80,
                height: 50.0,
                margin:
                    EdgeInsets.only(bottom: 15.0), // Adjust margin as needed
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Color(0xFFB38586)),
                  color: Color(0xFFF2E9E8),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ),
              Container(
                width: 80,
                height: 50.0,
                margin:
                    EdgeInsets.only(bottom: 20.0), // Adjust margin as needed
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Color(0xFFAB8787)),
                  color: Color(0xFFCBABA4),
                ),
                child: TextButton(
                  onPressed: () {
                    // Clear user data and navigate to login screen
                    clearUserData();
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: const Text(
                    'Log out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

void clearUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove("user_id");
  prefs.remove("user_name");
  prefs.remove("user_email");
  prefs.remove("user_phone");
  prefs.remove("user_password");
}
