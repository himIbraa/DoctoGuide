import 'package:flutter/material.dart';
import 'package:doctoguide/screens/history/DetailsNonConsulted.dart'; 
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doctoguide/constants/endpoints.dart';
import 'package:doctoguide/theme/theme.dart';


// Define a data model for your history items
class HistoryItem {
  final String specialistType;
  final String symptom;
  final String date;
  final String time;

  HistoryItem({
    required this.specialistType,
    required this.symptom,
    required this.date,
    required this.time,
  });
}



class NonConsultedHistory extends StatefulWidget {
  final int patientId; // Accepting patient ID as a parameter

  const NonConsultedHistory({super.key, required this.patientId});

  @override
  _NonConsultedHistoryState createState() => _NonConsultedHistoryState();
}

class _NonConsultedHistoryState extends State<NonConsultedHistory> {
  List<HistoryItem> displayedHistoryItems = [];
  bool isLoading = true;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    fetchHistoryData(); // Fetch history data when the page initializes
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Fetching the data from the API endpoint
  Future<void> fetchHistoryData() async {
    final response = await http.get(
        Uri.parse('$api_endpoint_History1${widget.patientId}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final historyItems = (data['data'] as List).map((item) {
        return HistoryItem(
          specialistType: item['result'],
          symptom: item['symptoms'],
          date: _formatDateTime(item['created_at']).split(' ')[0], // Format date
          time: _formatDateTime(item['created_at']).split(' ')[1], // Format time
        );
      }).toList();

      setState(() {
        displayedHistoryItems = historyItems;
        isLoading = false;
      });
    } else {
      // Handle error case
      print('Failed to load search history data');
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
                item.specialistType.toLowerCase().contains(query.toLowerCase()) ||
                item.symptom.toLowerCase().contains(query.toLowerCase()))
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
                      hintText: 'Search History , Specialist ...',
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
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
              : Expanded(
                  child: ListView.builder(
                    itemCount: displayedHistoryItems.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsNonConsultedPage(
                                specialistType: displayedHistoryItems[index].specialistType,
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
                              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
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
                                      displayedHistoryItems[index].specialistType,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // Symptoms
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                      vertical: 10.0,
                                    ),
                                    child: Text(
                                      _truncateText(displayedHistoryItems[index].symptom),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  // Date, Time, and Status
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                      vertical: 10.0,
                                    ),
                                    child: Row(
                                      children: [
                                        // Date Icon
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
                                        // Time Icon
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

// Truncate long text for display purposes
String _truncateText(String text) {
  const int maxLength = 40; // Adjust the maximum length as needed
  return text.length <= maxLength ? text : '${text.substring(0, maxLength - 3)}...';
}
