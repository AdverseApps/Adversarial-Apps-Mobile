import 'package:flutter/material.dart';

/// This is the component for the Nav Bar at the top of the app at all times.
class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const SharedAppBar({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Use the title passed in from constructor
      title: Text(title),
      // Common navigation icons used throughout the app
      actions: [
        IconButton(
          icon: const Icon(Icons.home),
          tooltip: 'Go to Dashboard',
          onPressed: () {
            Navigator.pushNamed(context, '/dashboard');
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

  // This sets the size of the AppBar.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
