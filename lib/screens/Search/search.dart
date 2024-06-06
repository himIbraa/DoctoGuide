import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:doctoguide/theme/theme.dart';
import 'package:doctoguide/widgets/BottomNavBar.dart';
import 'package:doctoguide/screens/home/NearestDoctor.dart';
import 'package:doctoguide/screens/home/map.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  late double latitude;
  late double longitude;
  final supabase = Supabase.instance.client;
  late SharedPreferences _prefs;
  late String _userId;
  final dio = Dio();
  final int locationExpirationMinutes = 30;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      setState(() {
        _userId = _prefs.getString('user_id') ?? '';
        latitude = _prefs.getDouble('latitude') ?? 0.0;
        longitude = _prefs.getDouble('longitude') ?? 0.0;
      });

      if (_isLocationExpired()) {
        await _getCurrentLocation();
      }
      print('Loaded user ID: $_userId');
    } catch (ex, st) {
      print('$ex $st');
    }
  }

  bool _isLocationExpired() {
    final int? timestamp = _prefs.getInt('location_timestamp');
    if (timestamp == null) {
      return true;
    }
    final DateTime savedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateTime currentTime = DateTime.now();
    return currentTime.difference(savedTime).inMinutes > locationExpirationMinutes;
  }

  Future<void> _getCurrentLocation() async {
    Fluttertoast.showToast(
      msg: "We are getting your location, please wait for a while...",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });

      await _prefs.setDouble('latitude', latitude);
      await _prefs.setDouble('longitude', longitude);
      await _prefs.setInt('location_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  Image.asset(
                    'lib/assets/images/logosearch.png',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.greyColor,
                          width: 0.7,
                        ),
                      ),
                      child: TextField(
                        controller: searchController,
                        cursorColor: AppColors.primaryColor,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Browse Nearest Specialist...',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: AppColors.greyColor,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search, color: AppColors.primaryColor),
                            onPressed: () async {
                              if (_isLocationExpired()) {
                                await _getCurrentLocation();
                              }
                              UpdateLocation.updateLocalization(_userId, latitude, longitude);
                              handleSearch(context);
                            },
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 16.0,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: AppColors.primaryColor,
                              width: 0.7,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Find Specialist',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < specialtyList.length; i += 2)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          buildSpecialtyItem(specialtyList[i]),
                          SizedBox(width: 8),
                          if (i + 1 < specialtyList.length)
                            buildSpecialtyItem(specialtyList[i + 1]),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedTab: '/search'),
    );
  }

  Widget buildSpecialtyItem(Specialty specialty) {
    return InkWell(
      onTap: () => handleSpecialtyTap(context, specialty.name),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.primaryColor,
            width: 1,
          ),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              specialty.icon,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              specialty.name,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleSpecialtyTap(BuildContext context, String specialty) async {
    if (_isLocationExpired()) {
      await _getCurrentLocation();
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NearestDoctorPage(
          searchQuery: specialty,
          latitude: latitude,
          longitude: longitude,
        ),
      ),
    );
  }

  void handleSearch(BuildContext context) async {
    String specialty = searchController.text.trim();
    if (_isLocationExpired()) {
      await _getCurrentLocation();
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NearestDoctorPage(
          searchQuery: specialty,
          latitude: latitude,
          longitude: longitude,
        ),
      ),
    );
  }
}

class Specialty {
  final IconData icon;
  final String name;

  Specialty({required this.icon, required this.name});
}

List<Specialty> specialtyList = [
  Specialty(icon: Icons.headset, name: 'Generalist'),
  Specialty(icon: Icons.baby_changing_station, name: 'Pediatrics'),
  Specialty(icon: Icons.local_hospital, name: 'Allergist'),
  Specialty(icon: Icons.local_hospital, name: 'otolaryngologist'),
  Specialty(icon: Icons.local_hospital, name: 'Orthopedics'),



];
