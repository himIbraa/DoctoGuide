import 'package:doctoguidedoctorapp/models/request.dart';
import 'package:doctoguidedoctorapp/widgets/BottomNavBar.dart';
import 'package:doctoguidedoctorapp/widgets/buildCancelledConsultations.dart';
import 'package:doctoguidedoctorapp/widgets/buildCompletedConsultations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConsultationPage extends StatefulWidget {
  @override
  _ConsultationPageState createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  String _selectedCategory = 'completed'; // Selected category by default
  bool _isCompletedPressed = true;

  @override
  Widget build(BuildContext context) {
    final Requests = Provider.of<Request>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0.0,
        title: Transform(
          // Translate title to the left
          transform: Matrix4.translationValues(30, 12.0, 0.0),
          child: const Text(
            'Consultations',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // Remove appbar shadow
      ),
      backgroundColor: Colors.white,
      body: Expanded(
        child: FutureBuilder<void>(
          future: Requests.fetchRequests(_selectedCategory),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // If there's an error, handle it accordingly
              return Text('Error: ${snapshot.error}');
            } else {
              final requests = Requests.consultations;
              return Padding(
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
                                color: _isCompletedPressed &&
                                        _selectedCategory == 'completed'
                                    ? Color(0XFF199A8E)
                                    : Color(0xFFE8F3F1),
                              ),
                              child: _buildCategoryButton('completed', true),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(5.00),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0),
                                ),
                                color: !_isCompletedPressed &&
                                        _selectedCategory == 'cancelled'
                                    ? Color(0XFF199A8E)
                                    : Color(0xFFE8F3F1),
                              ),
                              child: _buildCategoryButton('cancelled', false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      margin: const EdgeInsets.only(top: 20, bottom: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F3F1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE8F3F1),
                          width: 2.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: Color(0xFF199A8E),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                print("Search Query: $value");
                                //_updateSearchResults(value);
                              },
                              decoration: const InputDecoration(
                                hintText: 'Search patient, requests...',
                                hintStyle: TextStyle(
                                  color: Color(0xFF199A8E),
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
                    if (_selectedCategory == 'completed')
                      Expanded(
                        child: ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final patient = requests[index];
                            return buildCompletedConsultations(patient: patient);
                          },
                        ),
                      ),
                    if (_selectedCategory == 'cancelled')
                      Expanded(
                        child: ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final patient = requests[index];
                            return buildCancelledConsultations(patient: patient);
                          },
                        ),
                      ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  Widget _buildCategoryButton(String category, bool isCompleted) {
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedCategory = category;
          _isCompletedPressed = isCompleted;
        });
      },
      child: Text(
        category,
        style: TextStyle(
          fontSize: 18,
          color: _selectedCategory == category ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
