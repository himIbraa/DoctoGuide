import 'package:doctoguidedoctorapp/constants/endpoints.dart';
import 'package:doctoguidedoctorapp/models/patient.dart';
import 'package:doctoguidedoctorapp/screens/medical%20information/DetailsConsultedPage.dart';
import 'package:doctoguidedoctorapp/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Define a data model for your consulted history items
class ConsultedHistoryItem {
  final String specialistType;
  final String doctorName;
  final String doctorPhoneNumber;
  final String symptom;
  final String date;
  final String time;

  ConsultedHistoryItem({
    required this.specialistType,
    required this.doctorName,
    required this.doctorPhoneNumber,
    required this.symptom,
    required this.date,
    required this.time,
  });
}

class buildMedicalHistory extends StatefulWidget {
  final Patient patient; // Accepting patient ID as a parameter

  buildMedicalHistory({required this.patient});

  @override
  _buildMedicalHistoryState createState() => _buildMedicalHistoryState();
}

class _buildMedicalHistoryState extends State<buildMedicalHistory> {
  List<ConsultedHistoryItem> displayedHistoryItems = [];
  late TextEditingController searchController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    fetchHistoryData(); // Fetch consulted history data when the page initializes
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Fetching the consulted history data from the API endpoint
  Future<void> fetchHistoryData() async {
    print(widget.patient.id_patient);
    // Construct the URI
final Uri uri = Uri.parse('$api_endpoint_consultation_history_get?patient_id=${widget.patient.id_patient}');

// Print the URI for debugging
print('Debugging URI: $uri');

// Make the HTTP request
final response = await http.get(uri);

// Check the response
print('Response status code: ${response.statusCode}');
print('Response body: ${response.body}');// Replace API_ENDPOINT_HERE with your actual API endpoint

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final historyItems = (data['data'] as List).map((item) {
        final history = item['searchHistory'];
        final doctor = item['doctor'];
                  print(history['result']);

        return ConsultedHistoryItem(
          specialistType: history['result'],
          doctorName: doctor['name'],
          doctorPhoneNumber: doctor['phone'],
          symptom: history['symptoms'],
          date: _formatDateTime(history['created_at']).split(' ')[0], // Format date
          time: _formatDateTime(history['created_at']).split(' ')[1], // Format time
        );
      }).toList();

      setState(() {
        displayedHistoryItems = historyItems;
        isLoading = false;
      });
    } else {
      // Handle error case
      print('Failed to load consulted history data');
    }
  }

  // Helper method to format date and time
  String _formatDateTime(String dateTime) {
    DateTime dt = DateTime.parse(dateTime);
    return "${dt.toLocal()}".split(' ')[0] + ' ' + "${dt.toLocal()}".split(' ')[1].substring(0, 5);
  }

  void filterHistoryItems(String query) {
    setState(() {
      if (query.isNotEmpty) {
        displayedHistoryItems = displayedHistoryItems
            .where((item) =>
                item.specialistType.toLowerCase().contains(query.toLowerCase()) ||
                item.symptom.toLowerCase().contains(query.toLowerCase()) ||
                item.doctorName.toLowerCase().contains(query.toLowerCase()) ||
                item.doctorPhoneNumber.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        fetchHistoryData(); // Re-fetch the data if the search query is empty
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          isLoading
              ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
              : Expanded(
                  child: ListView.builder(
                    itemCount: displayedHistoryItems.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsConsultedPage(
                                specialistType: displayedHistoryItems[index].specialistType,
                                doctorName: displayedHistoryItems[index].doctorName,
                                doctorPhoneNumber: displayedHistoryItems[index].doctorPhoneNumber,
                                symptom: displayedHistoryItems[index].symptom,
                                date: displayedHistoryItems[index].date,
                                time: displayedHistoryItems[index].time,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Request Box
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.6),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Type of Specialist
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                      vertical: 10.0,
                                    ),
                                    child: Text(
                                      displayedHistoryItems[index].specialistType,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // Doctor Details
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                      vertical: 10.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayedHistoryItems[index].doctorName,
                                          style:const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500, // Semibold
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                        Text(
                                          displayedHistoryItems[index].doctorPhoneNumber,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Symptoms
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                      vertical: 5.0,
                                    ),
                                    child: Text(
                                      _truncateText(displayedHistoryItems[index].symptom),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  // Date and Time
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                      vertical: 10.0,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          color: Color(0xFF555555),
                                          size: 15,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          displayedHistoryItems[index].date,
                                          style: const TextStyle(
                                            color: Color(0xFF555555),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        SizedBox(width: 15),
                                        const Icon(
                                          Icons.access_time,
                                          color: Color(0xFF555555),
                                          size: 15,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          displayedHistoryItems[index].time,
                                          style: const TextStyle(
                                            color: Color(0xFF555555),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

// Helper function to truncate the text to a maximum length of 40 characters.
String _truncateText(String text) {
  const int maxLength = 40;
  return text.length <= maxLength ? text : text.substring(0, maxLength - 3) + '...';
}
