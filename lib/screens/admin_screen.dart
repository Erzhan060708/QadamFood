import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';

// ═══════════════════════════════════════════════════════════════
//  ADMIN SCREEN
// ═══════════════════════════════════════════════════════════════

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  final _passwordCtrl = TextEditingController();

  static const _ADMIN_PASSWORD = 'qadam2025';
  bool _isAuthenticated = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 4 қойынды болды
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _authenticate() {
    if (_passwordCtrl.text.trim() == _ADMIN_PASSWORD) {
      setState(() => _isAuthenticated = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пароль қате'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) return _buildLogin();

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        foregroundColor: const Color(0xFF0A5443),
        elevation: 0,
        title: const Text('Qadam басқару орталығы',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A2E26))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF0A5443)),
            onPressed: () => setState(() => _isAuthenticated = false),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF8A00),
          indicatorWeight: 3,
          labelColor: const Color(0xFF0A5443),
          unselectedLabelColor: const Color(0xFF718078),
          isScrollable: true, // Табтар көбейгендіктен экранға сыймаса, скролл болады
          tabs: const [
            Tab(icon: Icon(Icons.storefront), text: 'Кафелер'),
            Tab(icon: Icon(Icons.shopping_bag), text: 'Пакеттер'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Заказдар'),
            Tab(icon: Icon(Icons.people), text: 'Қолданушылар'), // ЖАҢА ТАБ
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CafesTab(),
          _BagsTab(),
          _OrdersTab(),
          _UsersTab(), // ЖАҢА ЭКРАН
        ],
      ),
    );
  }

  Widget _buildLogin() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF0A5443),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A5443),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.admin_panel_settings,
                      color: Colors.white, size: 48),
                ),
                const SizedBox(height: 24),
                const Text('Әкімші панелі',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2E26))),
                const SizedBox(height: 8),
                Text('Тек кафе иелері үшін',
                    style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 32),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  onSubmitted: (_) => _authenticate(),
                  decoration: InputDecoration(
                    labelText: 'Әкімші паролі',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A5443),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Кіру',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TAB 1: CAFES
// ═══════════════════════════════════════════════════════════════
class _CafesTab extends StatefulWidget {
  const _CafesTab();

  @override
  State<_CafesTab> createState() => _CafesTabState();
}

class _CafesTabState extends State<_CafesTab> {
  List<Map<String, dynamic>> _cafes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getStores();
      setState(() {
        _cafes = List<Map<String, dynamic>>.from(res);
        _loading = false;
      });
    } catch (e) {
      debugPrint('Cafes load error: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Өшіру?'),
        content: Text('«$name» кафесін өшіресіз бе?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Жоқ')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Иә, өшіру',
                  style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService.deleteStore(int.parse(id));
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Қате: $e')));
      }
    }
  }

  void _showMerchantQr(Map<String, dynamic> cafe) {
    final id = cafe['id'].toString();
    final url = 'https://qadam-food.vercel.app/#/merchant/$id';
    showDialog<void>(context: context, builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('${cafe['name']} · демо QR'),
      content: SizedBox(width: 320, child: Column(mainAxisSize: MainAxisSize.min, children: [
        QrImageView(data: url, size: 210, backgroundColor: Colors.white),
        const SizedBox(height: 12), const Text('Сканер осы кафенің демо кабинетіне апарады.', textAlign: TextAlign.center),
        const SizedBox(height: 14),
        Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF5EFE6), borderRadius: BorderRadius.circular(14)), child: SelectableText('demo.cafe$id@qadam.food\nQadamDemo!$id', style: const TextStyle(fontSize: 13, height: 1.5))),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Жабу'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => const _AddCafeDialog(),
          );
          if (ok == true) _load();
        },
        backgroundColor: const Color(0xFF0A5443),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Кафе қосу',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cafes.isEmpty
              ? _empty('Кафе жоқ. «Қосу» батырмасын басыңыз.')
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: _cafes.length + 1,
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF0A5443), Color(0xFF1F7A4D)]),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Серіктес орындар', style: TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 5),
                              Text('${_cafes.length} кафе', style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              const Text('QR код пен демо кабинет әр орынға жеке.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ])),
                            Container(width: 54, height: 54, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .15), borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28)),
                          ]),
                        );
                      }
                      final c = _cafes[i - 1];
                      final imageUrl = c['image_url'] as String?;
                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: (imageUrl != null && imageUrl.isNotEmpty)
                                ? Image.network(
                                    imageUrl,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _avatar(c['name']),
                                  )
                                : _avatar(c['name']),
                          ),
                          title: Text(c['name'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('📍 ${c['address'] ?? '—'}'),
                              if (c['phone'] != null)
                                Text('📞 ${c['phone']}'),
                              Text('⭐ ${c['rating'] ?? 5.0}  ·  ${c['category'] ?? 'Кафе'}'),
                            ],
                          ),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(tooltip: 'Кафе QR коды', icon: const Icon(Icons.qr_code_2, color: Color(0xFF0A5443)), onPressed: () => _showMerchantQr(c)),
                            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _delete(c['id'].toString(), c['name'])),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _avatar(String? name) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF0A5443),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          (name ?? '?')[0].toUpperCase(),
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _empty(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(text,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
//  ADD CAFE DIALOG
// ═══════════════════════════════════════════════════════════════
class _AddCafeDialog extends StatefulWidget {
  const _AddCafeDialog();

  @override
  State<_AddCafeDialog> createState() => _AddCafeDialogState();
}

class _AddCafeDialogState extends State<_AddCafeDialog> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController(text: '09:00 - 22:00');
  final _descCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController(text: '4.5');
  final _imageCtrl = TextEditingController();

  String _category = 'Кафе';
  bool _saving = false;

  final List<String> _categories = [
    'Кафе', 'Наубайхана', 'Мейрамхана', 'Кофехана', 'Асхана', 'Дүкен',
  ];

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Аты мен мекенжайды толтырыңыз')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await ApiService.createStore({
        'name': _nameCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'working_hours': _hoursCtrl.text.trim(),
        'category': _category,
        'rating': double.tryParse(_ratingCtrl.text) ?? 4.5,
        'image_url': _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
      });

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Қате: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.storefront, color: Color(0xFF0A5443)),
                  const SizedBox(width: 8),
                  const Text('Жаңа кафе қосу',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              _field(_nameCtrl, 'Кафе атауы *', 'Coffee Boom', Icons.storefront),
              const SizedBox(height: 12),
              _field(_addressCtrl, 'Мекенжай *', 'Алматы, Абай 15', Icons.location_on),
              const SizedBox(height: 12),
              _field(_phoneCtrl, 'Телефон', '+7 777 123 45 67', Icons.phone, keyboard: TextInputType.phone),
              const SizedBox(height: 12),
              _field(_hoursCtrl, 'Жұмыс уақыты', '09:00 - 22:00', Icons.access_time),
              const SizedBox(height: 12),
              _field(_imageCtrl, 'Сурет сілтемесі (URL)', 'https://...', Icons.image),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: 'Категория',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v ?? 'Кафе'),
              ),
              const SizedBox(height: 12),

              _field(_ratingCtrl, 'Рейтинг', '4.5', Icons.star, keyboard: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Болдырмау'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A5443),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Сақтау', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, String hint, IconData icon, {TextInputType? keyboard}) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TAB 2: BAGS
// ═══════════════════════════════════════════════════════════════
class _BagsTab extends StatefulWidget {
  const _BagsTab();

  @override
  State<_BagsTab> createState() => _BagsTabState();
}

class _BagsTabState extends State<_BagsTab> {
  List<Map<String, dynamic>> _bags = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getBags();
      setState(() {
        _bags = List<Map<String, dynamic>>.from(res);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id, String title) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Өшіру?'),
        content: Text('«$title» пакетін өшіресіз бе?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Жоқ')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Иә', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService.deleteBag(int.parse(id));
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Қате: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => const _AddBagDialog(),
          );
          if (ok == true) _load();
        },
        backgroundColor: const Color(0xFFFF8A00),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Пакет қосу', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bags.isEmpty
              ? _empty('Пакет жоқ. «Қосу» батырмасын басыңыз.')
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bags.length,
                    itemBuilder: (_, i) {
                      final b = _bags[i];
                      final store = b['stores'] as Map<String, dynamic>?;
                      final isSoldOut = b['status'] == 'sold_out' || (b['quantity_available'] ?? 0) <= 0;
                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(b['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isSoldOut ? Colors.grey.shade300 : const Color(0xFFFCEFCB),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      isSoldOut ? 'Sold Out' : 'Active',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSoldOut ? Colors.grey.shade700 : const Color(0xFF0A5443)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('🏪 ${store?['name'] ?? '?'}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text('₸${(b['original_price'] as num).toInt()}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12)),
                                  const SizedBox(width: 6),
                                  Text('₸${(b['discounted_price'] as num).toInt()}', style: const TextStyle(color: Color(0xFF0A5443), fontWeight: FontWeight.bold, fontSize: 15)),
                                  const Spacer(),
                                  Text('📦 ${b['quantity_available']}', style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(child: Text('⏰ ${b['pickup_start']} - ${b['pickup_end']}', style: const TextStyle(fontSize: 12))),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    onPressed: () => _delete(b['id'].toString(), b['title']),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _empty(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(text, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
//  ADD BAG DIALOG
// ═══════════════════════════════════════════════════════════════
class _AddBagDialog extends StatefulWidget {
  const _AddBagDialog();

  @override
  State<_AddBagDialog> createState() => _AddBagDialogState();
}

class _AddBagDialogState extends State<_AddBagDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _originalCtrl = TextEditingController(text: '2500');
  final _discountCtrl = TextEditingController(text: '899');
  final _qtyCtrl = TextEditingController(text: '5');
  final _imageCtrl = TextEditingController();

  String? _selectedStoreId;
  List<Map<String, dynamic>> _stores = [];
  TimeOfDay _start = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 21, minute: 0);
  bool _saving = false;
  bool _loadingStores = true;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    try {
      final res = await ApiService.getStores();
      if (!mounted) return;
      setState(() {
        _stores = List<Map<String, dynamic>>.from(res);
        if (_stores.isNotEmpty) _selectedStoreId = _stores.first['id'].toString();
        _loadingStores = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingStores = false);
    }
  }

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пакет атауын жазыңыз')));
      return;
    }
    if (_selectedStoreId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Кафе таңдаңыз')));
      return;
    }

    setState(() => _saving = true);

    try {
      await ApiService.createBag({
        'store_id': int.parse(_selectedStoreId!),
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'original_price': double.tryParse(_originalCtrl.text) ?? 0,
        'discounted_price': double.tryParse(_discountCtrl.text) ?? 0,
        'pickup_start': _fmtTime(_start),
        'pickup_end': _fmtTime(_end),
        'quantity_available': int.tryParse(_qtyCtrl.text) ?? 1,
        'image_url': _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
      });

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Қате: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final t = await showTimePicker(context: context, initialTime: isStart ? _start : _end);
    if (t != null) setState(() => isStart ? _start = t : _end = t);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _loadingStores
              ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag, color: Color(0xFFFF8A00)),
                        const SizedBox(width: 8),
                        const Text('Жаңа пакет қосу', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedStoreId,
                      decoration: InputDecoration(
                        labelText: 'Кафе *',
                        prefixIcon: const Icon(Icons.storefront),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _stores.map((s) => DropdownMenuItem<String>(value: s['id'].toString(), child: Text(s['name'] ?? ''))).toList(),
                      onChanged: (v) => setState(() => _selectedStoreId = v),
                    ),
                    const SizedBox(height: 12),
                    _field(_titleCtrl, 'Пакет атауы *', 'Coffee & Cake Box', Icons.shopping_bag),
                    const SizedBox(height: 12),
                    _field(_descCtrl, 'Сипаттама', 'Кофе мен тәтті', Icons.description, maxLines: 2),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _field(_originalCtrl, 'Ескі баға', '2500', Icons.attach_money, keyboard: TextInputType.number)),
                        const SizedBox(width: 10),
                        Expanded(child: _field(_discountCtrl, 'Жаңа баға', '899', Icons.money, keyboard: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _field(_qtyCtrl, 'Саны', '5', Icons.inventory, keyboard: TextInputType.number),
                    const SizedBox(height: 12),
                    _field(_imageCtrl, 'Сурет сілтемесі (URL)', 'https://...', Icons.image),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _timeBtn('Басталу', _start, () => _pickTime(true))),
                        const SizedBox(width: 10),
                        Expanded(child: _timeBtn('Аяқталу', _end, () => _pickTime(false))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving ? null : () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text('Болдырмау'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _save,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A00), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: _saving
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Сақтау', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, String hint, IconData icon, {TextInputType? keyboard, int maxLines = 1}) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _timeBtn(String label, TimeOfDay t, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.access_time),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text('${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TAB 3: ORDERS
// ═══════════════════════════════════════════════════════════════
class _OrdersTab extends StatefulWidget {
  const _OrdersTab();

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getAdminOrders();
      setState(() {
        _orders = List<Map<String, dynamic>>.from(res);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _complete(String id) async {
    try {
      await ApiService.completeOrder(int.parse(id));
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Қате: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('Заказдар жоқ', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (_, i) {
                      final o = _orders[i];
                      final bag = o['bags'] as Map<String, dynamic>?;
                      final store = bag?['stores'] as Map<String, dynamic>?;
                      final isPaid = o['status'] == 'paid';
                      final isCompleted = o['status'] == 'completed';
                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isCompleted ? Colors.grey.shade200 : const Color(0xFFFCEFCB),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isCompleted ? 'Аяқталды' : 'Белсенді',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isCompleted ? Colors.grey.shade700 : const Color(0xFF0A5443)),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(o['qr_code'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(bag?['title'] ?? '—', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              Text('🏪 ${store?['name'] ?? '—'}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              Text('👤 ${(o['user'] as Map?)?['full_name'] ?? ''} ${(o['user'] as Map?)?['email'] ?? ''}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              if (isPaid) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _complete(o['id'].toString()),
                                    icon: const Icon(Icons.check, color: Colors.white, size: 18),
                                    label: const Text('Заказды аяқтау', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A5443), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TAB 4: USERS (ЖАҢА)
// ═══════════════════════════════════════════════════════════════
class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getUsers();
      setState(() {
        _users = List<Map<String, dynamic>>.from(res);
        _loading = false;
      });
    } catch (e) {
      debugPrint('Users load error: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('Қолданушылар жоқ'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _users.length,
                    itemBuilder: (_, i) {
                      final u = _users[i];
                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF0A5443),
                            child: Text(
                              (u['email'] ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(u['full_name'] ?? 'User',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(u['email'] ?? ''),
                          trailing: Text(
                            '${u['points']} ұпай',
                            style: const TextStyle(color: Color(0xFF0A5443), fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
