import 'package:flutter/material.dart';
import '../models/bag_model.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../widgets/bag_card.dart';
import 'bag_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Bag> _bags = [];
  Set<String> _favIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ids = await FavoritesService.getIds();
      final response = await ApiService.getBags();
      final all = response.map((j) => Bag.fromJson(j)).toList();
      if (!mounted) return;
      setState(() {
        _favIds = ids;
        _bags = all.where((b) => ids.contains(b.id)).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        title: const Text('Таңдаулылар', style: TextStyle(color: Color(0xFF0A2E26), fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bags.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 72, color: Color(0xFFFF8A00)),
                        SizedBox(height: 16),
                        Text('Таңдаулы пакет жоқ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Карточкадағы жүрекшені басып, пакетті сақтаңыз', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bags.length,
                    itemBuilder: (_, i) {
                      final bag = _bags[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: BagCard(
                          bag: bag,
                          isFavorite: _favIds.contains(bag.id),
                          onFavoriteToggle: () async {
                            await FavoritesService.toggle(bag.id);
                            _load();
                          },
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BagDetailScreen(bag: bag)),
                          ).then((_) => _load()),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
