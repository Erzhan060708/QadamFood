import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigate;
  const ProfileScreen({super.key, this.onNavigate});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _green = Color(0xFF0A5443);
  static const _ink = Color(0xFF173B30);
  static const _muted = Color(0xFF68766E);

  bool _loading = true;
  bool _loggedIn = false;
  String _name = '';
  String _email = '';
  int _points = 0;
  int _orders = 0;
  double _moneySaved = 0;
  double _foodSaved = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final profile = await ApiService.getMe();
      List<dynamic> orders = [];
      try {
        orders = await ApiService.getOrders();
      } catch (_) {}
      var saved = 0.0;
      for (final order in orders) {
        final bag = order['bags'] as Map<String, dynamic>? ?? {};
        final original = (bag['original_price'] as num?)?.toDouble() ?? 0;
        final discounted = (bag['discounted_price'] as num?)?.toDouble() ?? 0;
        saved += (original - discounted).clamp(0, 999999).toDouble();
      }
      final email = (profile['email'] ?? '').toString();
      final fullName = (profile['full_name'] ?? '').toString().trim();
      if (!mounted) return;
      setState(() {
        _loggedIn = true;
        _email = email;
        _name = fullName.contains('@') || fullName == email.split('@').first
            ? ''
            : fullName;
        _points = (profile['points'] as num?)?.toInt() ?? 0;
        _orders = orders.length;
        _moneySaved = saved;
        _foodSaved = orders.length * .4;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loggedIn = false;
        _name = '';
        _email = '';
        _points = 0;
        _orders = 0;
        _moneySaved = 0;
        _foodSaved = 0;
        _loading = false;
      });
    }
  }

  Future<void> _signIn() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AuthScreen()));
    if (mounted) _loadProfile();
  }

  Future<void> _signOut() async {
    await ApiService.logout();
    if (!mounted) return;
    setState(() {
      _loggedIn = false;
      _name = '';
      _email = '';
      _points = 0;
      _orders = 0;
      _moneySaved = 0;
      _foodSaved = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: _green))
              : RefreshIndicator(
                  color: _green,
                  onRefresh: _loadProfile,
                  child: LayoutBuilder(builder: (_, constraints) {
                    final wide = constraints.maxWidth > 760;
                    return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Center(
                            child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 900),
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: wide ? 30 : 18,
                                        vertical: 18),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _titleBar(),
                                          const SizedBox(height: 20),
                                          _profileHero(),
                                          const SizedBox(height: 22),
                                          if (_loggedIn) ...[
                                            _impactStats(wide),
                                            const SizedBox(height: 26),
                                            const Text('Жеке бөлім',
                                                style: TextStyle(
                                                    color: _ink,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                            const SizedBox(height: 12),
                                            _menuTile(
                                                Icons.receipt_long_outlined,
                                                'Менің тапсырыстарым',
                                                'QR код пен алу уақытын қарау',
                                                () =>
                                                    widget.onNavigate?.call(3)),
                                            _menuTile(
                                                Icons.favorite_border_rounded,
                                                'Таңдаулылар',
                                                'Сақтап қойған ұсыныстарыңыз',
                                                () =>
                                                    widget.onNavigate?.call(2)),
                                            _menuTile(
                                                Icons.search_rounded,
                                                'Ұсыныстарды іздеу',
                                                'Бүгінгі пакеттерді шолу',
                                                () =>
                                                    widget.onNavigate?.call(1)),
                                            const SizedBox(height: 18),
                                            _ecoNote(),
                                            const SizedBox(height: 20),
                                            SizedBox(
                                                width: double.infinity,
                                                child: OutlinedButton.icon(
                                                    onPressed: _signOut,
                                                    icon: const Icon(
                                                        Icons.logout_rounded,
                                                        color:
                                                            Color(0xFFB34235)),
                                                    label: const Text(
                                                        'Аккаунттан шығу',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFFB34235),
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700)),
                                                    style: OutlinedButton.styleFrom(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                                vertical: 15),
                                                        side: const BorderSide(
                                                            color: Color(0xFFE4C9C5)),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
                                          ] else ...[
                                            _menuTile(
                                                Icons.receipt_long_outlined,
                                                'Тапсырыстар',
                                                'Кіру арқылы сатып алуыңызды сақтаңыз',
                                                _signIn),
                                            _menuTile(
                                                Icons.favorite_border_rounded,
                                                'Таңдаулылар',
                                                'Ұнаған пакеттеріңізді жоғалтпаңыз',
                                                _signIn),
                                            const SizedBox(height: 18),
                                            SizedBox(
                                                width: double.infinity,
                                                child: FilledButton(
                                                    onPressed: _signIn,
                                                    style: FilledButton.styleFrom(
                                                        backgroundColor: _green,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 16),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    14))),
                                                    child: const Text(
                                                        'Кіру немесе тіркелу',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)))),
                                          ],
                                          const SizedBox(height: 26),
                                          Row(children: [
                                            const Icon(Icons.eco_outlined,
                                                color: _green, size: 19),
                                            const SizedBox(width: 7),
                                            const Text('Qadam Food',
                                                style: TextStyle(
                                                    color: _ink,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const Spacer(),
                                            Text('Бір қадам — аз ысырап',
                                                style: TextStyle(
                                                    color: _muted,
                                                    fontSize: 11))
                                          ]),
                                          const SizedBox(height: 20),
                                        ])))));
                  }))),
    );
  }

  Widget _titleBar() => Row(children: [
        const Text('Профиль',
            style: TextStyle(
                color: _ink,
                fontSize: 27,
                fontWeight: FontWeight.w800,
                letterSpacing: -.6)),
        const Spacer(),
        if (_loggedIn)
          IconButton(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh_rounded, color: _green))
      ]);

  Widget _profileHero() => Container(
      padding: const EdgeInsets.all(22),
      decoration:
          BoxDecoration(color: _green, borderRadius: BorderRadius.circular(22)),
      child: Row(children: [
        Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(20)),
            child: Icon(_loggedIn ? Icons.person_rounded : Icons.eco_rounded,
                color: Colors.white, size: 32)),
        const SizedBox(width: 15),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              _loggedIn
                  ? (_name.isNotEmpty ? _name : 'Qadam мүшесі')
                  : 'Қош келдіңіз!',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(_loggedIn ? _email : 'Әр қадам тағамды сақтауға көмектеседі',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          if (_loggedIn) ...[
            const SizedBox(height: 11),
            Row(children: [
              const Icon(Icons.stars_rounded,
                  color: Color(0xFFFFB45A), size: 17),
              const SizedBox(width: 5),
              Text('$_points ұпай',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12))
            ])
          ]
        ])),
        const Icon(Icons.eco_rounded, size: 32, color: Color(0x66FFFFFF)),
      ]));

  Widget _impactStats(bool wide) => LayoutBuilder(builder: (_, box) {
        final values = [
          (_orders.toString(), 'тапсырыс', Icons.shopping_bag_outlined),
          (
            '${_foodSaved.toStringAsFixed(1)} кг',
            'сақталған тағам',
            Icons.eco_outlined
          ),
          (
            '${_moneySaved.toStringAsFixed(0)} ₸',
            'үнемделген ақша',
            Icons.savings_outlined
          )
        ];
        return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: values.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: box.maxWidth > 620 ? 3 : 1,
                childAspectRatio: box.maxWidth > 620 ? 1.6 : 3.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            itemBuilder: (_, i) {
              final item = values[i];
              return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE8EEE9)),
                      borderRadius: BorderRadius.circular(17)),
                  child: Row(children: [
                    Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                            color: const Color(0xFFEAF3ED),
                            borderRadius: BorderRadius.circular(13)),
                        child: Icon(item.$3, color: _green, size: 20)),
                    const SizedBox(width: 12),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.$1,
                              style: const TextStyle(
                                  color: _ink,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800)),
                          Text(item.$2,
                              style:
                                  const TextStyle(color: _muted, fontSize: 11))
                        ])
                  ]));
            });
      });

  Widget _menuTile(
          IconData icon, String title, String subtitle, VoidCallback onTap) =>
      Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE8EEE9)),
              borderRadius: BorderRadius.circular(16)),
          child: ListTile(
              onTap: onTap,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      color: const Color(0xFFEAF3ED),
                      borderRadius: BorderRadius.circular(13)),
                  child: Icon(icon, color: _green, size: 21)),
              title: Text(title,
                  style: const TextStyle(
                      color: _ink, fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(subtitle,
                  style: const TextStyle(color: _muted, fontSize: 11)),
              trailing:
                  const Icon(Icons.chevron_right_rounded, color: _muted)));

  Widget _ecoNote() => Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
          color: const Color(0xFFFFF5E8),
          borderRadius: BorderRadius.circular(16)),
      child: const Row(children: [
        Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFD97800)),
        SizedBox(width: 11),
        Expanded(
            child: Text(
                'Әр құтқарылған пакет — жақсы тағамның қоқысқа кетпеуіне қосқан үлесіңіз.',
                style: TextStyle(
                    color: Color(0xFF76552D), fontSize: 12, height: 1.45)))
      ]));
}
