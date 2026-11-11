import 'package:flutter/material.dart';
import '../models/bag_model.dart';
import '../services/api_service.dart';
import '../widgets/bag_card.dart';
import 'bag_detail_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});
  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabs;
  List<Bag> _bags = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });
    _searchController.addListener(() =>
        setState(() => _query = _searchController.text.toLowerCase().trim()));
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final response = await ApiService.getBags();
      if (!mounted) return;
      setState(() {
        _bags = response.map((item) => Bag.fromJson(item)).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Bag> get _filtered {
    var result = _bags;
    if (_tabs.index == 1)
      result = result.where((bag) => bag.pickupDate == 'today').toList();
    if (_tabs.index == 2)
      result = result.where((bag) => bag.pickupDate == 'tomorrow').toList();
    if (_query.isNotEmpty)
      result = result
          .where((bag) =>
              '${bag.title} ${bag.storeName}'.toLowerCase().contains(_query))
          .toList();
    return result;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8FAF7),
        body: SafeArea(
            child: Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ұсыныстар',
                        style: TextStyle(
                            color: Color(0xFF173B30),
                            fontSize: 27,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Text('Жақын жердегі дәмді пакеттерді табыңыз.',
                        style:
                            TextStyle(color: Color(0xFF68766E), fontSize: 13)),
                    const SizedBox(height: 17),
                    TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                            hintText: 'Кафе немесе пакет іздеу',
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: Color(0xFF0A5443)),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE5EBE6))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                    color: Color(0xFFE5EBE6))))),
                  ])),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE7EDE8)),
                  borderRadius: BorderRadius.circular(14)),
              child: TabBar(
                  controller: _tabs,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF68766E),
                  indicator: BoxDecoration(
                      color: const Color(0xFF0A5443),
                      borderRadius: BorderRadius.circular(12)),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Барлығы'),
                    Tab(text: 'Бүгін'),
                    Tab(text: 'Ертең')
                  ])),
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(children: [
                Text('${_filtered.length} ұсыныс',
                    style: const TextStyle(
                        color: Color(0xFF173B30),
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                const Icon(Icons.tune_rounded,
                    size: 18, color: Color(0xFF0A5443)),
                const SizedBox(width: 5),
                const Text('Жаңа',
                    style: TextStyle(
                        color: Color(0xFF0A5443),
                        fontWeight: FontWeight.w600,
                        fontSize: 12))
              ])),
          Expanded(
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF0A5443)))
                  : _filtered.isEmpty
                      ? const Center(
                          child: Text('Ұсыныс табылмады',
                              style: TextStyle(color: Color(0xFF68766E))))
                      : RefreshIndicator(
                          color: const Color(0xFF0A5443),
                          onRefresh: _load,
                          child: LayoutBuilder(builder: (_, constraints) {
                            final columns = constraints.maxWidth > 1050
                                ? 3
                                : (constraints.maxWidth > 680 ? 2 : 1);
                            if (columns == 1)
                              return ListView.separated(
                                  padding:
                                      const EdgeInsets.fromLTRB(18, 0, 18, 18),
                                  itemCount: _filtered.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 14),
                                  itemBuilder: (_, i) =>
                                      _bagCard(_filtered[i]));
                            return GridView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(18, 0, 18, 18),
                                itemCount: _filtered.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: columns,
                                        childAspectRatio: 1,
                                        crossAxisSpacing: 14,
                                        mainAxisSpacing: 14),
                                itemBuilder: (_, i) => _bagCard(_filtered[i]));
                          }))),
        ])),
      );

  Widget _bagCard(Bag bag) => BagCard(
      bag: bag,
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => BagDetailScreen(bag: bag))));
}
