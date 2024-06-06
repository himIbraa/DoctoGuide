import 'package:flutter/material.dart';
import 'package:doctoguide/theme/theme.dart';

class CustomDialogND extends StatefulWidget {
  final String doctorName;

  const CustomDialogND({super.key, required this.doctorName});

  @override
  _CustomDialogStateND createState() => _CustomDialogStateND();
}

class _CustomDialogStateND extends State<CustomDialogND> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = false;
    });
   
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: isLoading
          ?  const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor), // Set color to primary color
                ),
                SizedBox(height: 16),
                Text('Trying to find the Nearest ',
                style: TextStyle(
                    color: AppColors.greyColor,
                    
                  ),), 
                  Text(' Specialist ...',
                style: TextStyle(
                    color: AppColors.greyColor,
                    
                  ),),// Show analyzing message
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
                Text(
                  widget.doctorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                                const SizedBox(height: 8),

                const Text(
                  'has accepted your request!',
                  style: TextStyle(
                    color: AppColors.greyColor,
                    fontSize: 16,
                  ),
                ),
                
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                      // Navigate to the NearestDoctorPage screen
                      
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
                      'See Location',
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
