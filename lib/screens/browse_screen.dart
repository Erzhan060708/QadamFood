import 'package:flutter/material.dart';
import '../models/bag_model.dart';
import '../widgets/bag_card.dart';
import 'bag_detail_screen.dart';
import '../services/api_service.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();

  late TabController _tabController;
  List<Bag> _allBags = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _fetchBags();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBags() async {
    try {
      final response = await ApiService.getBags();
      if (!mounted) return;
      setState(() {
        _allBags = response.map((json) => Bag.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Ошибка загрузки: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<Bag> _applyFilters() {
    List<Bag> result = _allBags;
    final tabIndex = _tabController.index;
    if (tabIndex == 1) {
      result = result.where((b) => b.pickupDate == 'today').toList();
    } else if (tabIndex == 2) {
      result = result.where((b) => b.pickupDate == 'tomorrow').toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((b) =>
              b.title.toLowerCase().contains(_searchQuery) ||
              b.storeName.toLowerCase().contains(_searchQuery))
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final bags = _applyFilters();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F3),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Кафе немесе пакет іздеу...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF005C4B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.map_outlined, color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Карта появится в версии 2.0 🗺️')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF005C4B),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFFF7A00),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Today'),
                Tab(text: 'Tomorrow'),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${_tabController.index == 0 ? "All" : _tabController.index == 1 ? "Today's" : "Tomorrow's"} surprise bags (${bags.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : bags.isEmpty
                      ? const Center(
                          child: Text('Әзірге бос. Басқа сүзгіні көріңіз.', style: TextStyle(color: Colors.grey)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: bags.length,
                          itemBuilder: (context, i) {
                            final bag = bags[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: BagCard(
                                bag: bag,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => BagDetailScreen(bag: bag)),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}