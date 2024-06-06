// ignore_for_file: unnecessary_string_interpolations, prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:doctoguidedoctorapp/widgets/button.dart';
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

class MyInformationPage extends StatefulWidget {
  @override
  State<MyInformationPage> createState() => _MyInformationPageState();
}

class _MyInformationPageState extends State<MyInformationPage> {
  Color themeColor = Color.fromRGBO(171, 135, 135, 1);
  Color insideColor = Color(0xFFCBABA4);
  String? imagePath;
  final dio = Dio();
  late SharedPreferences _prefs;
  late String _userId;
  String? imageUrlResponse =
      "https://jzredydxgjflzlgkamhn.supabase.co/storage/v1/object/sign/item/item/2024-01-26T21:30:55.587640.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJpdGVtL2l0ZW0vMjAyNC0wMS0yNlQyMTozMDo1NS41ODc2NDAuanBnIiwiaWF0IjoxNzA2MzAxMDU5LCJleHAiOjIwMjE2NjEwNTl9.EQ8qCe_8uC6EGsNxzptM88Cy8xCKtzg6d0VIeO-aEj4";

  String? imagePathDB =
      "https://jzredydxgjflzlgkamhn.supabase.co/storage/v1/object/sign/item/item/2024-01-26T21:30:55.587640.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJpdGVtL2l0ZW0vMjAyNC0wMS0yNlQyMTozMDo1NS41ODc2NDAuanBnIiwiaWF0IjoxNzA2MzAxMDU5LCJleHAiOjIwMjE2NjEwNTl9.EQ8qCe_8uC6EGsNxzptM88Cy8xCKtzg6d0VIeO-aEj4"; // Variable to store the picked image path;

  @override
  void initState() {
    super.initState();
    getIdAndLoadUserData();
  }

  Future<void> getIdAndLoadUserData() async {
    try {
      await getId();
      await _loadUserData();
    } catch (ex, st) {
      print('Error: $ex $st');
    }
  }

  Future<void> getId() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      setState(() {});
      _userId = _prefs.getString('user_id') ?? '';
      // Debug prints
      print('____________User ID: $_userId');
    } catch (ex, st) {
      print('Error: $ex $st');
    }
  }

  Future<void> _loadUserData() async {
    try {
      //to get the image
      final data = await supabase
          .from('doctor')
          .select()
          .eq('id_doctor', _userId)
          .single();
      _nameController.text =
          (data['name']) as String; //_prefs.getString('user_name') ?? '';
      _emailController.text =
          (data['email']) as String; // _prefs.getString('user_email') ?? '';
      _phoneController.text =
          (data['phone']) as String; //_prefs.getString('user_phone') ?? '';
      imagePathDB = data['picture'] as String?;
      _birthDateController.text = (data['birthDate']) as String;

      _genderController.text = (data['gender']) as String;

      //print(data);

      setState(() {});
    } catch (ex, st) {
      print('$ex $st ');
    }
  }

//UPDATE PROFILE
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _birthDateController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  //TextEditingController _wilayaController = TextEditingController();

  Future<void> _updateUserProfile() async {
    // Retrieve entered values
    String name = _nameController.text;
    String email = _emailController.text;
    String phone = _phoneController.text;
    String gender = _genderController.text;
    String birthDate = _birthDateController.text;

    // Add your logic to update the user profile in Supabase
    try {
      // Example: Your API endpoint for updating user profile in Supabase
      print('before patch');

      final response = await dio.get(
        '$api_endpoint_update_user_profile?id_doctor=${_userId}&name=${name}&email=$email&phone=$phone&gender=$gender&birthdate=$birthDate',
      );

      print(
          'userId: ${_userId}, name: $name, email: $email, phone: $phone, gender: $gender, birthDate: $birthDate');

      print(_userId);
      print('after patch');

      Map<String, dynamic> retData = jsonDecode(response.toString());
      print('after json');
      if (imageUrlResponse != null) {
        await _onUpload(imageUrlResponse!);
      }

      if (retData['status'] == 200) {
        print('User profile updated successfully');
        // Perform any additional actions if needed
      } else {
        showToast(retData['message']);
        print('Error updating user profile: ${retData['message']}');
        // Handle the error accordingly
      }
    } catch (e) {
      showToast('Unexpected error occurred');
      print('Error updating user profile: $e');
      // Handle unexpected errors
    }
  }

  Widget buildSaveButton() {
    return Container(
      width: 150,
      height: 60.0,
      margin: EdgeInsets.only(top: 30.0), // Adjust margin as needed
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.primaryColor),
        color: AppColors.primaryColor,
      ),
      child: TextButton(
        onPressed: () async {
          // Call the method to update the user profile
          await _updateUserProfile();
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyProfile()),
          );

          // Add your logic to save the information (e.g., update a user profile)

          //print('Wilaya: $wilaya');
        },
        child: const Text(
          'Save',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: 60.0), // Adjust left padding as needed
          child: Text(
            'My Information',
            //textAlign: TextAlign.center,
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
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //CustomAppBarIcon(),
                SizedBox(height: 10.0),

                SizedBox(height: 20.0),
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    imagePath != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: FileImage(File(imagePath!)),
                          )
                        : CircleAvatar(
                            radius: 64,
                            backgroundImage: NetworkImage(imagePathDB!),
                          ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: () async {
                          await _pickImage();
                        },
                        icon: const Icon(Icons.add_a_photo),
                      ),
                    )
                  ],
                ),

                SizedBox(height: 60.0),

                // TextFields for Name, Email, Phone Number, and Wilaya
                InputButton(hintText: 'Name', controller: _nameController),
                SizedBox(height: 30.0),
                InputButton(hintText: 'Email', controller: _emailController),
                SizedBox(height: 30.0),
                InputButton(
                    hintText: 'Phone Number', controller: _phoneController),
                SizedBox(height: 30.0),
                InputButton(
                    hintText: 'Birth Date', controller: _birthDateController),
                SizedBox(height: 30.0),
                InputButton(hintText: 'gender', controller: _genderController),

                // Save Button
                buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (imageFile == null) {
      return;
    }
    setState(() {
      imagePath = imageFile.path;
    });

    // Add the image upload logic here
    final bytes = await File(imagePath!).readAsBytes();
    final fileExt = imagePath!.split('.').last;
    final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
    final filePath = 'item/$fileName'; // Adapt the path as needed

    // Inside the _upload method
    print('File Path: $filePath');
    print('File Name: $fileName');
    print('File Extension: $fileExt');

    // Upload the image to Supabase Storage
    await supabase.storage.from('profilepic').uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(contentType: 'image/$fileExt'),
        );

    print('Upload Response:');

    // Get the signed URL for the uploaded image
    imageUrlResponse = await supabase.storage
        .from('profilepic')
        .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);
    print('$imageUrlResponse');

    // Continue with the rest of your code, e.g., updating the UI or calling the onUpload callback

    setState(() {});
  }

  /// Called when image has been uploaded to Supabase storage from within Avatar widget
  Future<void> _onUpload(String imageUrl) async {
    try {
      print('>>>>>>>>>>>>>>>$widget.userId $imageUrl ');

      final response = await supabase.from('doctor').update({
        'picture': imageUrl,
      }).match({
        'id_user': _userId,
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
