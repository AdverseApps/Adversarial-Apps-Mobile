import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'cubit/qr_generate_cubit.dart';
import 'cubit/qr_generate_state.dart';

class QrGeneratePage extends StatelessWidget {
  const QrGeneratePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QrGenerateCubit, QrGenerateState>(
      builder: (context, state) {
        final cubit = context.read<QrGenerateCubit>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Generate a QR Code'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Enter text to generate QR code',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => cubit.updateText(value),
                ),
                const SizedBox(height: 24),
                if (state.inputText.isNotEmpty)
                  QrImageView(
                    data: state.inputText,
                    version: QrVersions.auto,
                    size: 200.0,
                  )
                else
                  const Text('Type something above to generate a QR code.'),
              ],
            ),
          ),
        );
      },
    );
  }
}
