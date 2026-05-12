import 'package:flutter/material.dart';

import '../widgets/floating_nav_bar.dart';
import 'consult_screen.dart';
import 'home_screen.dart';
import 'medicine_screen.dart';
import 'profile_screen.dart';

/// Top-level shell: hosts the four main tabs and the floating bottom nav.
/// State is kept across tab switches via [IndexedStack].
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const List<Widget> _tabs = <Widget>[
    HomeScreen(),
    MedicineScreen(),
    ConsultScreen(),
    ProfileScreen(),
  ];

  static const List<NavBarItem> _navItems = <NavBarItem>[
    NavBarItem(icon: Icons.home_rounded, label: 'Home'),
    NavBarItem(icon: Icons.medical_services_rounded, label: 'Medicine'),
    NavBarItem(icon: Icons.chat_bubble_rounded, label: 'Consult'),
    NavBarItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  static const List<String> _titles = <String>[
    'TBXpert',
    'Medicine',
    'Consult',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_index],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade50,
        foregroundColor: Color(0xFF315660),
        elevation: 0,
        centerTitle: true,
      ),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: FloatingNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: _navItems,
      ),
    );
  }
}
