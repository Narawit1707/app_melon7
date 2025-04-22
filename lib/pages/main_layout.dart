import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pj_app/pages/home_page.dart';
// import 'package:pj_app/pages/notification_page.dart';
import 'package:pj_app/pages/search_page.dart';
import 'package:pj_app/pages/profile_page.dart';
import 'package:pj_app/pages/select_images_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    const SearchPage(),
    const SelectImagesPage(),
    // const NotificationPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color.fromARGB(255, 214, 214, 214), width: 1),
            ),
          ),
          child: GNav(
            backgroundColor: Colors.white,
            color: const Color.fromARGB(255, 0, 0, 0),
            activeColor: const Color.fromARGB(255, 0, 0, 0),
            tabBackgroundColor: Colors.lime,
            gap: 5, // ลดช่องว่างระหว่างไอคอนและข้อความ
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), // ลด padding
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.search,
                text: 'Search',
              ),
              GButton(
                icon: Icons.post_add,
                text: 'Post',
              ),
              // GButton(
              //   icon: Icons.notifications,
              //   text: 'Notification',
              // ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}