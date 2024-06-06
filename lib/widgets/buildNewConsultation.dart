import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:doctoguidedoctorapp/constants/endpoints.dart';
import 'package:doctoguidedoctorapp/functions/functions.dart';
import 'package:doctoguidedoctorapp/models/patient.dart';
import 'package:doctoguidedoctorapp/models/request.dart';
import 'package:doctoguidedoctorapp/screens/medical%20information/MedicalHistory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';
import '../models/map.dart';

class buildNewConsultation extends StatefulWidget {
  final Patient patient;

  const buildNewConsultation({super.key, required this.patient});

  @override
  State<buildNewConsultation> createState() => _buildNewConsultationState();
}

class _buildNewConsultationState extends State<buildNewConsultation> {
  late String _userId;
  late SharedPreferences _prefs;
  late String filePath;
  late String fileUrlResponse;
  
  List<Map<String, dynamic>> consultation_prices = [];
  int? selectedConsultation;
  final TextEditingController _reportController = TextEditingController();
  int age = 0;

  void updateToCancelled(Patient patient) async {
    try {
      // Remove item from liked items and update the UI
      await context.read<Request>().updateToCancelled(patient);
    } catch (error) {
      print('Error updating status to cancelled: $error');
      // Handle the error as needed
    }
  }

  // void updateToCompleted(Patient patient) async {
  //   try {
  //     // Remove item from liked items and update the UI
  //     await context.read<Request>().updateToCompleted(patient);
  //   } catch (error) {
  //     print('Error updating status to completed: $error');
  //     // Handle the error as needed
  //   }
  // }

  void addConsultation(Patient patient, String report, DateTime completionTime,
      int selectedConsultation) async {
    try {
      print('Adding consultation...');
      print('Patient: ${patient.toString()}');
      print('Report: $report');
      print('Completion Time: $completionTime');
      print('Selected Consultation: $selectedConsultation');

      // Remove item from liked items and update the UI
      await context.read<Request>().addConsultation(
          patient, report, completionTime, selectedConsultation);

      
      
      print('Consultation added successfully');
    } catch (error) {
      print('Error adding consultation: $error');
      // Handle the error as needed
    }
}


  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserData();
    fetchConsultationPrices();
    // Calculate the age in the initState method
    age = calculateAge(widget.patient.birthDate);
    print('Age: $age');
  }

  Future<void> _loadUserData() async {
    _prefs = await SharedPreferences.getInstance();

    setState(() {
      _userId = _prefs.getString('user_id') ?? '';
      print(_userId);
    });
  }

  Future<void> fetchConsultationPrices() async {
    try {
      print("in");
      final url = '$api_endpoint_consultation_prices_get?id_doctor=$_userId';
      print('Request URL: $url');

      final response = await dio.get(url);
      print('Response: $response');

      print(response);
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          // Update the wilayas list with the fetched wilayas
          consultation_prices =
              List<Map<String, dynamic>>.from(jsonDecode(response.data));
          print(consultation_prices);
        });
      } else {
        print('Error fetching wilayas: ${response.statusCode}');
      }
    } catch (error) {
      print('Dio error: $error');
    }
  }


  void uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        try {
          // Read file bytes
          final bytes = await File(filePath).readAsBytes();
          final fileExt = filePath.split('.').last;
          final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
          final storagePath = 'doctorfile/$fileName';

          // Upload the file to Supabase Storage
          await supabase.storage.from('doctorfile').uploadBinary(
                storagePath,
                bytes,
                fileOptions: FileOptions(contentType: 'application/$fileExt'),
              );

          print('Upload Successful');

          // Get the signed URL for the uploaded file
          fileUrlResponse = await supabase.storage
              .from('doctorfile')
              .createSignedUrl(storagePath, 60 * 60 * 24 * 365 * 10);

          print('File URL: $fileUrlResponse');


//----------------------------------
          try {
            print('before insert');
            final response = await supabase
            .from('consultationrequest')
            .update({
              'docs': fileUrlResponse, // Replace 'yourDocsString' with the actual value
            })
            .eq('pid', widget.patient.id_patient)
            .eq('did', _userId)
            .execute();
          print('after update');

          } catch (ex, st) {
            print('$ex $st ');
            print('_________insert failed');
          }
        
          setState(() {
            // Update UI if needed
          });
        } catch (error) {
          // Handle file upload errors
          print('Error uploading file: $error');
          // Show error message to the user if needed
        }
      } else {
        // Handle the case when filePath is null
        print('No file path available');
        // Show error message to the user if needed
      }
    } else {
      // Handle the case when result is null or files list is empty
      print('No file selected');
      // Show error message to the user if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                        const CircleAvatar(
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
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.patient.phoneNumber,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Patient GPS Position - Second Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Row(
                      children: [
          //Image.asset('assets/icons/location_arrow.png'),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        onPressed: () async {
                          // Handle GPS position tap
                          print('_______________________pressed');
                          try {
                            print('before fetch');
                            final locationData = await fetchPatientLocation
                                .fetchPatient(widget.patient.id_patient);
                            final latitude = locationData['latitude'].toString();
                          
                            final longitude = locationData['longitude'].toString();
                            print('Latitude: $latitude, Longitude: $longitude');
                            print('after fetch');
                            MapUtils.openMap(latitude, longitude);
                            print('after open map');
                          } catch (e) {
                            print('Error fetching patient location: $e');
                          }
                        },
                        child: Text(
                          'Patient Location',
                          style:
                              TextStyle(color: Color(0xFF199A8E), fontSize: 16),
                        ),
                      ),
                      ],
                    ),
                  ),
                  //Patient information with problem desciption and medical information 
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
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.patient.gender, // Gender
                                style: const TextStyle(
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
                              SizedBox(
                                  height:
                                      16), // Add space between symptoms and button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MedicalHistory(
                                                    patient: widget.patient)),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(
                                          0xFFE8F3F1), // Use the same background color as the container
                                      side: BorderSide(
                                          color: Color(0xFF199A8E),
                                          width:
                                              1.0), // Use the same border color as the container
                                    ),
                                    child: Text(
                                      'Medical History',
                                      style: TextStyle(
                                          color: Color(
                                              0xFF199A8E)), // Use the same text color as the container's border color
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
                  //Report
                  const Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Report',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                  //Report field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _reportController,
                              onChanged: (value) {
                                //print("Search Query: $value");
                                //_updateSearchResults(value);
                              },
                              decoration: const InputDecoration(
                                hintText:
                                    'Add your consultation report and documents',
                                hintStyle: TextStyle(
                                  color: Color(0xFFADADAD),
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
                  ),
                  // Browse Buttons
                  Padding(
                    padding: EdgeInsets.only(right: 20.0).copyWith(bottom: 20),
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          // Add your button onPressed functionality here
                          uploadFile();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.white, // Button background color
                          side: const BorderSide(
                              color: Color(0xFF199A8E),
                              width: 2), // Button border
                        ),
                        child: const Text(
                          'Browse',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF199A8E),
                          ),
                        ),
                      ),
                    ),
                  ),
                  //Consultation fee
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Consultation Fee',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBFBFB),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFE8F3F1),
                              width: 2.0,
                            ),
                          ),
                          child: DropdownButton<int>(
                            value: selectedConsultation,
                            onChanged: (value) {
                              setState(() {
                                selectedConsultation = value!;
                                print(selectedConsultation);
                              });
                            },
                            hint: const Text(
                              'Select consultation type', // Add your hint text here
                              style: TextStyle(
                                color: Color(0xFFADADAD),
                                fontWeight: FontWeight.w400,
                                fontSize: 17,
                              ),
                            ),
                            items: consultation_prices
                                .map<DropdownMenuItem<int>>((type) {
                              return DropdownMenuItem<int>(
                                value: type['id'] as int,
                                child: Row(
                                  children: [
                                    Text(type['type'].toString()),
                                    const SizedBox(
                                        width:
                                            12), // Add some space between type and price
                                    Text(type['price'].toString()),
                                  ],
                                ),
                              );
                            }).toList(),
                            isExpanded: true,
                            underline: SizedBox(),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF199A8E),
                              size: 50,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action Buttons - Fourth Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0)
                        .copyWith(bottom: 20)
                        .copyWith(top: 7),
                    child: SizedBox(
                      height: 50, // Set the height of the SizedBox
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                updateToCancelled(widget.patient);
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xFF555555)),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFE8F3F1),
                                padding: EdgeInsets.all(13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10), // Add space between buttons
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                //updateToCompleted(widget.patient);
                                DateTime completionTime = DateTime
                                    .now(); // Assuming completion time is current time
                                String report = _reportController
                                    .text; // Get report from TextField using controller
                                if (selectedConsultation != null) {
                                  addConsultation(widget.patient, report,
                                      completionTime, selectedConsultation!);
                                  Navigator.pushReplacementNamed(context, '/home');
                                } else {
                                  // Handle the case when selectedConsultation is null
                                }
                              },
                              child: Text(
                                'Completed',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF199A8E),
                                padding: EdgeInsets.all(13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
