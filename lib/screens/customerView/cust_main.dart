import 'package:artsphere/screens/customerView/custProfileScreen.dart';
import 'package:artsphere/screens/customerView/orderHistoryScreen.dart';
import 'package:artsphere/screens/customerView/custHome.dart';
import 'package:artsphere/screens/customerView/custReel.dart';
import 'package:flutter/material.dart';

class CustomerMain extends StatefulWidget {
  @override
  _CustomerMainState createState() => _CustomerMainState();
}

class _CustomerMainState extends State<CustomerMain> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [
    CustomerHome(),
    CustomerReelsPage(),
    OrderHistoryScreen(),
    CustomerProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: _buildFancyNavBar(context),
    );
  }

  Widget _buildFancyNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.home_outlined, Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.video_library_outlined, Icons.video_library),
              label: "Videos",
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.shopping_bag_outlined, Icons.shopping_bag),
              label: "Orders",
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.person_outline, Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData outlineIcon, IconData filledIcon) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: _selectedIndex == _pages.indexOf(_pages[_selectedIndex])
          ? Icon(filledIcon, key: ValueKey(filledIcon))
          : Icon(outlineIcon, key: ValueKey(outlineIcon)),
    );
  }
}