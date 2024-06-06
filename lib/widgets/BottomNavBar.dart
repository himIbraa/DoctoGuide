import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final String? selectedTab;

  const BottomNavBar({Key? key, this.selectedTab}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = getCurrentIndex(widget.selectedTab);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60.0,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(2.0)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.9),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildNavItem(0, Icons.home, '/home'),
          buildNavItem(1, Icons.search, '/search'), 
          buildNavItem(2, Icons.history, '/history'),
          buildNavItem(3, Icons.person, '/profile'),
        ],
      ),
    );
  }

  Widget buildNavItem(int index, IconData icon, String route) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () async {
        setState(() {
          selectedIndex = index;
          Navigator.pushReplacementNamed(context, route);
        });
      },
      child: Container(
        child: buildIcon(icon, isSelected),
      ),
    );
  }

  Widget buildIcon(IconData icon, bool isSelected) {
    double iconSize = isSelected ? 50.0 : 40.0;

    if (icon == Icons.history && isSelected) {
      return Stack(
        children: [
          Icon(
            icon,
            color: const Color(0xFF199A8E),
            size: iconSize,
          ),
          const Positioned(
            top: 0,
            right: 0,
            child: SizedBox(
              width: 0.1, // Set the width to a very small value
              height: 0.1, // Set the height to a very small value
            ),
          ),
        ],
      );
    } else if (icon == Icons.history && !isSelected) {
      return Stack(
        children: [
          Icon(
            icon,
            color: const Color(0xFFA1A8B0),
            size: iconSize,
          ),
          const Positioned(
            top: 0,
            right: 0,
            child: SizedBox(
              width: 0.1, // Set the width to a very small value
              height: 0.1, // Set the height to a very small value
            ),
          ),
        ],
      );
    } else {
      return Icon(
        icon,
        color: isSelected ? const Color(0xFF199A8E) : const Color(0xFFA1A8B0),
        size: isSelected ? 42 : 35,
      );
    }
  }

  int getCurrentIndex(String? route) {
    switch (route) {
      case '/home':
        return 0;
      case '/search':
        return 1;
      case '/history':
        return 2;
      case '/profile':
        return 3;
      default:
        return 0;
    }
  }
}
