import 'package:doctoguidedoctorapp/models/request.dart';
import 'package:doctoguidedoctorapp/widgets/BottomNavBar.dart';
import 'package:doctoguidedoctorapp/widgets/buildNewConsultation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewConsultation extends StatefulWidget {
  const NewConsultation({super.key});

  @override
  State<NewConsultation> createState() => _NewConsultationState();
}

class _NewConsultationState extends State<NewConsultation> {
  String status = "accepted";
  @override
  Widget build(BuildContext context) {
    final Requests = Provider.of<Request>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0.0,
        title: Transform(
          // you can forcefully translate values left side using Transform
          transform: Matrix4.translationValues(30, 12.0, 0.0),
          child: const Text(
            'New Consultation',
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
      body: FutureBuilder<void>(
          future: Requests.fetchRequests(status),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              // Access the products
              final requests = Requests.consultations;

              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final patient = requests[index];
                  return buildNewConsultation(patient: patient);
                },
              );
            }
          }),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
