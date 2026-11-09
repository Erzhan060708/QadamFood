import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bag_model.dart';
import '../widgets/bag_card.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import 'bag_detail_screen.dart';
import 'auth_screen.dart';
import 'admin_screen.dart';
import 'profile_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<Bag> _bags = [];
  List<dynamic> _stores = [];
  List<dynamic> _announcements = [];
  Map<String, dynamic> _stats = {};
  Set<String> _favIds = {};
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String _userEmail = '';
  String _userName = '';
  String _query = '';
  String _category = 'Барлығы';
  final _dealsKey = GlobalKey();

  static const _categories = ['Барлығы', 'Кафе', 'Кофехана', 'Наубайхана', 'Мейрамхана', 'Асхана'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
      _load();
    });
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      setState(() => _isLoggedIn = true);
      try {
        final profile = await ApiService.getMe();
        if (!mounted) return;
        setState(() {
          _userEmail = profile['email'] ?? 'U';
          _userName = profile['full_name'] ?? '';
        });
      } catch (_) {}
    } else if (mounted) {
      setState(() => _isLoggedIn = false);
    }
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        ApiService.getBags(),
        ApiService.getStores(),
        ApiService.getStats(),
        FavoritesService.getIds(),
        ApiService.getAllAnnouncements(),
      ]);
      if (!mounted) return;
      setState(() {
        _bags = (results[0] as List).map((j) => Bag.fromJson(j)).toList();
        _stores = results[1] as List;
        _stats = results[2] as Map<String, dynamic>;
        _favIds = results[3] as Set<String>;
        _announcements = results[4] as List;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Discover error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<Bag> get _filtered {
    return _bags.where((b) {
      final hay = '${b.title} ${b.storeName} ${b.storeCategory}'.toLowerCase();
      final matchesQ = _query.isEmpty || hay.contains(_query.toLowerCase());
      final matchesC = _category == 'Барлығы' || b.storeCategory == _category;
      return matchesQ && matchesC;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _checkAuth();
            await _load();
          },
          color: const Color(0xFF0A5443),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildGreeting(),
                _buildHero(),
                _buildSearch(),
                _buildCategories(),
                if (_stores.isNotEmpty) _buildStores(),
                if (_announcements.isNotEmpty) _buildAnnouncements(),
                _buildSectionTitle("Бүгінгі сюрприз-пакеттер", '${_filtered.length}', key: _dealsKey),
                _buildBagsList(),
                const SizedBox(height: 16),
                _buildHowItWorks(),
                const SizedBox(height: 24),
                _buildImpactSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      height: 245,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: const Color(0xFF0A5443), borderRadius: BorderRadius.circular(28)),
      child: Stack(children: [
        Positioned.fill(child: Image.network(
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=1200&auto=format&fit=crop&q=85',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        )),
        Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xEE063D31), Color(0x99063D31), Color(0x22063D31)])))),
        Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFF8A00), borderRadius: BorderRadius.circular(20)), child: const Text('АЛМАТЫ · БҮГІН', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: .8))),
          const SizedBox(height: 12),
          const Text('Дәмдісін ал.\nЫсырапты азайт.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 27, height: 1.08)),
          const SizedBox(height: 8),
          const Text('Күн соңындағы сүйікті тағамдар —\nтиімді бағамен.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.35)),
          const SizedBox(height: 12),
          InkWell(onTap: () => Scrollable.ensureVisible(_dealsKey.currentContext!, duration: const Duration(milliseconds: 450)), borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('Ұсыныстарды көру', style: TextStyle(color: Color(0xFF0A5443), fontWeight: FontWeight.bold, fontSize: 12)), SizedBox(width: 6), Icon(Icons.arrow_downward_rounded, size: 15, color: Color(0xFF0A5443))]))),
        ])),
        Positioned(right: -18, top: -16, child: Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 20)))),
      ]),
    );
  }

  Widget _buildHowItWorks() {
    final items = [(Icons.storefront_rounded, 'Орынды таңда'), (Icons.shopping_bag_rounded, 'Пакетті бронда'), (Icons.qr_code_2_rounded, 'QR көрсетіп ал')];
    return Container(margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Қалай жұмыс істейді?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0A2E26))), const SizedBox(height: 18),
      Row(children: [for (var i = 0; i < items.length; i++) Expanded(child: Row(children: [Expanded(child: Column(children: [CircleAvatar(radius: 21, backgroundColor: const Color(0xFFE9F3ED), child: Icon(items[i].$1, color: const Color(0xFF0A5443), size: 20)), const SizedBox(height: 8), Text(items[i].$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))])), if (i < items.length - 1) const Padding(padding: EdgeInsets.only(bottom: 22), child: Icon(Icons.chevron_right_rounded, color: Color(0xFFFF8A00)))]))]),
    ]));
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              children: [
                Icon(Icons.location_on_rounded, color: Color(0xFFFF8A00), size: 16),
                SizedBox(width: 6),
                Text('Алматы, KZ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2E26))),
              ],
            ),
          ),
          const Spacer(),
          _iconButton(
            icon: Icons.admin_panel_settings,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen())),
          ),
          const SizedBox(width: 8),
          _iconButton(
            icon: Icons.notifications_none_rounded,
            onTap: _showNotifications,
            badge: true,
          ),
          const SizedBox(width: 8),
          if (!_isLoggedIn)
            GestureDetector(
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
                _checkAuth();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFF0A5443), borderRadius: BorderRadius.circular(24)),
                child: const Text('Кіру', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            )
          else
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0A5443), Color(0xFF1F7A4D)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    (_userName.isNotEmpty ? _userName : _userEmail).isNotEmpty
                        ? (_userName.isNotEmpty ? _userName : _userEmail)[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Хабарламалар', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _notif('Coffee Boom жаңа пакет қосты', '18:00–21:00 аралығында алып кетіңіз'),
            _notif('Сіздің ұпайыңыз өсті', 'Әр сатып алу +50 ұпай береді'),
            _notif('Gagarin Bakery', 'Студенттік нан қорабы 490₸'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _notif(String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(backgroundColor: Color(0xFF0A5443), child: Icon(Icons.eco, color: Colors.white, size: 18)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onTap, bool badge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, size: 20, color: const Color(0xFF0A5443)),
          ),
          if (badge)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A00),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    final name = _userName.isNotEmpty ? _userName.split(' ').first : '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name.isEmpty ? 'Қайырлы күн! ☀️' : 'Сәлем, $name! ☀️',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0A2E26), height: 1.2),
          ),
          const SizedBox(height: 6),
          const Text('Тамақты құтқар — қадам жаса', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: TextField(
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: 'Кафе немесе пакет іздеу...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF0A5443)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = _categories[i];
          final selected = c == _category;
          return ChoiceChip(
            label: Text(c),
            selected: selected,
            onSelected: (_) => setState(() => _category = c),
            selectedColor: const Color(0xFF0A5443),
            labelStyle: TextStyle(color: selected ? Colors.white : const Color(0xFF0A2E26), fontWeight: FontWeight.w600),
            backgroundColor: Colors.white,
          );
        },
      ),
    );
  }

  Widget _buildStores() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text('Серіктес кафелер', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0A2E26))),
        ),
        SizedBox(
          height: 108,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _stores.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final s = _stores[i] as Map<String, dynamic>;
              return Container(
                width: 88,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 48,
                        width: 72,
                        child: (s['image_url'] != null)
                            ? Image.network(s['image_url'], fit: BoxFit.cover, errorBuilder: (_, __, ___) => _storeLetter(s['name']))
                            : _storeLetter(s['name']),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s['name'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    Text('⭐ ${s['rating'] ?? ''}', style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _storeLetter(dynamic name) {
    return Container(
      color: const Color(0xFF0A5443),
      child: Center(child: Text((name ?? '?').toString()[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildAnnouncements() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(padding: EdgeInsets.fromLTRB(20, 18, 20, 10), child: Text('Кафелерден жаңалық', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0A2E26)))),
      SizedBox(height: 130, child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20), scrollDirection: Axis.horizontal,
        itemCount: _announcements.length, separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) { final item = _announcements[i] as Map<String, dynamic>; return Container(width: 250, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFFE9F3ED), borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item['store_name'] ?? 'Qadam Food', style: const TextStyle(color: Color(0xFF0A5443), fontSize: 11, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(item['title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Expanded(child: Text(item['body'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFF5D6E66))))])); },
      )),
    ]);
  }

  Widget _buildSectionTitle(String title, String action, {Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0A2E26))),
          Text(action, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0A5443))),
        ],
      ),
    );
  }

  Widget _buildBagsList() {
    if (_isLoading) {
      return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()));
    }
    final bags = _filtered;
    if (bags.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Column(
          children: [
            Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('Пакет табылмады', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: bags.length,
      itemBuilder: (context, i) {
        final bag = bags[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: BagCard(
            bag: bag,
            tag: i == 0 ? 'Selling Fast' : (i == 1 ? 'Popular' : null),
            isFavorite: _favIds.contains(bag.id),
            onFavoriteToggle: () async {
              final next = await FavoritesService.toggle(bag.id);
              setState(() {
                if (next) {
                  _favIds.add(bag.id);
                } else {
                  _favIds.remove(bag.id);
                }
              });
            },
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BagDetailScreen(bag: bag)),
            ).then((_) => _load()),
          ),
        );
      },
    );
  }

  Widget _buildImpactSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A5443), Color(0xFF1F7A4D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt_rounded, color: Color(0xFFFF8A00)),
              SizedBox(width: 10),
              Text('Qadam Food Impact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _impactItem('${_stats['meals_saved'] ?? 0}', 'тағам сақталды', Icons.restaurant),
              _impactItem('${_stats['kg_saved'] ?? 0} kg', 'ысырап азайды', Icons.eco),
              _impactItem('${_stats['co2_prevented'] ?? 0} kg', 'CO₂', Icons.cloud_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _impactItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 18),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 10.5)),
      ],
    );
  }
}
