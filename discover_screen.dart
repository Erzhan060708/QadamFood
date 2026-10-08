import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bag_model.dart';
import '../widgets/bag_card.dart';
import 'bag_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Bag> bags = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBags();
  }

  Future<void> _fetchBags() async {
    try {
      final response = await supabase
          .from('bags')
          .select('*, stores(*)')
          .eq('status', 'active');

      setState(() {
        bags = (response as List).map((json) => Bag.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Ошибка загрузки: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(Widget context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bags.isEmpty
              ? const Center(child: Text('Пока нет доступных пакетов 😔'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bags.length,
                  itemBuilder: (context, index) {
                    final bag = bags[index];
                    return BagCard(
                      bag: bag,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BagDetailScreen(bag: bag),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}