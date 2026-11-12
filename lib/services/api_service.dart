import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://qadam-backend-iobo.onrender.com';

  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> register(
      String email, String password, String fullName) async {
    final res = await http.post(Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'email': email, 'password': password, 'full_name': fullName}));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access_token']);
      return data;
    }
    throw Exception(jsonDecode(res.body)['detail'] ?? 'Қате');
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access_token']);
      return data;
    }
    throw Exception('Email немесе құпиясөз қате');
  }

  static Future<Map<String, dynamic>> getMe() async {
    final res =
        await http.get(Uri.parse('$baseUrl/api/me'), headers: await _authHeaders());
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Деректерді алу мүмкін болмады');
  }

  static Future<List<dynamic>> getBags({String q = '', String category = ''}) async {
    final uri = Uri.parse('$baseUrl/api/bags').replace(queryParameters: {
      if (q.isNotEmpty) 'q': q,
      if (category.isNotEmpty) 'category': category,
    });
    final res = await http.get(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Пакеттерді жүктеу мүмкін болмады');
  }

  static Future<List<dynamic>> getStores() async {
    final res = await http.get(Uri.parse('$baseUrl/api/stores'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Кафелерді жүктеу мүмкін болмады');
  }

  static Future<Map<String, dynamic>> getMerchantStore(int storeId) async {
    final res = await http.get(Uri.parse('$baseUrl/api/merchant/stores/$storeId'), headers: await _authHeaders());
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Кафе кабинетіне кіруге рұқсат жоқ');
  }

  static Future<List<dynamic>> getAnnouncements(int storeId) async {
    final res = await http.get(Uri.parse('$baseUrl/api/stores/$storeId/announcements'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Хабарландыруларды алу мүмкін болмады');
  }

  static Future<List<dynamic>> getAllAnnouncements() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/announcements'));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return [];
  }

  static Future<void> createAnnouncement(int storeId, String title, String body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/merchant/stores/$storeId/announcements'),
      headers: await _authHeaders(),
      body: jsonEncode({'title': title, 'body': body}),
    );
    if (res.statusCode != 200) {
      final data = jsonDecode(res.body);
      throw Exception(data['detail'] ?? 'Хабарландыру жарияланбады');
    }
  }

  static Future<Map<String, dynamic>> getStats() async {
    final res = await http.get(Uri.parse('$baseUrl/api/stats'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {
      'meals_saved': 0,
      'kg_saved': 0,
      'co2_prevented': 0,
      'users': 0,
      'stores': 0,
    };
  }

  static Future<void> createStore(Map<String, dynamic> data) async {
    await http.post(Uri.parse('$baseUrl/api/stores'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
  }

  static Future<void> deleteStore(int id) async {
    await http.delete(Uri.parse('$baseUrl/api/stores/$id'));
  }

  static Future<void> createBag(Map<String, dynamic> data) async {
    await http.post(Uri.parse('$baseUrl/api/bags'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
  }

  static Future<void> deleteBag(int id) async {
    await http.delete(Uri.parse('$baseUrl/api/bags/$id'));
  }

  static Future<Map<String, dynamic>> createOrder(int bagId) async {
    final prefs = await SharedPreferences.getInstance();
    final keyName = 'pending_order_key_$bagId';
    var requestKey = prefs.getString(keyName);
    if (requestKey == null) {
      final random = Random.secure();
      requestKey = '${DateTime.now().microsecondsSinceEpoch}-'
          '${List.generate(16, (_) => random.nextInt(16).toRadixString(16)).join()}';
      await prefs.setString(keyName, requestKey);
    }
    final headers = await _authHeaders();
    final body = jsonEncode({'bag_id': bagId, 'request_key': requestKey});
    Object? lastError;

    // Retry only transport failures, using the same key so a committed order
    // cannot be charged or created twice if the response was lost.
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final res = await http.post(Uri.parse('$baseUrl/api/orders'),
            headers: headers, body: body).timeout(const Duration(seconds: 20));
        if (res.statusCode == 200) {
          await prefs.remove(keyName);
          return jsonDecode(res.body);
        }
        final detail = _responseDetail(res.body);
        throw Exception(detail ?? 'Сатып алу мүмкін болмады (${res.statusCode})');
      } on http.ClientException catch (error) {
        lastError = error;
      } on TimeoutException catch (error) {
        lastError = error;
      }
      if (attempt == 0) await Future<void>.delayed(const Duration(seconds: 1));
    }
    throw Exception(
        'Байланыс үзілді. Тапсырыстың қайталанбауы үшін оны тексеріп, қайта көріңіз. ($lastError)');
  }

  static String? _responseDetail(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded['detail']?.toString() : null;
    } catch (_) {
      return null;
    }
  }

  static Future<List<dynamic>> getOrders() async {
    final res =
        await http.get(Uri.parse('$baseUrl/api/orders'), headers: await _authHeaders());
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Заказдарды алу мүмкін болмады');
  }

  static Future<List<dynamic>> getAdminOrders() async {
    final res = await http.get(Uri.parse('$baseUrl/api/admin/orders'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Заказдарды алу мүмкін болмады');
  }

  static Future<void> completeOrder(int id) async {
    await http.put(Uri.parse('$baseUrl/api/orders/$id/complete'));
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<List<dynamic>> getUsers() async {
    final res = await http.get(Uri.parse('$baseUrl/api/users'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Қолданушыларды жүктеу мүмкін болмады');
  }
}
