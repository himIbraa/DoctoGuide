import 'dart:async';
import 'package:flutter/material.dart';
import 'package:doctoguide/theme/theme.dart';
import 'package:doctoguide/screens/home/RequestPopUp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctoguide/constants/endpoints.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import '../screens/home/map.dart';

class DoctorCard extends StatefulWidget {
  final String doctorid;
  final String doctorName;
  final String specialty;
  final String phone;
  final String fee;
  final VoidCallback onRequest;

  const DoctorCard({
    Key? key,
    required this.doctorid,
    required this.doctorName,
    required this.specialty,
    required this.phone,
    required this.fee,
    required this.onRequest,
  }) : super(key: key);

  @override
  _DoctorCardState createState() => _DoctorCardState();
}

String _locationMessage = '';
late String latitude;
late String longitude;

class _DoctorCardState extends State<DoctorCard> {
  late StreamSubscription<Position> _positionStreamSubscription;
  bool isRequesting = false;
  int? requestId; // State variable to hold the request ID
  StreamController<String> requestStatusStreamController =
      StreamController<String>();

  @override
  void initState() {
    super.initState();
    // Start monitoring request status if a request ID is available
    if (requestId != null) {
      monitorRequestStatus();
    }
  }

  @override
  void dispose() {
    // Dispose of the stream controller when the widget is disposed
    requestStatusStreamController.close();
    super.dispose();
  }

  Future<void> monitorRequestStatus() async {
    // Define an interval (e.g., every 5 seconds) to check the request status
    const intervalDuration = Duration(seconds: 5);

    // Check if the requestId is available
    if (requestId == null) {
      print("id id null hihihihihhihiihih");
    }

    Timer.periodic(intervalDuration, (timer) async {
      // Make an HTTP request to fetch the request status
      final response = await http.get(
        Uri.parse("$api_request_status?request_id=$requestId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['data']['status'];
        print(status);

        // Add the status to the stream
        requestStatusStreamController.add(status);

        // If the status is "accepted," show the pop-up dialog
        if (status == 'accepted') {
          showDialog(
            context: context,
            builder: (context) => CustomDialogND(
              doctorName: widget.doctorName,
            ),
          );
          setState(() {
            isRequesting = false;
          });

          // Optionally stop monitoring the request status if needed
          timer.cancel();
        } else if (status == 'rejected') {
          // Show popup with request rejected message and icon for rejection
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
            Text('Your request has been rejected.'),
          ],
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () {
          // Set isRequesting back to false to enable request button
          setState(() {
            isRequesting = false;
          });
          Navigator.pop(context); // Close the dialog
        },
        child: Text('OK', style: TextStyle(color: AppColors.primaryColor),
),
      ),
    ],
  ),
);


          // Stop monitoring the request status since it's rejected
          timer.cancel();
        }
      } else {
        print('Failed to fetch request status');
      }
    });
  }

  Future<void> sendRequest() async {
    setState(() {
      isRequesting = true; // Set the state to "waiting"
    });

    // Retrieve the current logged-in patient ID from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? patientId = prefs.getString("user_id");

    // Check if patient ID is not null
    if (patientId != null) {
      // Send the request
      final url = Uri.parse(api_request_doctor);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'patient_id': patientId,
          'doctor_id': widget.doctorid,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        // Extract requestId from response
        requestId = responseData['request_id'];
        print('Consultation request created: ${responseData['message']}');

        // Start monitoring request status since we now have the requestId
        monitorRequestStatus();
      } else {
        final errorData = jsonDecode(response.body);
        // Handle error response
        print('Error: ${errorData['message']}');
      }
    } else {
      // Handle the case when patient ID is not available
      print('Error: No logged-in patient ID found');
    }

    // Set `isRequesting` back to false after sending the request
    setState(() {
      isRequesting = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0
      ),
      child: Padding(
        padding: const EdgeInsets.only(
            top: 8.0, bottom: 4.0, left: 16.0, right: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display doctor's name and location icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.doctorName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Display specialty and distance
            Row(
              children: [
                Text(
                  widget.specialty,
                  style: const TextStyle(
                    color: AppColors.greyColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Display the phone number
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 8.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.phone,
                    size: 16,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.phone,
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Display doctor's fee
                      const Text(
                        'Starting price :',
                        style: TextStyle(
                          color: AppColors.greyColor,
                        ),
                      ),
                      const SizedBox(width: 2), // Add a small space between the text and the price
                      Text(
                        widget.fee,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Display request button
                OutlinedButton(
                  onPressed: isRequesting
                      ? null
                      : sendRequest, // Disable button if request is in progress
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    side: const BorderSide(color: AppColors.primaryColor),
                  ),
                  child: Text(
                    isRequesting
                        ? "Waiting..."
                        : "Request", // Change button text based on `isRequesting`
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> requestConsultation(String patientId, String doctorId) async {
  final url = Uri.parse(api_request_doctor);
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'patient_id': patientId,
      'doctor_id': doctorId,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final responseData = jsonDecode(response.body);
    final requestId = responseData['request_id'];
    // Handle successful response
    print('Consultation request created: ${responseData['message']}');
  } else {
    final errorData = jsonDecode(response.body);
    // Handle error response
    print('Error: ${errorData['message']}');
  }
}
