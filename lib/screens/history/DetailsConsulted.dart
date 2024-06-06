// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:doctoguide/theme/theme.dart';
import 'package:doctoguide/widgets/BottomNavBar.dart'; // Import the BottomNavBar widget

import '../profile/my_profile.dart';

class DetailsConsultedPage extends StatefulWidget {
  final String specialistType;
  final String doctorName;
  final String doctorPhoneNumber;
  final String symptom;
  final String date;
  final String time;
  final int id_doctor;
  final int id_patient;

  const DetailsConsultedPage({super.key, 
    required this.specialistType,
    required this.doctorName,
    required this.doctorPhoneNumber,
    required this.symptom,
    required this.date,
    required this.time,
    required this.id_doctor,
    required this.id_patient,
  });

  @override
  State<DetailsConsultedPage> createState() => _DetailsConsultedPageState();
}

class _DetailsConsultedPageState extends State<DetailsConsultedPage> {
  final TextEditingController _fileController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {

      final data = await supabase
        .from('consultationrequest')
        .select()
        .eq('did', widget.id_doctor)
        .eq('pid', widget.id_patient)
        .single();


      _fileController.text = (data['docs']) as String;

      print(data);

      setState(() {});
    } catch (ex, st) {
      print('$ex $st ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.specialistType,
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                border: Border.all(
                  color: AppColors.primaryColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.symptom,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Doctor Report',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightGreyColor,
                border: Border.all(
                  color: AppColors.greyColor,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1.The patient reports symptoms including nasal congestion, sneezing, itching of the eyes, and a clear nasal discharge,\n 2.Allergic rhinitis, likely due to [specific allergens].\n3.Possible allergic conjunctivitis.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryColor,
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
                              'ordonance.pdf',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: AppColors.primaryColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.download,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: AppColors.darkgreyColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      widget.date,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkgreyColor,
                      ),
                    ),
                    SizedBox(width: 20),
                    Icon(
                      Icons.access_time,
                      size: 20,
                      color: AppColors.darkgreyColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      widget.time,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkgreyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
          selectedTab: '/history'), // Pass 'history' as selectedTab
    );
  }
}
