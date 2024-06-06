import 'package:doctoguidedoctorapp/functions/functions.dart';
import 'package:doctoguidedoctorapp/models/patient.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailedCancelledConsultation extends StatefulWidget {
  final Patient patient;
  const DetailedCancelledConsultation({super.key, required this.patient});
  @override
  State<DetailedCancelledConsultation> createState() => _DetailedCancelledConsultationState();
} 

class _DetailedCancelledConsultationState extends State<DetailedCancelledConsultation> {
  int age =0;
  @override
  void initState() {
    super.initState();
    // Calculate the age in the initState method
    age = calculateAge(widget.patient.birthDate);
    print('Age: $age');
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title:
            // you can forcefully translate values left side using Transform
            const Text(
          'Consultation Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold, // Make the text bold
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // Remove appbar shadow
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Request Box
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
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
                    
                    //Patient information with problem desciption
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFE8F3F1),
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: Color(0xFF199A8E),
                                width: 1.0, // Set the border width
                              ),
                            ),
                            child:  Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.patient.gender, // Gender
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  age.toString(), // Age
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  widget.patient.symptoms, // Symptoms description
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }
}
