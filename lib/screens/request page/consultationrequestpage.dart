import 'package:doctoguidedoctorapp/models/request.dart';
import 'package:doctoguidedoctorapp/widgets/BottomNavBar.dart';
import 'package:doctoguidedoctorapp/widgets/suspended_request.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConsultationRequestPage extends StatelessWidget {
  String status = "suspended";
  @override
  Widget build(BuildContext context) {
    

    // ignore: non_constant_identifier_names
    final Requests = Provider.of<Request>(context);

    //String status = suspended;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0.0,
        title: Transform(
          // you can forcefully translate values left side using Transform
          transform: Matrix4.translationValues(30, 12.0, 0.0),
          child: const Text(
            'Requests',
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
            if(Requests.consultations.isEmpty){
              return const Padding(
                padding:  EdgeInsets.all(30.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'No Requests for now.',
                    style: TextStyle(
                      color: Color(0xFF199A8E),
                      fontSize: 20,
                    ),
                  ),
                ),
              );
            }
            else if (snapshot.hasError) {
              // If there's an error, handle it accordingly
              return Text('Error: ${snapshot.error}');
            }
            else  {
              // Access the products
              final requests = Requests.consultations;

              return ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final patient = requests[index];
                  return SuspendedRequest(patient: patient);
                },
              );
            } 
          }),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
