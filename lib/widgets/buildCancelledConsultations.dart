import 'package:doctoguidedoctorapp/models/patient.dart';
import 'package:doctoguidedoctorapp/screens/home/DetailedCancelledConsultation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class buildCancelledConsultations extends StatefulWidget {
  final Patient patient;
  const buildCancelledConsultations({super.key, required this.patient});

  @override
  State<buildCancelledConsultations> createState() => _buildCancelledConsultationsState();
}

class _buildCancelledConsultationsState extends State<buildCancelledConsultations> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
    child: Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        children: [
          
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailedCancelledConsultation(patient: widget.patient)),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Request Box
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.6), // Shadow color
                        spreadRadius: 2, // Spread radius
                        blurRadius: 5, // Blur radius
                        offset: Offset(0, 3), // Offset in x and y direction
                      ),
                    ],
                    border: Border.all(
                      color: Color(0xFFE8F3F1), // Set the border color
                      width: 2.0, // Set the border width
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Patient Information - First Row
                       Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(
                                  'lib/assets/images/profile_picture.png'), // Placeholder image
                              radius: 30,
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.patient.name,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  widget.patient.phoneNumber,
                                  style:
                                      TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Date, Time, and Status - Third Row
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0)
                            .copyWith(left: 30),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF555555),
                              size: 18, // Reduce the size of the icon
                            ),
                            const SizedBox(width: 6),
                             Text(
                              widget.patient.completionTime != null 
  ? DateFormat('dd/MM/yyyy').format(widget.patient.completionTime!)
  : 'N/A',

                              style: TextStyle(
                                color: Color(0xFF555555),
                                fontStyle: FontStyle.italic,
                                fontSize: 14, // Reduce the font size
                              ),
                            ),
                            const SizedBox(
                                width:
                                    10), // Increase spacing between date and time
                            const Icon(
                              Icons.access_time,
                              color: Color(0xFF555555),
                              size: 18, // Reduce the size of the icon
                            ),
                            const SizedBox(width: 6),
                             Text(
                              widget.patient.completionTime != null 
  ? DateFormat('HH:mm').format(widget.patient.completionTime!)
  : 'N/A',
                              style: TextStyle(
                                color: Color(0xFF555555),
                                fontStyle: FontStyle.italic,
                                fontSize: 14, // Reduce the font size
                              ),
                            ),
                            const SizedBox(
                                width:
                                    10), // Increase spacing between time and status
                            Container(
                              width:
                                  8, // Reduce the width of the small yellow circle
                              height:
                                  8, // Reduce the height of the small yellow circle
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Cancelled',
                              style: TextStyle(
                                color: Color(0xFF555555),
                                fontStyle: FontStyle.italic,
                                fontSize: 14, // Reduce the font size
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
          ),
        ],
      ),
    ),
  );
  // Visibility(
  //   visible: searchQuery.isNotEmpty,
  //   child: SearchProduct(searchQuery: _searchController.text),
  // )
}

}