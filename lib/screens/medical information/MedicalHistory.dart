import 'package:doctoguidedoctorapp/models/patient.dart';
import 'package:doctoguidedoctorapp/screens/medical%20information/medicalInfo.dart';
import 'package:doctoguidedoctorapp/widgets/BottomNavBar.dart';
import 'package:doctoguidedoctorapp/widgets/buildMedicalHistory.dart';
import 'package:flutter/material.dart';

class MedicalHistory extends StatefulWidget {
  final Patient patient;
  const MedicalHistory({super.key, required this.patient});

  @override
  State<MedicalHistory> createState() => _MedicalHistoryState();
}

class _MedicalHistoryState extends State<MedicalHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0.0,
        title: Transform(
          // you can forcefully translate values left side using Transform
          transform: Matrix4.translationValues(30, 12.0, 0.0),
          child: const Text(
            'Medical History',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold, // Make the text bold
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // Remove appbar shadow
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 36.0).copyWith(top: 20),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage(
                      'lib/assets/images/profile_picture.png'), // Placeholder image
                  radius: 30,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.patient.name,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.patient.phoneNumber,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigate to another page when the container is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                medicalInfo(userId: widget.patient.id_patient)),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBFBFB),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE8F3F1),
                          width: 2.0,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'See and Edit Antecedents',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                  buildMedicalHistory(patient: widget.patient),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
