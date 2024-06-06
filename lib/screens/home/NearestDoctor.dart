import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctoguide/theme/theme.dart';
import 'package:doctoguide/widgets/BottomNavBar.dart';
import 'package:doctoguide/widgets/DoctorCard.dart';
import 'package:doctoguide/constants/endpoints.dart';
import 'package:doctoguide/screens/home/RequestPopUp.dart';

class NearestDoctorPage extends StatefulWidget {
  final String searchQuery;
  final double latitude;
  final double longitude;

  const NearestDoctorPage({
    super.key,
    required this.searchQuery,
    required this.latitude,
    required this.longitude,
  });

  @override
  _NearestDoctorPageState createState() => _NearestDoctorPageState();
}

class _NearestDoctorPageState extends State<NearestDoctorPage> {
  bool _isLoading = false; // To track loading state

  Future<List<Map<String, dynamic>>> fetchDoctors() async {
    final response = await http.get(
      Uri.parse('$api_endpoint_get_doctors?specialty=${widget.searchQuery}&latitude=${widget.latitude}&longitude=${widget.longitude}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> doctors =
          List<Map<String, dynamic>>.from(jsonData['data']);
      return doctors;
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  Future<void> findDoctorAutomatically() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? patientId = prefs.getString('user_id');

      List<Map<String, dynamic>> doctors = await fetchDoctors();
      List<int> doctorIds = doctors.map<int>((doctor) => doctor['id_doctor'] as int).toList();

      print('Sending request to API:');
      print(jsonEncode({
        'patient_id': patientId,
        'doctor_ids': doctorIds,
      }));

      final response = await http.post(
        Uri.parse(api_Find_Doctor),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'patient_id': patientId,
          'doctor_ids': doctorIds,
        }),
      );

      print('Response from API:');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'];

        if (message.contains('accepted')) {
          final acceptedDoctorId = int.parse(
            RegExp(r'doctor ID (\d+)').firstMatch(message)?.group(1) ?? '',
          );

          final acceptedDoctor = doctors.firstWhere(
            (doctor) => doctor['id_doctor'] == acceptedDoctorId,
            orElse: () => {},
          );

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialogND(doctorName: acceptedDoctor['name']);
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('No Doctor Found'),
                content: const Text('No doctors accepted the request.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to find a doctor automatically')),
        );
      }
    } catch (e) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cancel,
                color: Colors.red,
                size: 48,
              ),
            ],
          ),
          SizedBox(height: 8), // Add spacing between the icon and the text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('No Doctor has been found'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: Text(
            'OK',
            style: TextStyle(color: AppColors.primaryColor),
          ),
        ),
      ],
    ),
  );


    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Nearest Doctors',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: findDoctorAutomatically,
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                backgroundColor: AppColors.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(
                    color: AppColors.primaryColor,
                    width: 0.7,
                  ),
                ),
              ),
              child: const Text('Search automatically for a doctor'),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchDoctors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'lib/assets/images/Noresult.jpg', // Path to your image asset
// Adjust the height as needed
                          ),

                        ],
                      ),
                    );


                } else {
                  final doctors = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return DoctorCard(
                        doctorid: doctor['id_doctor'].toString(),
                        doctorName: doctor['name'] ?? 'N/A',
                        specialty: doctor['speciality'] ?? 'N/A',
                        phone: doctor['phone'] ?? 'N/A',
                        fee: '${doctor['fee']} DA',
                        onRequest: () {
                          // Handle request button press
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(selectedTab: '/search'),
    );
  }
}
