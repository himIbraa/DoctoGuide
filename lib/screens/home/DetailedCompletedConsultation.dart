// ignore_for_file: prefer_const_constructors

import 'package:doctoguidedoctorapp/functions/functions.dart';
import 'package:doctoguidedoctorapp/models/patient.dart';
import 'package:doctoguidedoctorapp/screens/medical%20information/MedicalHistory.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/request.dart';

class DetailedCompletedConsultation extends StatefulWidget {
  final Patient patient;
  const DetailedCompletedConsultation({Key? key, required this.patient}) : super(key: key);
  @override
  State<DetailedCompletedConsultation> createState() =>
      _DetailedCompletedConsultationState();
}

class _DetailedCompletedConsultationState
    extends State<DetailedCompletedConsultation> {
  int age = 0;
  late String userId;
  TextEditingController _fileController = TextEditingController();
  late SharedPreferences _prefs;
  @override
  void initState() {
    super.initState();
    getId();
    _loadData();
    // Calculate the age in the initState method
    age = calculateAge(widget.patient.birthDate);
    print('Age: $age');
  }

  Future<void> getId() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      setState(() {});
      userId = _prefs.getString('user_id') ?? '';
      // Debug prints
      print('____________User ID: $userId');
    } catch (ex, st) {
      print('Error: $ex $st');
    }
  }

  Future<void> _loadData() async {
    try {
      final data = await supabase
          .from('consultationrequest')
          .select()
          .eq('did', userId)
          .eq('pid', widget.patient.id_patient)
          .single();

      _fileController.text = (data['docs']) as String;
      print(_fileController.text);

      //print(data);

      setState(() {});
    } catch (ex, st) {
      print('$ex $st ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: const Text(
          'Consultation Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFE8F3F1),
                      width: 2.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage('lib/assets/images/profile_picture.png'),
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
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.patient.phoneNumber,
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F3F1),
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: const Color(0xFF199A8E),
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.patient.gender,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    age.toString(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.patient.symptoms,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MedicalHistory(
                                                patient: widget.patient,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFE8F3F1),
                                          side: const BorderSide(
                                            color: Color(0xFF199A8E),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: const Text(
                                          'Medical History',
                                          style: TextStyle(color: Color(0xFF199A8E)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Handle GPS position tap
                              },
                              child: const Text(
                                'Report',
                                style: TextStyle(color: Colors.black, fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBFBFB),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFE8F3F1),
                              width: 2.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.patient.consultationReport,
                                  style: const TextStyle(
                                    color: Color(0xFF000000),
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0).copyWith(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.green,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      String fileUrl = _fileController.text;
                                      Uri uri = Uri.parse(fileUrl);
        
                                      await launchUrl(uri);
                                    },
                                    child: Text(
                                      'report.pdf',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.green,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.download,
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Handle GPS position tap
                              },
                              child: const Text(
                                'Consultation fee',
                                style: TextStyle(color: Colors.black, fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBFBFB),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFE8F3F1),
                              width: 2.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.patient.consultationType,
                                  style: const TextStyle(
                                    color: Color(0xFF000000),
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                widget.patient.consultationPrice,
                                style: const TextStyle(
                                  color: Color(0xFF000000),
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0).copyWith(left: 30),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF555555),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.patient.completionTime != null 
  ? DateFormat('dd/MM/yyyy').format(widget.patient.completionTime!)
  : 'N/A',

                              style: const TextStyle(
                                color: Color(0xFF555555),
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.access_time,
                              color: Color(0xFF555555),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.patient.completionTime != null 
  ? DateFormat('HH:mm').format(widget.patient.completionTime!)
  : 'N/A',

                              style: const TextStyle(
                                color: Color(0xFF555555),
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.yellow,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Completed',
                              style: TextStyle(
                                color: Color(0xFF555555),
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
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
      ),
    );
  }
}
