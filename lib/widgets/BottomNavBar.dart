import 'package:doctoguidedoctorapp/models/request.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class BottomNavBar extends StatefulWidget {
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int selectedIndex;

  @override
  Widget build(BuildContext context) {
    selectedIndex =
        getCurrentIndex(ModalRoute.of(context)?.settings.name ?? '/home');

   // Listen to changes in hasSuspendedConsultations
    bool hasSuspendedConsultations =
        Provider.of<Request>(context).hasSuspendedConsultations;

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 90.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.9),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildNavItem(0, Icons.home, '/home', hasSuspendedConsultations),
          buildNavItem(1, Icons.mail_outline, '/request',
              hasSuspendedConsultations),
          buildNavItem(2, Icons.mark_email_read_outlined, '/New Consultation', hasSuspendedConsultations),
          buildNavItem(3, Icons.person, '/profile', hasSuspendedConsultations),
        ],
      ),
    );
  }

  Widget buildNavItem(
      int index, IconData icon, String route, bool hasSuspendedConsultations) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () async {
        // Navigate to the corresponding route for all indices
        setState(() {
          selectedIndex = index;
          Navigator.pushReplacementNamed(context, route);
        });
      },
      child: Container(
        child: buildIcon(index, icon, isSelected, hasSuspendedConsultations),
      ),
    );
  }

  Widget buildIcon(int index, IconData icon, bool isSelected,
      bool hasSuspendedConsultations) {
    double iconSize = isSelected ? 50.0 : 40.0;

    if (icon == Icons.mail_outline) {
      return Stack(
        children: [
          Icon(
            icon,
            color: isSelected ? Color(0xFF199A8E) : const Color(0xFFA1A8B0),
            size: iconSize,
          ),
          if (hasSuspendedConsultations)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: iconSize * 0.4,
                height: iconSize * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      );
    } else if (icon is IconData ) {
      return Icon(
        icon,
        color: isSelected ? Color(0xFF199A8E) : const Color(0xFFA1A8B0),
        size: isSelected ? 50 : 40,
      );
    } else {
      return Container();
    }
  }


  int getCurrentIndex(String? route) {
    switch (route) {
      case '/home':
        return 0;
      case '/request':
        return 1;
      case '/New Consultation':
        return 2;
      case '/profile':
        return 3;
      default:
        return 0;
    }
  }
}
