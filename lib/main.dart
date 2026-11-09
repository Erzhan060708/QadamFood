import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_screen.dart';
import 'screens/merchant_portal_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QadamFoodApp());
}

class QadamFoodApp extends StatelessWidget {
  const QadamFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme();
    return MaterialApp(
      title: 'Qadam Food',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0A5443),
        scaffoldBackgroundColor: const Color(0xFFF5EFE6),
        textTheme: textTheme,
        appBarTheme: AppBarTheme(titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A5443),
          primary: const Color(0xFF0A5443),
        ),
      ),
      home: const MainScreen(),
      onGenerateRoute: (settings) {
        final match = RegExp(r'^/merchant/(\d+)$').firstMatch(settings.name ?? '');
        if (match != null) {
          return MaterialPageRoute(builder: (_) => MerchantPortalScreen(storeId: int.parse(match.group(1)!)));
        }
        return null;
      },
    );
  }
}
