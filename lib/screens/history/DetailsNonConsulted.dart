import 'package:flutter/material.dart';
import 'package:doctoguide/theme/theme.dart';
import 'package:doctoguide/widgets/BottomNavBar.dart'; // Import the BottomNavBar widget


class DetailsNonConsultedPage extends StatelessWidget {
  final String specialistType;
  final String symptom;
  final String date;
  final String time;

  const DetailsNonConsultedPage({super.key, 
    required this.specialistType,
    required this.symptom,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          specialistType,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                border: Border.all(
                  color: AppColors.primaryColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                symptom,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppColors.darkgreyColor,
                ),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.darkgreyColor,
                  ),
                ),
                const SizedBox(width: 20),
                const Icon(
                  Icons.access_time,
                  size: 20,
                  color: AppColors.darkgreyColor,
                ),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.darkgreyColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
bottomNavigationBar: const BottomNavBar(selectedTab: '/history'), // Pass 'history' as selectedTab

    );
  }
}
