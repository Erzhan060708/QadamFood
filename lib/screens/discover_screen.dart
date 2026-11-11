import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bag_model.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../widgets/bag_card.dart';
import 'auth_screen.dart';
import 'bag_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const DiscoverScreen({super.key, this.onProfileTap});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  static const _green = Color(0xFF0A5443);
  static const _ink = Color(0xFF173B30);
  static const _muted = Color(0xFF68766E);
  static const _categories = [
    'Барлығы',
    'Кафе',
    'Кофехана',
    'Наубайхана',
    'Мейрамхана',
    'Асхана'
  ];

  List<Bag> _bags = [];
  List<dynamic> _stores = [];
  List<dynamic> _announcements = [];
  Map<String, dynamic> _stats = {};
  Set<String> _favorites = {};
  bool _loading = true;
  bool _loggedIn = false;
  String _name = '';
  String _email = '';
  String _query = '';
  String _category = 'Барлығы';
  final _dealsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await Future.wait([_loadAuth(), _loadContent()]);
  }

  Future<void> _loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      if (mounted)
        setState(() {
          _loggedIn = false;
          _name = '';
          _email = '';
        });
      return;
    }
    try {
      final profile = await ApiService.getMe();
      if (!mounted) return;
      final email = (profile['email'] ?? '').toString();
      final fullName = (profile['full_name'] ?? '').toString().trim();
      setState(() {
        _loggedIn = true;
        _email = email;
        _name = fullName.contains('@') || fullName == email.split('@').first
            ? ''
            : fullName;
      });
    } catch (_) {
      if (mounted)
        setState(() {
          _loggedIn = false;
          _name = '';
          _email = '';
        });
    }
  }

  Future<void> _loadContent() async {
    try {
      final values = await Future.wait([
        ApiService.getBags(),
        ApiService.getStores(),
        ApiService.getStats(),
        FavoritesService.getIds(),
        ApiService.getAllAnnouncements(),
      ]);
      if (!mounted) return;
      setState(() {
        _bags = (values[0] as List).map((item) => Bag.fromJson(item)).toList();
        _stores = values[1] as List;
        _stats = values[2] as Map<String, dynamic>;
        _favorites = values[3] as Set<String>;
        _announcements = values[4] as List;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Discover load error: $error');
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Bag> get _filtered => _bags.where((bag) {
        final terms =
            '${bag.title} ${bag.storeName} ${bag.storeCategory}'.toLowerCase();
        return (_query.isEmpty || terms.contains(_query.toLowerCase())) &&
            (_category == 'Барлығы' || bag.storeCategory == _category);
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      body: SafeArea(
        child: RefreshIndicator(
          color: _green,
          onRefresh: _refresh,
          child: LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth > 900;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: wide ? 36 : 18),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _header(),
                          const SizedBox(height: 20),
                          _hero(wide),
                          const SizedBox(height: 24),
                          _benefits(wide),
                          const SizedBox(height: 36),
                          _sectionHeading(
                              'Қалай жұмыс істейді?', 'Төрт қарапайым қадам'),
                          const SizedBox(height: 18),
                          _howItWorks(wide),
                          const SizedBox(height: 38),
                          _sectionHeading('Жақын жердегі орындар',
                              'Алматының серіктес кафелері'),
                          const SizedBox(height: 16),
                          _partnerList(),
                          if (_announcements.isNotEmpty) ...[
                            const SizedBox(height: 36),
                            _sectionHeading(
                                'Кафелерден жаңалық', 'Жаңа ұсыныстар'),
                            const SizedBox(height: 14),
                            _announcementList(),
                          ],
                          const SizedBox(height: 38),
                          Container(
                              key: _dealsKey,
                              child: _sectionHeading('Бүгінгі ұсыныстар',
                                  '${_filtered.length} пакет')),
                          const SizedBox(height: 16),
                          _searchAndFilters(),
                          const SizedBox(height: 18),
                          _deals(wide),
                          const SizedBox(height: 38),
                          _impact(),
                          const SizedBox(height: 16),
                          _closingCallout(),
                          const SizedBox(height: 28),
                          _footer(),
                          const SizedBox(height: 24),
                        ]),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _header() => Row(children: [
        Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: _green, borderRadius: BorderRadius.circular(13)),
            child:
                const Icon(Icons.eco_rounded, color: Colors.white, size: 23)),
        const SizedBox(width: 10),
        const Text('Qadam',
            style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: _ink,
                letterSpacing: -.6)),
        const Text(' Food',
            style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w500,
                color: _green,
                letterSpacing: -.6)),
        const Spacer(),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5EBE6)),
                borderRadius: BorderRadius.circular(24)),
            child: const Row(children: [
              Icon(Icons.location_on_outlined, size: 17, color: _green),
              SizedBox(width: 5),
              Text('Алматы',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: _ink))
            ])),
        const SizedBox(width: 9),
        if (!_loggedIn)
          TextButton(
              onPressed: _openAuth,
              child: const Text('Кіру',
                  style: TextStyle(color: _green, fontWeight: FontWeight.bold)))
        else
          InkWell(
              onTap: widget.onProfileTap,
              borderRadius: BorderRadius.circular(24),
              child: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFE7F2EC),
                  child: Text(_initial,
                      style: const TextStyle(
                          color: _green, fontWeight: FontWeight.bold)))),
      ]);

  String get _initial => (_name.isNotEmpty ? _name : _email).isNotEmpty
      ? (_name.isNotEmpty ? _name : _email)[0].toUpperCase()
      : 'Q';

  Future<void> _openAuth() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AuthScreen()));
    await _loadAuth();
  }

  Widget _hero(bool wide) => Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: wide ? 360 : 350),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: _green, borderRadius: BorderRadius.circular(24)),
        child: Stack(children: [
          Positioned.fill(
              child: Image.network(
                  'https://images.unsplash.com/photo-1547592180-85f173990554?w=1600&auto=format&fit=crop&q=85',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink())),
          Positioned.fill(
              child: DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                const Color(0xF50A5443),
                const Color(0xB30A5443),
                Colors.black.withValues(alpha: .12)
              ])))),
          Padding(
              padding: EdgeInsets.all(wide ? 44 : 26),
              child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: wide ? 540 : 360),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .14),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Text('АЛМАТЫДАҒЫ КҮНДЕЛІКТІ ҰСЫНЫСТАР',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: .9))),
                        const SizedBox(height: 20),
                        Text(
                            _name.isEmpty
                                ? 'Көбірек үнемде.\nАз ысырап ет.'
                                : 'Қош келдің, ${_name.split(' ').first}.\nКөбірек үнемде.',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: wide ? 48 : 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.4,
                                height: 1.04)),
                        const SizedBox(height: 14),
                        Text(
                            'Күн соңындағы дәмді тағамдарды 50–70% жеңілдікпен алып, тағам ысырабына қарсы қадам жаса.',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: .9),
                                fontSize: 15,
                                height: 1.55)),
                        const SizedBox(height: 22),
                        FilledButton(
                            onPressed: () {
                              final target = _dealsKey.currentContext;
                              if (target != null)
                                Scrollable.ensureVisible(target,
                                    duration: const Duration(milliseconds: 450),
                                    curve: Curves.easeInOut);
                            },
                            style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8A00),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28))),
                            child: const Text('Ұсыныстарды көру',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ]))),
        ]),
      );

  Widget _benefits(bool wide) {
    final items = [
      (Icons.sell_outlined, '50–70%', 'үнемде'),
      (Icons.schedule_rounded, 'Күн сайын', 'жаңа ұсыныс'),
      (Icons.eco_outlined, 'Ысырапты', 'азайт'),
      (Icons.storefront_outlined, '${_stores.length} орын', 'Алматыда')
    ];
    return LayoutBuilder(builder: (_, box) {
      final count = box.maxWidth > 680 ? 4 : 2;
      return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count,
              childAspectRatio: count == 4 ? 2.9 : 2.2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10),
          itemBuilder: (_, i) {
            final item = items[i];
            return Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE9EEE9)),
                    borderRadius: BorderRadius.circular(15)),
                child: Row(children: [
                  Icon(item.$1, color: _green, size: 22),
                  const SizedBox(width: 10),
                  Flexible(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(item.$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _ink,
                                fontSize: 13)),
                        Text(item.$3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: _muted, fontSize: 11))
                      ]))
                ]));
          });
    });
  }

  Widget _sectionHeading(String title, String sub) =>
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: _ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.5)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(color: _muted, fontSize: 13))
        ])),
        const Icon(Icons.arrow_forward_rounded, color: _green, size: 20)
      ]);

  Widget _howItWorks(bool wide) {
    final steps = [
      (
        Icons.search_rounded,
        'Орынды тап',
        'Жақын кафе мен наубайхананы таңда.'
      ),
      (
        Icons.shopping_bag_outlined,
        'Пакетті таңда',
        'Күн соңындағы жаңа ұсынысты бронда.'
      ),
      (Icons.qr_code_2_rounded, 'QR ал', 'Тапсырысыңды QR арқылы раста.'),
      (Icons.restaurant_rounded, 'Алып кет', 'Көрсетілген уақытта кафеден ал.')
    ];
    return LayoutBuilder(builder: (_, box) {
      final count = box.maxWidth > 700 ? 4 : 2;
      return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: steps.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count,
              childAspectRatio: count == 4 ? 1.22 : 1.05,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14),
          itemBuilder: (_, i) {
            final step = steps[i];
            return Container(
                padding: const EdgeInsets.all(19),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE9EEE9)),
                    borderRadius: BorderRadius.circular(18)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('0${i + 1}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF8A00))),
                      const SizedBox(height: 12),
                      Icon(step.$1, color: _green, size: 25),
                      const SizedBox(height: 12),
                      Text(step.$2,
                          style: const TextStyle(
                              color: _ink,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      const SizedBox(height: 5),
                      Expanded(
                          child: Text(step.$3,
                              style: const TextStyle(
                                  color: _muted, fontSize: 12, height: 1.45)))
                    ]));
          });
    });
  }

  Widget _partnerList() {
    if (_stores.isEmpty) return const SizedBox.shrink();
    return SizedBox(
        height: 166,
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _stores.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final store = _stores[i] as Map<String, dynamic>;
              final image = (store['image_url'] ?? '').toString();
              return Container(
                  width: 150,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE9EEE9)),
                      borderRadius: BorderRadius.circular(17)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Stack(fit: StackFit.expand, children: [
                          if (image.isNotEmpty)
                            (image.startsWith('assets/')
                                ? Image.asset(image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _storeFallback(store['name']))
                                : Image.network(image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _storeFallback(store['name']))),
                          if (image.isEmpty) _storeFallback(store['name']),
                          Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14)),
                                  child: Text('⭐ ${store['rating'] ?? '4.8'}',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold))))
                        ])),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(store['name'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: _ink,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Text(store['category'] ?? 'Кафе',
                                      style: const TextStyle(
                                          color: _muted, fontSize: 10))
                                ]))
                      ]));
            }));
  }

  Widget _storeFallback(dynamic name) => Container(
      color: const Color(0xFFE7F2EC),
      child: Center(
          child: Icon(Icons.storefront_rounded,
              color: _green.withValues(alpha: .65), size: 34)));

  Widget _announcementList() => SizedBox(
      height: 115,
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _announcements.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final item = _announcements[i] as Map<String, dynamic>;
            return Container(
                width: 270,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: const Color(0xFFEAF3ED),
                    borderRadius: BorderRadius.circular(17)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['store_name'] ?? 'Qadam Food',
                          style: const TextStyle(
                              color: _green,
                              fontWeight: FontWeight.bold,
                              fontSize: 11)),
                      const SizedBox(height: 6),
                      Text(item['title'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: _ink,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      const SizedBox(height: 4),
                      Expanded(
                          child: Text(item['body'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(color: _muted, fontSize: 11)))
                    ]));
          }));

  Widget _searchAndFilters() => Column(children: [
        TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
                hintText: 'Кафе немесе пакет іздеу',
                prefixIcon: const Icon(Icons.search, color: _green),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5EBE6))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5EBE6))))),
        const SizedBox(height: 12),
        SizedBox(
            height: 38,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final category = _categories[i];
                  final selected = category == _category;
                  return ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) => setState(() => _category = category),
                      selectedColor: _green,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                          color: selected ? _green : const Color(0xFFE0E7E1)),
                      labelStyle: TextStyle(
                          color: selected ? Colors.white : _ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w600));
                })),
      ]);

  Widget _deals(bool wide) {
    if (_loading)
      return const Padding(
          padding: EdgeInsets.all(42),
          child: Center(child: CircularProgressIndicator(color: _green)));
    if (_filtered.isEmpty)
      return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: const Column(children: [
            Icon(Icons.search_off_rounded, size: 40, color: _muted),
            SizedBox(height: 9),
            Text('Ұсыныс табылмады',
                style: TextStyle(color: _ink, fontWeight: FontWeight.bold)),
            SizedBox(height: 3),
            Text('Сүзгіні өзгертіп көріңіз.',
                style: TextStyle(color: _muted, fontSize: 12))
          ]));
    final width = MediaQuery.sizeOf(context).width;
    final columns = width > 1000 ? 3 : (width > 640 ? 2 : 1);
    if (columns == 1) {
      return Column(children: [
        for (var i = 0; i < _filtered.length; i++)
          Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _bagCard(_filtered[i], i)),
      ]);
    }
    return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _filtered.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: 1.0,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14),
        itemBuilder: (_, i) {
          final bag = _filtered[i];
          return _bagCard(bag, i);
        });
  }

  Widget _bagCard(Bag bag, int index) => BagCard(
        bag: bag,
        tag: index == 0 ? 'Тиімді ұсыныс' : null,
        isFavorite: _favorites.contains(bag.id),
        onFavoriteToggle: () async {
          final isFavorite = await FavoritesService.toggle(bag.id);
          if (!mounted) return;
          setState(() {
            if (isFavorite) {
              _favorites.add(bag.id);
            } else {
              _favorites.remove(bag.id);
            }
          });
        },
        onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => BagDetailScreen(bag: bag)))
            .then((_) => _loadContent()),
      );

  Widget _impact() => Container(
      padding: const EdgeInsets.all(22),
      decoration:
          BoxDecoration(color: _green, borderRadius: BorderRadius.circular(20)),
      child: LayoutBuilder(builder: (_, box) {
        final labels = [
          ('${_stats['meals_saved'] ?? 0}', 'тағам сақталды'),
          ('${_stats['kg_saved'] ?? 0} кг', 'ысырап азайды'),
          ('${_stats['co2_prevented'] ?? 0} кг', 'CO₂ үнемделді')
        ];
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Әр қадамның әсері',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Бірге тамақты сақтаймыз.',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 20),
          Row(children: [
            for (final item in labels)
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(item.$1,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: box.maxWidth < 450 ? 20 : 25,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(item.$2,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 10))
                  ]))
          ])
        ]);
      }));

  Widget _closingCallout() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            color: const Color(0xFFFFF4E7),
            borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: const Color(0xFFFFE3C4),
                  borderRadius: BorderRadius.circular(15)),
              child:
                  const Icon(Icons.favorite_rounded, color: Color(0xFFE27A00))),
          const SizedBox(width: 13),
          const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Жақсы тағамды бірге сақтайық.',
                    style: TextStyle(
                        color: _ink,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Бүгінгі пакеттерді қарап, өз қадамыңызды жасаңыз.',
                    style: TextStyle(color: _muted, fontSize: 12, height: 1.4))
              ])),
          const SizedBox(width: 12),
          IconButton(
              onPressed: () {
                final target = _dealsKey.currentContext;
                if (target != null)
                  Scrollable.ensureVisible(target,
                      duration: const Duration(milliseconds: 400));
              },
              icon: const Icon(Icons.arrow_forward_rounded, color: _green)),
        ]),
      );

  Widget _footer() => Row(children: [
        const Icon(Icons.eco_outlined, size: 18, color: _green),
        const SizedBox(width: 7),
        const Text('Qadam Food',
            style: TextStyle(color: _ink, fontWeight: FontWeight.bold)),
        const Spacer(),
        Text('Тамақ ысырабына қарсы бір қадам.',
            style: TextStyle(color: _muted, fontSize: 11))
      ]);
}
