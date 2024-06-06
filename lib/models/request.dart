import 'dart:convert';

import 'package:doctoguidedoctorapp/models/patient.dart';
import 'package:doctoguidedoctorapp/constants/endpoints.dart';
import 'package:doctoguidedoctorapp/models/patient.dart';
import 'package:doctoguidedoctorapp/screens/loginSignUp/login.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

final supabase = Supabase.instance.client;

class Request extends ChangeNotifier {
  final List<Patient> _consultations = [];
  late SharedPreferences _prefs;
  List<Patient> get consultations => _consultations;
  bool _hasSuspendedConsultations = false; // Track suspended consultations
  bool get hasSuspendedConsultations => _hasSuspendedConsultations; // Getter
  String? lastImage =
      "https://jzredydxgjflzlgkamhn.supabase.co/storage/v1/object/sign/item/item/2024-01-26T21:31:17.285704.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJpdGVtL2l0ZW0vMjAyNC0wMS0yNlQyMTozMToxNy4yODU3MDQucG5nIiwiaWF0IjoxNzA2MzAxMDgyLCJleHAiOjIwMjE2NjEwODJ9.Hqjnc2K1p73rVlYD1kqUr39t65g4c5fk9sGp5AzHAek";
  String? defaultProfilePic =
      "https://jzredydxgjflzlgkamhn.supabase.co/storage/v1/object/sign/item/item/2024-01-26T21:30:55.587640.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJpdGVtL2l0ZW0vMjAyNC0wMS0yNlQyMTozMDo1NS41ODc2NDAuanBnIiwiaWF0IjoxNzA2MzAxMDU5LCJleHAiOjIwMjE2NjEwNTl9.EQ8qCe_8uC6EGsNxzptM88Cy8xCKtzg6d0VIeO-aEj4";

  Future<void> fetchRequests(String status) async {
    try {
      final isLoggedIn = await checkIfLoggedIn();
      if (isLoggedIn) {
        _prefs = await SharedPreferences.getInstance();
        String userId = _prefs.getString('user_id') ?? '';

        var response = await dio
            .get('$api_endpoint_fetch_requests?id_user=$userId&status=$status');

        List<dynamic> dataLines = jsonDecode(response.data);
      

        // Clear the existing list before adding new liked items
        _consultations.clear();

        for (var row_d in dataLines) {
          Map row = Map.of(row_d);

        

          String idPatient = row['pid']?.toString() ?? 'N/A';
          String consultationStatus = row['status']?.toString() ?? 'N/A';
          String name = row['patient']?['name']?.toString() ?? 'N/A';
          String phoneNumber = row['patient']?['phone']?.toString() ?? 'N/A';
          String picture = row['patient']?['picture']?.toString() ?? 'N/A';
          String gender = row['patient']?['gender']?.toString() ?? 'N/A';
          String email = row['patient']?['email']?.toString() ?? 'N/A';
          String birthDate = row['patient']?['birthDate']?.toString() ?? 'N/A';
          String symptoms =
              row['searchHistory']?['symptoms']?.toString() ?? ' ';
          String consultationReport = row['report']?.toString() ?? 'N/A';
          DateTime? completionTime = row['completiontime'] != null
              ? DateTime.tryParse(row['completiontime'])
              : null;
          String consultationType =
              row['consultationPrice']?['type']?.toString() ?? 'N/A';
          String consultationPrice =
              row['consultationPrice']?['price']?.toString() ?? 'N/A';

          _consultations.add(Patient(
            id_patient: idPatient,
            consultationStatus: consultationStatus,
            name: name,
            phoneNumber: phoneNumber,
            picture: picture,
            gender: gender,
            email: email,
            birthDate: birthDate,
            symptoms: symptoms,
            consultationReport: consultationReport,
            completionTime: completionTime,
            consultationType: consultationType,
            consultationPrice: consultationPrice,
          ));
        }
        // Sort the consultations based on completionTime
        _consultations.sort((a, b) {
          if (a.completionTime == null && b.completionTime == null) {
            return 0; // Both are null, consider them equal
          } else if (a.completionTime == null) {
            return 1; // a is null, b is not null, so a comes after b
          } else if (b.completionTime == null) {
            return -1; // b is null, a is not null, so a comes before b
          } else {
            return b.completionTime!.compareTo(
                a.completionTime!); // Both are not null, compare normally
          }
        });

        // Check for suspended consultations and update the state
        _hasSuspendedConsultations = _consultations.any(
            (consultation) => consultation.consultationStatus == 'suspended');
        updateSuspendedConsultations(_hasSuspendedConsultations);
        // Notify listeners after adding liked items
        notifyListeners();
      } else {
        _consultations.clear();
      }
    } catch (error) {
      print('Supabase error: ${error}');
      throw Exception('Failed to $status requests');
    }
  }

  void updateSuspendedConsultations(bool hasSuspendedConsultations) {
    _hasSuspendedConsultations = hasSuspendedConsultations;
    notifyListeners(); // Notify listeners whenever there is a change
  }

  Future<bool> checkIfLoggedIn() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.containsKey('user_id');
  }

  Future<void> updateToAccepted(Patient patient) async {
    try {
      _prefs = await SharedPreferences.getInstance();
      String userId = _prefs.getString('user_id') ?? '';
      var response = await dio.get(
          '$api_endpoint_update_to_accepted?doctor_id=$userId&patient_id=${patient.id_patient}');
      Map retData = jsonDecode(response.toString());

      if (retData['status'] == 200) {
        // Remove the item from the liked list in the local state
        _consultations.remove(patient);
        // Notify listeners after removing the item
        notifyListeners();
      } else {
        print('Server returned an error: ${response.data}');
      }
    } catch (error) {
      print('Error during item removal from liked list: $error');
      throw Exception('Failed to remove item from liked list');
    }
  }

  Future<void> updateToCancelled(Patient patient) async {
    try {
      _prefs = await SharedPreferences.getInstance();
      String userId = _prefs.getString('user_id') ?? '';
      var response = await dio.get(
          '$api_endpoint_update_to_cancelled?doctor_id=$userId&patient_id=${patient.id_patient}');
      Map retData = jsonDecode(response.toString());

      if (retData['status'] == 200) {
        // Remove the item from the liked list in the local state
        _consultations.remove(patient);
        // Notify listeners after removing the item
        notifyListeners();
      } else {
        print('Server returned an error: ${response.data}');
      }
    } catch (error) {
      print('Error during item removal from liked list: $error');
      throw Exception('Failed to remove item from liked list');
    }
  }

  Future<void> updateToRejected(Patient patient) async {
    try {
      _prefs = await SharedPreferences.getInstance();
      String userId = _prefs.getString('user_id') ?? '';
      var response = await dio.get(
          '$api_endpoint_update_to_rejected?doctor_id=$userId&patient_id=${patient.id_patient}');
      Map retData = jsonDecode(response.toString());

      if (retData['status'] == 200) {
        // Remove the item from the liked list in the local state
        _consultations.remove(patient);
        // Notify listeners after removing the item
        notifyListeners();
      } else {
        //print('Server returned an error: ${response.data}');
      }
    } catch (error) {
      print('Error during item removal from liked list: $error');
      throw Exception('Failed to remove item from liked list');
    }
  }

  // Future<void> updateToCompleted(Patient patient) async {

  //   try {
  //     _prefs = await SharedPreferences.getInstance();
  //     String userId = _prefs.getString('user_id') ?? '';
  //     var response = await dio.get(
  //         '$api_endpoint_update_to_completed?doctor_id=$userId&patient_id=${patient.id_patient}');
  //     Map retData = jsonDecode(response.toString());

  //     if (retData['status'] == 200) {
  //       // Remove the item from the liked list in the local state
  //       _consultations.remove(patient);
  //       // Notify listeners after removing the item
  //       notifyListeners();
  //     } else {
  //       print('Server returned an error: ${response.data}');
  //     }
  //   } catch (error) {
  //     print('Error during item removal from liked list: $error');
  //     throw Exception('Failed to remove item from liked list');
  //   }
  // }

  Future<void> addConsultation(Patient patient, String report,
      DateTime completionTime, int selectedConsultation) async {
    try {
      _prefs = await SharedPreferences.getInstance();
      String userId = _prefs.getString('user_id') ?? '';
      var response = await dio.get(
          '$api_endpoint_add_consultation?doctor_id=$userId&patient_id=${patient.id_patient}&report=$report&completionTime=$completionTime'
          '&selectedConsultation=$selectedConsultation');
      Map retData = jsonDecode(response.toString());

      if (retData['status'] == 200) {
        //print(response.data);
        // Notify listeners after removing the item
        notifyListeners();
      } else {
        print('Server returned an error: ${response.data}');
      }
    } catch (error) {
      print('Error during item removal from liked list: $error');
      throw Exception('Failed to remove item from liked list');
    }
  }
}
