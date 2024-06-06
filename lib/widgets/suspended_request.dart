import 'package:doctoguidedoctorapp/functions/functions.dart';
import 'package:doctoguidedoctorapp/models/map.dart';
import 'package:doctoguidedoctorapp/models/patient.dart';
import 'package:doctoguidedoctorapp/models/request.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SuspendedRequest extends StatefulWidget {
  final Patient patient;
  const SuspendedRequest({super.key, required this.patient});

  @override
  State<SuspendedRequest> createState() => _SuspendedRequestState();
}

class _SuspendedRequestState extends State<SuspendedRequest> {
  int age = 0;
  void updateToAccepted(Patient patient) async {
    try {
      // Remove item from liked items and update the UI
      await context.read<Request>().updateToAccepted(patient);
    } catch (error) {
      print('Error updating status to accepted: $error');
      // Handle the error as needed
    }
  }

  void updateToRejected(Patient patient) async {
    try {
      // Remove item from liked items and update the UI
      await context.read<Request>().updateToRejected(patient);
    } catch (error) {
      print('Error updating status to rejected: $error');
      // Handle the error as needed
    }
  }

  @override
  void initState() {
    super.initState();
    // Calculate the age in the initState method
    age = calculateAge(widget.patient.birthDate);
    print('Age: $age');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
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

                      Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.red, // Set the color to red
                          ),
                          SizedBox(width: 8),
                          Text(
                            '12 min',
                            style: TextStyle(
                                color: Colors.red), // Set the color to red
                          ),
                          SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
  padding: const EdgeInsets.symmetric(vertical: 16.0),
  child: FractionallySizedBox(
    widthFactor: 0.9, // Set the width factor to determine the fraction of available width
    alignment: Alignment.center, // Align the container in the center
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Color(0xFFE8F3F1),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Color(0xFF199A8E),
              width: 1.0, // Set the border width
            ),
          ),
          child: Column(
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
              if (widget.patient.symptoms != null && widget.patient.symptoms!.isNotEmpty) 
                Text(
                  widget.patient.symptoms!, // Symptoms description
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
),


                // Date, Time, and Status - Third Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10, // Width of the small orange circle
                            height: 10, // Height of the small orange circle
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange, // Set the color to orange
                            ),
                          ),
                          SizedBox(width: 8),
                          const Text(
                            'Suspended',
                            style: TextStyle(
                                color: Color(0xFF555555),
                                fontStyle: FontStyle
                                    .italic), // Set the text color to grey and make it italic
                          ),
                        ],
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
                              updateToRejected(widget.patient);
                            },
                            child: Text(
                              'Reject',
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
                              updateToAccepted(widget.patient);
                              Navigator.pushReplacementNamed(
                                  context, '/New Consultation');
                            },
                            child: Text(
                              'Accept',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
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
    );
  }
}
