// ignore_for_file: prefer_const_constructors

import 'package:doctoguide/screens/profile/my_profile.dart';
import 'package:doctoguide/theme/theme.dart';
import 'package:flutter/material.dart';


class medicalInfo extends StatefulWidget {
  final String userId;
  const medicalInfo({super.key, 
    required this.userId,
  });
  @override
  _MedicalInfoPageState createState() => _MedicalInfoPageState();
}

class _MedicalInfoPageState extends State<medicalInfo> {
  final TextEditingController _medicalHistoryController =
      TextEditingController();
  List<String> _medicalHistoryList = [];

  @override
  void initState() {
    super.initState();
    // Fetch medical history data from Supabase when the page initializes
    _fetchMedicalHistory();
  }

  Future<void> _fetchMedicalHistory() async {
    final response = await supabase.from('patientMedHistory').select('medInfo').eq('id_patient', widget.userId);
    if (response != null) {
      final List<dynamic>? data = response;
      setState(() {
        print('fetch');
        _medicalHistoryList = List<String>.from(
            data?.map((item) => item['medInfo'].toString()) ?? []);
        print('fetched');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(
          title: 
            //padding: EdgeInsets.only(left: 90.0), // Adjust left padding as needed
            Text(
              'Medical Information',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                 // Make text bold
                 
              ),
            ),
          
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate back to the previous screen (SplashScreen)
              Navigator.pop(context);
            },
          ),
        ),
         body: Padding(
           padding: const EdgeInsets.all(15.0),
           child: ListView.builder(
            itemCount: _medicalHistoryList.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  _medicalHistoryList[index],
                  style: TextStyle(fontSize: 18.0),
                ),
              );
            },
                   ),
         ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(25.0),
          child: FloatingActionButton(
            onPressed: () {
              _showAddMedicalHistoryDialog(context);
            },
            backgroundColor: AppColors.primaryColor,
            child: Icon(Icons.add, color: Colors.white,), // Change background color of the FAB
          ),
        ),

      ),
    );
  }

  Future<void> _showAddMedicalHistoryDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Medical History'),
          content: TextField(
            controller: _medicalHistoryController,
            decoration: InputDecoration(
              hintText: 'Enter medical history',
              
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: AppColors.primaryColor)),
            ),
            ElevatedButton(
              onPressed: () {
                _addMedicalHistory();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor, // Background color of the button
            ),
              child: Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addMedicalHistory() async {
    String medicalHistory = _medicalHistoryController.text.trim();

    if (medicalHistory.isNotEmpty) {
      // Send medical history data to Supabase
      await _addToSupabase(medicalHistory);

      // Clear text input field
      _medicalHistoryController.clear();

      // Update medical history list
      setState(() {
        _medicalHistoryList.add(medicalHistory);
      });
    }
  }

  Future<void> _addToSupabase(String medicalHistory) async {
    try {
      print('before insert');
      final response = await supabase
          .from('patientMedHistory')
          .insert({'id_patient': widget.userId, 'medInfo': medicalHistory});
      print('after insert');
    } catch (ex, st) {
      print('$ex $st ');
      print('_________insert failed');
    }
  }
}
