import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'pages/dashboard_page.dart';
import 'pages/search_page.dart';
import 'pages/qr_scan_page.dart';
import 'pages/qr_generate_page.dart';
import 'pages/cubit/qr_scan_cubit.dart';
import 'pages/cubit/qr_generate_cubit.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        // Provide QrScanCubit for scanning
        BlocProvider<QrScanCubit>(
          create: (_) => QrScanCubit(),
        ),
        // Provide QrGenerateCubit for generating
        BlocProvider<QrGenerateCubit>(
          create: (_) => QrGenerateCubit(),
        ),
        // ... add other cubits here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adversarial Apps',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DashboardPage(),
      routes: {
        '/dashboard': (context) => const DashboardPage(),
        '/search': (context) => const SearchPage(),
        '/qrScan': (context) => const QrScanPage(),
        '/qrGenerate': (context) => const QrGeneratePage(),
      },
    );
  }
}
