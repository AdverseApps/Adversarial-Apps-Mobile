import 'package:adversarialapps/services/cik_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart'; // Add provider package
import 'pages/dashboard_page.dart';
import 'pages/search_page.dart';
import 'pages/qr_scan_page.dart';
import 'pages/qr_generate_page.dart';
import 'pages/cubit/qr_scan_cubit.dart';
import 'pages/cubit/qr_generate_cubit.dart';
import 'pages/cubit/search_cubit.dart';
import 'components/auth_provider.dart'; // Import the auth provider

void main() {
  final cikService = CikService(); // or some RemoteCikService
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<QrScanCubit>(
            create: (_) => QrScanCubit(),
          ),
          BlocProvider<QrGenerateCubit>(
            create: (_) => QrGenerateCubit(),
          ),
          BlocProvider<SearchCubit>(
            create: (_) => SearchCubit(cikService),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adversarial Apps',
      theme: ThemeData(
        // Use a dark brightness if you want text, icons, etc. to default to light colors.
        brightness: Brightness.dark,

        // Set the overall "primary" color (often used by widgets like FloatingActionButton, etc.)
        primaryColor: const Color(0xFF002759),

        // Set the scaffold’s background color (for pages’ default backgrounds).
        scaffoldBackgroundColor: const Color(0xFF121212),

        // Customize the AppBar color and text/icon colors.
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF002759), // AppBar background
          foregroundColor: Colors.white, // AppBar text/icons
          elevation: 0,
        ),

        // Override text styles if you want them all white by default
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
        ),

        // Also set default icon color to white
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      home: const DashboardPage(),
      routes: {
        '/dashboard': (context) => const DashboardPage(),
        '/search': (context) => SearchPage(),
        '/qrScan': (context) => const QrScanPage(),
        '/qrGenerate': (context) => const QrGeneratePage(),
      },
    );
  }
}
