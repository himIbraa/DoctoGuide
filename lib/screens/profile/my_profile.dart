// ProfilePage.dart
// ignore_for_file: prefer_const_constructors

import 'package:doctoguide/screens/loginSignUp/login.dart';
import 'package:doctoguide/widgets/BottomNavBar.dart'; 

import 'medicalInfo.dart';
import 'myInformation.dart';
//import 'package:doctoguide/widgets/buttom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

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

  String? name;
  final TextEditingController _nameController = TextEditingController();
  late String _userId;
  String? imagePath =
      "https://jzredydxgjflzlgkamhn.supabase.co/storage/v1/object/sign/item/item/2024-01-26T21:30:55.587640.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJpdGVtL2l0ZW0vMjAyNC0wMS0yNlQyMTozMDo1NS41ODc2NDAuanBnIiwiaWF0IjoxNzA2MzAxMDU5LCJleHAiOjIwMjE2NjEwNTl9.EQ8qCe_8uC6EGsNxzptM88Cy8xCKtzg6d0VIeO-aEj4"; // Variable to store the picked image path

  Future<void> _loadUserData() async {
    try {
      print('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
      _prefs = await SharedPreferences.getInstance();
      setState(() {
        _userId = _prefs.getString('user_id') ?? '';
      });

      print('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<$_userId');

      //to get the image

      

      
      print('____________________$name');
      //to get the image
      final data =
          await supabase.from('patient').select().eq('id_patient', _userId).single();
      _nameController.text =
          (data['name']) as String;

      setState(() {
        name = data['name'] as String?;
        print('name------------------$name');
        imagePath = data['picture'] as String?;
      });
    } catch (ex, st) {
      print('$ex $st ');
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
    backgroundColor: AppColors.primaryColor, // Set app bar background color
    leading: IconButton(
      icon: Icon(Icons.arrow_back,
      size: 35),
      onPressed: () {
        Navigator.of(context).pop(); // Navigate back when arrow icon is pressed
      },
    ),
  ),
  body: Container(
    color: AppColors.primaryColor, // Change to your desired primary color
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 30.0),

        // User Profile Information
        CircleAvatar(
          radius: 60.0,
          backgroundImage: NetworkImage(imagePath!),
        ),
        SizedBox(height: 10.0),

        TextField(
          controller: _nameController,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            fontFamily: 'Birthstone',
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
    // Remove the underline border
    border: InputBorder.none,
    // Optionally, you can add padding to the TextField
    contentPadding: EdgeInsets.zero, // Remove internal padding
  ),
        ),
        SizedBox(height: 80.0),

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
                          builder: (context) => MyInformationPage(),
                        ),
                      );
                    },
                  ),
                  buildProfileButton(
                    'Medical Information',
                    Icons.file_copy_rounded,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => medicalInfo(userId: _userId,)),
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
                      showlogoutDialog(context);
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
 bottomNavigationBar: const BottomNavBar(selectedTab: '/profile'), 
);

  }

  Widget buildProfileButton(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              icon,
              color:
                  AppColors.primaryColor, // Set the color of the icon to black
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
                  color:
                      Colors.grey, // Set the color of the arrow icon to black
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
}



void clearUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove("user_id");
  prefs.remove("user_name");
  prefs.remove("user_email");
  prefs.remove("user_phone");
  prefs.remove("user_password");
}

void showlogoutDialog(BuildContext context) {
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
              'Are you sure you want to log out?',
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
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
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
          TextButton(
            onPressed: () {
              // Clear user data and navigate to login screen
              clearUserData();
              Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => Login()),
             );
            },
            child: const Text(
              'Log Out',
              style: TextStyle(
                color: AppColors.primaryColor, // Customize the color of the Log Out text
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      );
    },
  );
}
