import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const SharedAppBar({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Read auth status from the provider.
    final isLoggedIn = Provider.of<AuthProvider>(context).isLoggedIn;
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.home),
          tooltip: 'Go to Dashboard',
          onPressed: () {
            if (isLoggedIn) {
              Navigator.pushNamed(context, '/dashboard');
            } else {
              Navigator.pushNamed(context, '/login');
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Go to Search',
          onPressed: () {
            Navigator.pushNamed(context, '/search');
          },
        ),
        IconButton(
          icon: const Icon(Icons.qr_code),
          tooltip: 'Go to QR Scanner',
          onPressed: () {
            Navigator.pushNamed(context, '/qrScan');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
