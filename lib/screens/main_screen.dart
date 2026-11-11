import 'package:flutter/material.dart';
import 'discover_screen.dart';
import 'browse_screen.dart';
import 'favorites_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'admin_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _profileVisit = 0;

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 4) _profileVisit++;
    });
  }

  List<Widget> get _screens => [
        DiscoverScreen(onProfileTap: () => _selectTab(4)),
        const BrowseScreen(),
        const FavoritesScreen(),
        const OrdersScreen(),
        ProfileScreen(
            key: ValueKey('profile-$_profileVisit'), onNavigate: _selectTab),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: _currentIndex == 4
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AdminScreen())),
              backgroundColor: const Color(0xFF0A5443),
              tooltip: 'Әкімші панелі',
              child:
                  const Icon(Icons.admin_panel_settings, color: Colors.white),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE9EEE9))),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 16,
                offset: const Offset(0, -4))
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(children: [
              _navItem(0, Icons.home_outlined, Icons.home_rounded, 'Басты бет'),
              _navItem(1, Icons.search_rounded, Icons.search_rounded, 'Іздеу'),
              _navItem(2, Icons.favorite_border_rounded, Icons.favorite_rounded,
                  'Таңдаулы'),
              _navItem(3, Icons.receipt_long_outlined,
                  Icons.receipt_long_rounded, 'Тапсырыс'),
              _navItem(4, Icons.person_outline_rounded, Icons.person_rounded,
                  'Профиль'),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final selected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _selectTab(index),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
                color: selected ? const Color(0xFFE7F2EC) : Colors.transparent,
                borderRadius: BorderRadius.circular(18)),
            child: Icon(selected ? activeIcon : icon,
                size: 22,
                color: selected
                    ? const Color(0xFF0A5443)
                    : const Color(0xFF8A958E)),
          ),
          const SizedBox(height: 3),
          Text(label,
              maxLines: 1,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? const Color(0xFF0A5443)
                      : const Color(0xFF8A958E))),
        ]),
      ),
    );
  }
}
