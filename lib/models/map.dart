import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:doctoguidedoctorapp/constants/endpoints.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/loginSignUp/login.dart';



class MapUtils {
  MapUtils();
  static void openMap(
    String latitude,
    String longitude,
  ) async {
    final Uri googleUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (!await launchUrl(googleUrl, mode: LaunchMode.externalApplication)) {
      throw 'Could not open the map.';
    }
  }
}

class CurrentLocation {
  CurrentLocation();

  static Future<Position> getCurrentLocation() async {
    try {
      // Check if the app has permission to access the device's location
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Request permission from the user
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Handle the case when the user denies permission
          print('User denied permissions to access the device\'s location.');
          return Future.error(
              'User denied permissions to access the device\'s location.');
        }
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Prompt the user to enable location services
        bool locationSettingsOpened = await Geolocator.openLocationSettings();
        if (!locationSettingsOpened) {
          // Handle the case when the user cancels opening location settings
          print('Failed to open location settings.');
          return Future.error('Failed to open location settings.');
        }
        // Wait for the user to enable location services and then try again
        // You can also use a stream to listen for changes in location service status
        await Future.delayed(Duration(seconds: 5)); // Wait for settings change
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          // Handle the case when the user still hasn't enabled location services
          print('Location services are still disabled.');
          return Future.error('Location services are still disabled.');
        }
      }
      // Get the current position
      Position position = await Geolocator.getCurrentPosition();
      return position;
    } catch (e) {
      // Handle any errors that occur while getting the current position
      print('Error getting current location: $e');
      return Future.error('Error getting current location: $e');
    }
  }
}

class UpdateLocation {
  UpdateLocation();

  static void updateLocalization(
      String _userId, double latitude, double longitude) async {
    final supabase = Supabase.instance.client;
    late SharedPreferences _prefs;
    late String _userId;
    final dio = Dio();
    try {
      _prefs = await SharedPreferences.getInstance();
      _userId = _prefs.getString('user_id') ?? '';

      print('User ID: $_userId');
      print('Before insert');

      

      final response = await dio.get(
        '$api_update_localization?id_doctor=$_userId&latitude=$latitude&longitude=$longitude',
      );

      print('After insert');

      Map<String, dynamic> retData = jsonDecode(response.data);

      // Check the response status from the server
      if (retData['status'] == 200) {
        // The item was successfully inserted into the server's database
        print('Item successfully inserted into the server.');
      } else {
        // Handle the case where the server returned an error
        print('Server returned an error: ${retData['message']}');
      }
    } catch (error) {
      // Handle unexpected errors
      print('Error during item insertion: $error');
      showToast('Unexpected error occurred');
    }
  }
}



class fetchPatientLocation{
  fetchPatientLocation();
  
static Future<Map<String, dynamic>> fetchPatient(String patientId) async {
  final supabase = Supabase.instance.client;
  try {
    final response = await supabase.from('patient')
        .select('latitude, longitude')
        .eq('id_patient', patientId)
        .single()
        .execute();

    if (response.data == null || response.data!.isEmpty) {
      throw Exception('Patient location not found for ID: $patientId');
    }

    // Access fetched data directly from the response
    final data = response.data;
    
    
    final double latitude = data['latitude'];
    final double longitude = data['longitude'];
    return {'latitude': latitude, 'longitude': longitude};
  } catch (e) {
    print('Error fetching patient location: $e');
    throw e;
  }
}



}
