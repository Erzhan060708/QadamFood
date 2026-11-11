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
    final textTheme = GoogleFonts.interTextTheme().copyWith(
      headlineLarge: GoogleFonts.poppins(
          fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.8),
      headlineMedium: GoogleFonts.poppins(
          fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      titleLarge:
          GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
    );
    return MaterialApp(
      title: 'Qadam Food',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0A5443),
        scaffoldBackgroundColor: const Color(0xFFF8FAF7),
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFFF8FAF7),
            elevation: 0,
            titleTextStyle: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF173B30))),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A5443),
          primary: const Color(0xFF0A5443),
          secondary: const Color(0xFFFF8A00),
          surface: Colors.white,
        ),
      ),
      home: const MainScreen(),
      onGenerateRoute: (settings) {
        final match =
            RegExp(r'^/merchant/(\d+)$').firstMatch(settings.name ?? '');
        if (match != null) {
          return MaterialPageRoute(
              builder: (_) =>
                  MerchantPortalScreen(storeId: int.parse(match.group(1)!)));
        }
        return null;
      },
    );
  }
}
