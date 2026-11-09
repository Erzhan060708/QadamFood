import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MerchantPortalScreen extends StatefulWidget {
  final int storeId;
  const MerchantPortalScreen({super.key, required this.storeId});

  @override
  State<MerchantPortalScreen> createState() => _MerchantPortalScreenState();
}

class _MerchantPortalScreenState extends State<MerchantPortalScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _title = TextEditingController();
  final _body = TextEditingController();
  Map<String, dynamic>? _store;
  List<dynamic> _announcements = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _email.text = 'demo.cafe${widget.storeId}@qadam.food';
    _password.text = 'QadamDemo!${widget.storeId}';
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await ApiService.login(_email.text.trim(), _password.text);
      final store = await ApiService.getMerchantStore(widget.storeId);
      final posts = await ApiService.getAnnouncements(widget.storeId);
      if (!mounted) return;
      setState(() { _store = store; _announcements = posts; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  Future<void> _publish() async {
    try {
      await ApiService.createAnnouncement(widget.storeId, _title.text, _body.text);
      _title.clear();
      _body.clear();
      final posts = await ApiService.getAnnouncements(widget.storeId);
      if (mounted) setState(() => _announcements = posts);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0A5443);
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(title: Text(_store?['name'] ?? 'Серіктес кабинеті'), backgroundColor: green, foregroundColor: Colors.white),
      body: _loading ? const Center(child: CircularProgressIndicator()) : _store == null ? _buildLogin() : _buildDashboard(),
    );
  }

  Widget _buildLogin() => Center(child: SingleChildScrollView(child: Container(
    constraints: const BoxConstraints(maxWidth: 440), margin: const EdgeInsets.all(24), padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.storefront_rounded, color: Color(0xFF0A5443), size: 42),
      const SizedBox(height: 16), const Text('Кафе кабинеті', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xFF0A2E26))),
      const SizedBox(height: 8), const Text('Демо аккаунтпен кіріп, өз хабарландыруыңызды жариялаңыз.'),
      const SizedBox(height: 22), TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
      const SizedBox(height: 12), TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Құпиясөз', border: OutlineInputBorder())),
      const SizedBox(height: 18), SizedBox(width: double.infinity, child: FilledButton(onPressed: _login, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0A5443), padding: const EdgeInsets.all(16)), child: const Text('Кабинетке кіру'))),
      const SizedBox(height: 10), const Text('Бұл — тестке арналған демо кіру деректері.', style: TextStyle(color: Colors.black54, fontSize: 12)),
    ]),
  )));

  Widget _buildDashboard() => ListView(padding: const EdgeInsets.all(20), children: [
    Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: const Color(0xFF0A5443), borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Қайырлы күн 👋', style: TextStyle(color: Colors.white70)), const SizedBox(height: 6), Text(_store?['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)), const SizedBox(height: 10), Text(_store?['address'] ?? '', style: const TextStyle(color: Colors.white70)),
    ])),
    const SizedBox(height: 22), const Text('Жаңа хабарландыру', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)), const SizedBox(height: 12),
    TextField(controller: _title, decoration: const InputDecoration(labelText: 'Тақырып', filled: true, fillColor: Colors.white, border: OutlineInputBorder())), const SizedBox(height: 10),
    TextField(controller: _body, maxLines: 3, decoration: const InputDecoration(labelText: 'Хабарландыру мәтіні', filled: true, fillColor: Colors.white, border: OutlineInputBorder())), const SizedBox(height: 12),
    FilledButton.icon(onPressed: _publish, icon: const Icon(Icons.campaign_outlined), label: const Text('Жариялау'), style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF8A00), padding: const EdgeInsets.all(15))),
    const SizedBox(height: 24), const Text('Жарияланған хабарландырулар', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)), const SizedBox(height: 8),
    if (_announcements.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('Әзірге хабарландыру жоқ.')),
    ..._announcements.map((item) => Card(color: Colors.white, child: ListTile(leading: const CircleAvatar(backgroundColor: Color(0xFFE9F3ED), child: Icon(Icons.campaign, color: Color(0xFF0A5443))), title: Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(item['body'] ?? '')))),
  ]);
}
