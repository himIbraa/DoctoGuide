import 'package:flutter/material.dart';
import 'package:doctoguide/theme/theme.dart';
import 'package:doctoguide/screens/home/NearestDoctor.dart';

class CustomDialog extends StatefulWidget {
  final String specialistName;
  final double latitude;
  final double longitude;

  const CustomDialog({
    Key? key,
    required this.specialistName,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  bool isLoading = true;
  String analysisResult = '';

  @override
  void initState() {
    super.initState();
    // Simulate a delay to mimic AI analysis
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isLoading = false;
        analysisResult =
            'Our analysis suggests to visit the specialist...'; // Replace with actual analysis result
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: isLoading
          ? const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor), // Set color to primary color
                ),
                SizedBox(height: 16),
                Text(
                  'Analyzing your input...',
                  style: TextStyle(
                    color: AppColors.greyColor,
                  ),
                ), // Show analyzing message
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 48,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Our analysis suggests to visit',
                  style: TextStyle(
                    color: AppColors.greyColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.specialistName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the NearestDoctorPage screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NearestDoctorPage(
                          searchQuery: widget.specialistName,
                          latitude: widget.latitude,
                          longitude: widget.longitude,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      'Browse Doctor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
      actions: const <Widget>[
        // Keep the actions empty
      ],
    );
  }
}
