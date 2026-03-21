import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StrainFormPage extends ConsumerWidget {
  const StrainFormPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neue Sorte'),
      ),
      body: const Center(
        child: Text('Formular zum Erstellen einer neuen Sorte.'),
      ),
    );
  }
}
