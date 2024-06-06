import 'package:flutter/material.dart';
import 'package:doctoguide/theme/theme.dart';
import 'package:doctoguide/widgets/BottomNavBar.dart';
import 'package:doctoguide/screens/home/popUp.dart';
import 'package:doctoguide/screens/home/NearestDoctor.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:doctoguide/constants/endpoints.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController symptomController = TextEditingController();
  late double latitude;
  late double longitude;
  final supabase = Supabase.instance.client;
  late SharedPreferences _prefs;
  late String _userId;
  final dio = Dio();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getCurrentLocation(); // Fetch the current location
  }

  Future<void> _loadUserData() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      setState(() {
        _userId = _prefs.getString('user_id') ?? '';
      });
      print('Loaded user ID: $_userId');
    } catch (ex, st) {
      print('$ex $st');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 180, // Set your desired width
                    height: 70, // Set your desired height
                    child: Image.asset('lib/assets/images/logohome.png'), // Your image asset here
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('lib/assets/images/profileImage.jpg'),
                  ),
                ],
              ),
              Container(
                width: double.infinity, // Make the container take full width
                padding: const EdgeInsets.all(16), // Add some padding inside the container
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor, // Use secondary color for the container
                  borderRadius: BorderRadius.circular(10), // Apply some border radius
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        "Need a doctor? We'll orient you to the right specialist.",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20, // Increase font size
                          fontWeight: FontWeight.bold, // Make text bold
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16), // Add some spacing between the text and the circle
                    Container(
                      width: 70, // Increase width
                      height: 90, // Increase height
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white, // White background for the circle
                      ),
                      child: Center(
                        child: Image.asset('lib/assets/images/doctorHome.png'), // Your image asset here
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreyColor,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: AppColors.greyColor, width: 0.5),
                      ),
                      child: const Center(
                        child: Text(
                          'Common symptoms you may experience',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.greyColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SymptomButton(
                          text: 'Fever, Chills,\nSweating, Fatigue',
                          onTap: () {
                            symptomController.text = 'Fever, Chills, Sweating, Fatigue'; // Update text
                          },
                        ),
                        const SizedBox(width: 10),
                        SymptomButton(
                          text: 'Stuffy Nose, Sore\nThroat, Cough',
                          onTap: () {
                            symptomController.text = 'Stuffy Nose, Sore Throat, Cough'; // Update text
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        SymptomButton(
                          text: 'Nausea, Vomiting,\nDiarrhea',
                          onTap: () {
                            symptomController.text = 'Nausea, Vomiting, Diarrhea'; // Update text
                          },
                        ),
                        const SizedBox(width: 10),
                        SymptomButton(
                          text: 'Headache, Nausea,\nSensitivity to Light',
                          onTap: () {
                            symptomController.text = 'Headache, Nausea, Sensitivity to Light'; // Update text
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: symptomController,
                      decoration: InputDecoration(
                        filled: true, // Set to true to enable filling the background
                        fillColor: AppColors.secondaryColor, // Background color
                        hintText: 'Write your symptoms here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.primaryColor), // Change border color here
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.primaryColor), // Change focused border color here
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send, color: AppColors.primaryColor), // Add suffix icon
                          onPressed: () async {
                            // Get the symptoms from the text field
                            String symptoms = symptomController.text.trim();

                            // Make sure the symptoms are not empty
                            if (symptoms.isEmpty) {
                              // Show an error message or handle it accordingly
                              return;
                            }

                            // Send the symptoms to the Flask API
                            var response = await http.post(
                              Uri.parse('$api_gemeni_get_spacialist'), // Replace with your Flask API URL
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({'symptoms': symptoms}),
                            );

                            if (response.statusCode == 200) {
                              // Parse the response
                              var data = jsonDecode(response.body);
                              String specialist = data['specialist'];

                              // Show the specialist recommendation in a dialog
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomDialog(
                                    specialistName: specialist,
                                    latitude: latitude,
                                    longitude: longitude,
                                  );
                                },
                              );
                            } else {
                              // Handle the error
                              showErrorDialog(context, 'Failed to get specialist recommendation');
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedTab: '/home'),
    );
  }

  // Function to handle the search action
  void handleSearch(BuildContext context) {
    // Get the search query from the search bar
    String query = searchController.text.trim();

    // Navigate to NearestDoctorPage with the search query as an argument
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NearestDoctorPage(searchQuery: query),
      ),
    );*/
  }
}

class SymptomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const SymptomButton({
    required this.text,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 135, // Set a fixed width for all instances
        height: 50, // Set a fixed height for all instances
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor, // Use secondary color for the container
          borderRadius: BorderRadius.circular(20), // Rounded corners
          border: Border.all(color: AppColors.greyColor), // Border color
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13, // Set a smaller font size
              color: Colors.black, // Black text color
            ),
            textAlign: TextAlign.center, // Center align the text
          ),
        ),
      ),
    );
  }
}

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 10),
            const Text(
              'Error',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'OK',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
