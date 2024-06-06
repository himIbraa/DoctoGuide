import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:doctoguidedoctorapp/screens/home/DetailedCompletedConsultation.dart';
import 'package:doctoguidedoctorapp/screens/home/consultationpage.dart';
import 'package:doctoguidedoctorapp/screens/loginSignUp/signupStep1.dart';
import 'package:doctoguidedoctorapp/screens/request%20page/consultationrequestpage.dart';
import '../../constants/endpoints.dart';
import '../profile/my_profile.dart';
import '../../theme/theme.dart';
import '../../widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio();
late String _userId;
late SharedPreferences _prefs;
dynamic idDoctor;

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<String> loginUser() async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();
    String email = emailController.text;
    String password = passwordController.text;
    final encodedEmail = Uri.encodeFull(email.trim());
    final encodedPassword = Uri.encodeFull(password.trim());

    print(email);
    print(password);

    try {
      final response = await dio.get(
        '$api_endpoint_user_login?email=$encodedEmail&password=$encodedPassword',
      );

      print(response.data);

      Map<String, dynamic> ret_data = jsonDecode(response.toString());

      if (ret_data['status'] == 200) {
        print("in");
        dynamic userData = ret_data['data'];
        print(ret_data['data']);
        Map<String, dynamic> doctorData = userData.first;
        // Access the 'id_doctor' value from the doctorData map
        idDoctor = doctorData['id_doctor'];
        print('ID Doctor: $idDoctor');
        _prefs = await SharedPreferences.getInstance();
        setState(() {
          _userId = _prefs.getString('user_id') ?? '';
        });

        if (userData != null &&
            userData is List<dynamic> &&
            userData.isNotEmpty) {
          // Assuming the first element in the list is the user data
          Map<String, dynamic> userMap = userData[0];

          prefs.setString("user_id", "${userMap['id_doctor']}");
          prefs.setString("user_name", userMap['name']);
          prefs.setString("user_email", userMap['email']);
          prefs.setString("user_phone", userMap['phone']);
          prefs.setString("user_password", userMap['password']);
          prefs.setString("user_gender", userMap['gender']);
          prefs.setString("user_birthdate", userMap['birthDate']);

          print("success");
          return 'success';
        } else {
          return 'Error: Unexpected user data format';
        }
      } else {
        print("fail");
        showToast(ret_data['message']);
        String error_msg = ret_data['message'] ?? 'Unknown error';
        return 'Error: $error_msg';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<bool> checkIfLoggedIn() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.containsKey('user_id');
  }

  @override
  Widget build(BuildContext context) {
    void onPressed() async {
      // Navigate to the next screen upon successful login
      String loginResult = await loginUser();

      if (loginResult == 'success') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MyProfile()
          ), // Replace NextScreen with your intended screen
        );
      } else {
        // Display an error message
        print('Login failed: $loginResult');
        // Perform other actions based on login failure
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding:
          EdgeInsets.only(left: 100.0), // Adjust left padding as needed
          child: Text(
            'Login',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40), // Spacer

              InputButton(
                hintText: 'Enter your email',
                controller: emailController,
              ),
              const SizedBox(height: 25),
              InputButton(
                hintText: 'Enter your password',
                icon: Icons.lock,
                controller: passwordController,
              ),
              const SizedBox(height: 15),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(
                  'Forgot Password?',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppColors.primaryColor,
                  ),
                ),
              ]),
              const SizedBox(height: 30),
              ButtonGreen(text: 'Login', onPressed: () => onPressed()),
              const SizedBox(height: 20),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not registered yet?',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: Text(
                      'Create an account',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40),

              //   // Horizontal Line with "Or" Text
              // Row(
              //   children: [
              //     Expanded(
              //       child: Divider(
              //         color: AppColors.thirdColor,
              //         height: 1,
              //       ),
              //     ),
              //     Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
              //       child: Text(
              //         'OR',
              //         style: TextStyle(
              //           fontSize: 17,
              //           fontWeight: FontWeight.bold,
              //           color: AppColors.thirdColor,
              //         ),
              //       ),
              //     ),
              //     Expanded(
              //       child: Divider(
              //         color: AppColors.thirdColor,
              //         height: 1,
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(height: 40),

              // const SocialLoginButtons(
              //   googleIcon: FontAwesomeIcons.google,
              //   facebookIcon: FontAwesomeIcons.facebook,
              //   cloudIcon: FontAwesomeIcons.cloud,
              // ),
            ],
          ),
        ),
      ),
    );
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
