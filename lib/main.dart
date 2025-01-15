import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'pages/cubit/qr_scan_cubit.dart';
import 'pages/cubit/qr_generate_cubit.dart';
import 'pages/qr_scan_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Scan Cubit
        BlocProvider(
          create: (context) => QrScanCubit(),
        ),
        // Generate Cubit
        BlocProvider(
          create: (context) => QrGenerateCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'Adversarial Apps QR Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // Start on the "Scan QR Code" page
        home: const QrScanPage(),
      ),
    );
  }
}
