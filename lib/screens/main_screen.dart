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

  final List<Widget> _screens = const [
    DiscoverScreen(),
    BrowseScreen(),
    FavoritesScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // ═══════════════════════════════════════════════
      //  ADMIN BUTTON — тек Profile табында көрінеді
      // ═══════════════════════════════════════════════
      floatingActionButton: _currentIndex == 4
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminScreen(),
                  ),
                );
              },
              backgroundColor: const Color(0xFF0A5443),
              tooltip: 'Әкімші панелі',
              child: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 26,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.explore_outlined, Icons.explore, 'Discover'),
                _navItem(1, Icons.search_rounded, Icons.search_rounded, 'Browse'),
                _navItem(2, Icons.bookmark_border_rounded,
                    Icons.bookmark_rounded, 'Favorites'),
                _navItem(3, Icons.receipt_long_outlined,
                    Icons.receipt_long_rounded, 'Orders'),
                _navItem(4, Icons.person_outline_rounded,
                    Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 18 : 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0A5443).withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 24,
                color: isSelected
                    ? const Color(0xFF0A5443)
                    : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF0A5443)
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}