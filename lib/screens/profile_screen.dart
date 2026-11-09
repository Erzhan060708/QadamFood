import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String _userName = 'Guest';
  int _points = 0;
  
  // Статистика (әзірге бос)
  double _kgSaved = 0;
  double _moneySaved = 0;
  int _bagsPurchased = 0;

  static const int _pointsPerLevel = 250;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService.getMe();
      List<dynamic> orders = [];
      try {
        orders = await ApiService.getOrders();
      } catch (_) {}
      double money = 0;
      for (final o in orders) {
        final bag = o['bags'] as Map<String, dynamic>? ?? {};
        final disc = (bag['discounted_price'] as num?)?.toDouble() ?? 0;
        final orig = (bag['original_price'] as num?)?.toDouble() ?? disc;
        money += (orig - disc).clamp(0, 999999);
      }
      if (!mounted) return;
      setState(() {
        _userName = profile['full_name'] ?? 'User';
        _points = profile['points'] ?? 0;
        _bagsPurchased = orders.length;
        _kgSaved = orders.length * 0.4;
        _moneySaved = money;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _userName = 'Guest';
        _isLoading = false;
      });
    }
  }

  int get _currentLevel => (_points ~/ _pointsPerLevel) + 1;
  int get _pointsIntoLevel => _points % _pointsPerLevel;
  double get _levelProgress => _pointsIntoLevel / _pointsPerLevel;
  int get _pointsToNextLevel => _pointsPerLevel - _pointsIntoLevel;
  double get _co2Prevented => _kgSaved * 2.5;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9F8F3),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F3),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          color: const Color(0xFF005C4B),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_userName == 'Guest')
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AuthScreen()),
                          );
                          _loadProfile();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A5443)),
                        child: const Text('Кіру / Тіркелу', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFF005C4B),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(_userName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_none)),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.help_outline)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF005C4B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('$_points',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _levelProgress.clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF005C4B)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${_pointsPerLevel}pts',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF005C4B), Color(0xFF007A63)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shield, size: 80, color: Color(0xFFFF7A00)),
                            SizedBox(height: 12),
                            Text('Food Saver',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white24),
                              child: const Icon(Icons.person_outline,
                                  color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 8),
                            const Text('Food Saver',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Text('Level $_currentLevel',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _statCard('${_kgSaved.toStringAsFixed(1)}kg', 'Food Rescued'),
                      _statCard('${_co2Prevented.toStringAsFixed(1)}kg', 'CO2e Prevented'),
                      _statCard('₸${_moneySaved.toStringAsFixed(2)}', 'Money Saved'),
                      _statCard('$_bagsPurchased', 'Bags Purchased'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF005C4B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.card_giftcard, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Refer Friends & Earn ₸2.49',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            SizedBox(height: 4),
                            Text('50 Hero Points per referral',
                                style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF005C4B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _bagsPurchased < 10
                              ? 'You are close to your next level. Rescue $_pointsToNextLevel more points and receive a ₸0.99 Voucher on any bag.'
                              : '🎉 You unlocked a ₸0.99 voucher!',
                          style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _menuButton('Settings'),
                      _menuButton('Complaints'),
                      _menuButton('Help'),
                      _menuButton('Terms'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ApiService.logout();
                        if (!mounted) return;
                        setState(() {
                          _userName = 'Guest';
                          _points = 0;
                          _bagsPurchased = 0;
                          _kgSaved = 0;
                          _moneySaved = 0;
                        });
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AuthScreen()),
                        );
                        _loadProfile();
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCEFCB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF005C4B))),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _menuButton(String label) {
    return Container(
      width: (MediaQuery.of(context).size.width - 44) / 2,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFCEFCB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF005C4B), fontSize: 15)),
      ),
    );
  }
}