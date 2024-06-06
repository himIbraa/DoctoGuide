// ignore_for_file: prefer_const_constructors


import 'package:flutter/material.dart';
import 'package:doctoguide/widgets/BottomNavBar.dart';
import 'package:doctoguide/screens/history/ConsultedHistory.dart';
import 'package:doctoguide/screens/history/NonConsultedHistory.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedCategory = 'Consulted'; // Selected category by default
  bool _isConsultedPressed = true;
  late SharedPreferences _prefs;
  late String userId;

  Future<bool> checkIfLoggedIn() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.containsKey('user_id');
  }
  
Future<void> getIdAndLoadUserData() async { 
    try { 
      await getId(); 
    } catch (ex, st) { 
      print('Error: $ex $st'); 
    } 
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

  Future<void> fetchRequests() async {
    try {
      final isLoggedIn = await checkIfLoggedIn();
      if (isLoggedIn) {
        _prefs = await SharedPreferences.getInstance();
        userId = _prefs.getString('user_id') ?? '';
        print('_______________user id : $userId');
      }
    } catch (error) {
      print('Supabase error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    getIdAndLoadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable the default back button
        title: Padding(
          padding: const EdgeInsets.only(top: 12.0), // Add space on top
          child: Center(
            child: Text(
              'History',
              style: TextStyle(
                fontSize: 26,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // Remove appbar shadow
      ),

      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(5.00),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                        ),
                        color: _isConsultedPressed &&
                                _selectedCategory == 'Consulted'
                            ? const Color(0XFF199A8E)
                            : const Color(0xFFE8F3F1),
                      ),
                      child: _buildCategoryButton('Consulted', true),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(5.00),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                        color: !_isConsultedPressed &&
                                _selectedCategory == 'Non-Consulted'
                            ? const Color(0XFF199A8E)
                            : const Color(0xFFE8F3F1),
                      ),
                      child: _buildCategoryButton('Non-Consulted', false),
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedCategory == 'Consulted')
            
              ConsultedHistory(
                patientId: int.parse(userId),
              ),
            if (_selectedCategory == 'Non-Consulted')
              NonConsultedHistory(
                patientId: int.parse(userId),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
          selectedTab: '/history'), // Pass 'history' as selectedTab
    );
  }

  Widget _buildCategoryButton(String category, bool isConsulted) {
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedCategory = category;
          _isConsultedPressed = isConsulted;
        });
      },
      child: Text(
        category,
        style: TextStyle(
          fontSize: 16,
          color: _selectedCategory == category ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
