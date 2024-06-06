// ignore_for_file: unnecessary_string_interpolations, prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:doctoguidedoctorapp/widgets/button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';
import '../../constants/endpoints.dart';
import '../../main.dart';
import '../loginSignUp/login.dart';
import 'my_profile.dart';
import '../../theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfessionalDoc extends StatefulWidget {
  final dynamic userId;

  ProfessionalDoc({
    required this.userId,
  });
  @override
  _ProfessionalDocState createState() => _ProfessionalDocState();
}

class _ProfessionalDocState extends State<ProfessionalDoc> {
  Color themeColor = Color.fromRGBO(171, 135, 135, 1);
  Color insideColor = Color(0xFFCBABA4);
  String? imagePath;
  late String name;
  late String speciality;
  final dio = Dio();
  String? imageUrlResponse =
      "https://jzredydxgjflzlgkamhn.supabase.co/storage/v1/object/sign/item/item/2024-01-26T21:30:55.587640.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJpdGVtL2l0ZW0vMjAyNC0wMS0yNlQyMTozMDo1NS41ODc2NDAuanBnIiwiaWF0IjoxNzA2MzAxMDU5LCJleHAiOjIwMjE2NjEwNTl9.EQ8qCe_8uC6EGsNxzptM88Cy8xCKtzg6d0VIeO-aEj4";
  late SharedPreferences _prefs;

  late String _userPassword;
  String? imagePathDB =
      "https://jzredydxgjflzlgkamhn.supabase.co/storage/v1/object/sign/item/item/2024-01-26T21:30:55.587640.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJpdGVtL2l0ZW0vMjAyNC0wMS0yNlQyMTozMDo1NS41ODc2NDAuanBnIiwiaWF0IjoxNzA2MzAxMDU5LCJleHAiOjIwMjE2NjEwNTl9.EQ8qCe_8uC6EGsNxzptM88Cy8xCKtzg6d0VIeO-aEj4"; // Variable to store the picked image path;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      setState(() {});

      //to get the image
      final data = await supabase
          .from('doctor')
          .select()
          .eq('id_doctor', widget.userId)
          .single();
      _nameController.text =
          (data['name']) as String; //_prefs.getString('user_name') ?? '';
      _specialityController.text = (data['speciality'])
          as String; // _prefs.getString('user_speciality') ?? '';
      _fileController.text = (data['diploma']) as String;

      imagePathDB = data['picture'] as String?;

      //print(data);

      setState(() {});
    } catch (ex, st) {
      print('$ex $st ');
    }
  }

//UPDATE PROFILE
  TextEditingController _nameController = TextEditingController();
  TextEditingController _specialityController = TextEditingController();
  TextEditingController _fileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Professional Documents',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make text bold
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
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text at the top

            // Profile picture and information
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile picture
                CircleAvatar(
                  radius: 50.0,
                  backgroundImage: AssetImage(
                      'assets/profile_image.jpg'), // Change to your image
                ),
                SizedBox(width: 20.0),

                // Name and speciality
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 120.0),
                    Text(
                      _nameController.text, // Change to your name
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _specialityController.text, // Change to your speciality
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20.0),

            // Additional information container
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Diploma',
                    style: TextStyle(
                      fontSize: 23.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  GestureDetector(
                    onTap: () async {
                    String fileUrl = _fileController.text;
                    Uri uri = Uri.parse(fileUrl);
                 
                    
                    await launchUrl(uri);
                    

                    },
                    child: Text(
                      'View Diploma',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: AppColors.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Called when image has been uploaded to Supabase storage from within Avatar widget
  Future<void> _onUpload(String imageUrl) async {
    try {
      print('>>>>>>>>>>>>>>>$widget.userId $imageUrl ');

      final response = await supabase.from('doctor').update({
        'picture': imageUrl,
      }).match({
        'id_user': widget.userId,
      });
      print('>>>>>>>>>>>>> $response <<<< $imageUrl ');
    } catch (error, st) {
      print(' $error $st ');
      SnackBar(
        content: const Text('Unexpected error occurred'),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    }
    setState(() {
      imagePath = imageUrl;
    });
  }
}
