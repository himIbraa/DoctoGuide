import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:doctoguide/theme/theme.dart';
import 'package:doctoguide/screens/history/DetailsConsulted.dart';
import 'package:doctoguide/constants/endpoints.dart';


// Define a data model for your consulted history items
class ConsultedHistoryItem {
  final String specialistType;
  final String doctorName;
  final String doctorPhoneNumber;
  final String symptom;
  final String date;
  final String time;
  final int id_doctor;

  ConsultedHistoryItem({
    required this.specialistType,
    required this.doctorName,
    required this.doctorPhoneNumber,
    required this.symptom,
    required this.date,
    required this.time,
    required this.id_doctor,
  });
}

class ConsultedHistory extends StatefulWidget {
  final int patientId; // Accepting patient ID as a parameter

  const ConsultedHistory({super.key, required this.patientId});

  @override
  _ConsultedHistoryState createState() => _ConsultedHistoryState();
}

class _ConsultedHistoryState extends State<ConsultedHistory> {
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
    final response = await http.get(Uri.parse(
        '$api_endpoint_History${widget.patientId}')); 
        // Replace API_ENDPOINT_HERE with your actual API endpoint

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final historyItems = (data['data'] as List).map((item) {
        final history = item['searchHistory'];
        final doctor = item['doctor'];
        print('------------before');
        final consultation = item['consultation'];
        print('------------after');
        return ConsultedHistoryItem(
          specialistType: history['result'],
          doctorName: doctor['name'],
          doctorPhoneNumber: doctor['phone'],
          symptom: history['symptoms'],
          date: _formatDateTime(history['created_at'])
              .split(' ')[0], // Format date
          time: _formatDateTime(history['created_at'])
              .split(' ')[1], // Format time
          id_doctor: consultation['did'], // Extracting doctor ID (did)
        );
        
      }).toList();
print('------------before');
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
    return '${"${dt.toLocal()}".split(' ')[0]} ${"${dt.toLocal()}".split(' ')[1].substring(0, 5)}';
  }

  void filterHistoryItems(String query) {
    setState(() {
      if (query.isNotEmpty) {
        displayedHistoryItems = displayedHistoryItems
            .where((item) =>
                item.specialistType
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                item.symptom.toLowerCase().contains(query.toLowerCase()) ||
                item.doctorName.toLowerCase().contains(query.toLowerCase()) ||
                item.doctorPhoneNumber
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                item.id_doctor
                    .toString()
                    .contains(query)) // Include doctor ID in search
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            margin: const EdgeInsets.only(top: 20, bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F3F1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE8F3F1),
                width: 2.0,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  color: Color(0xFF199A8E),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: filterHistoryItems,
                    decoration: const InputDecoration(
                      hintText: 'Search History, Specialist, Doctor...',
                      hintStyle: TextStyle(
                        color: Color(0xFF199A8E),
                        fontWeight: FontWeight.w400,
                        fontSize: 17,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryColor))
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
                                specialistType:
                                    displayedHistoryItems[index].specialistType,
                                doctorName:
                                    displayedHistoryItems[index].doctorName,
                                doctorPhoneNumber: displayedHistoryItems[index]
                                    .doctorPhoneNumber,
                                symptom: displayedHistoryItems[index].symptom,
                                date: displayedHistoryItems[index].date,
                                time: displayedHistoryItems[index].time,
                                id_doctor: displayedHistoryItems[index]
                                    .id_doctor, // Include doctor ID
                                id_patient: widget.patientId,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Request Box
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.6),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
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
                                      displayedHistoryItems[index]
                                          .specialistType,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayedHistoryItems[index]
                                              .doctorName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                                FontWeight.w500, // Semibold
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                        Text(
                                          displayedHistoryItems[index]
                                              .doctorPhoneNumber,
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
                                      _truncateText(
                                          displayedHistoryItems[index].symptom),
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
                                        const SizedBox(width: 4),
                                        Text(
                                          displayedHistoryItems[index].date,
                                          style: const TextStyle(
                                            color: Color(0xFF555555),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        const Icon(
                                          Icons.access_time,
                                          color: Color(0xFF555555),
                                          size: 15,
                                        ),
                                        const SizedBox(width: 2),
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
  return text.length <= maxLength
      ? text
      : '${text.substring(0, maxLength - 3)}...';
}
