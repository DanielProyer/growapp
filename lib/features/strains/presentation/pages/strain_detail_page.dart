import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StrainDetailPage extends ConsumerWidget {
  final String strainId;

  const StrainDetailPage({super.key, required this.strainId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sorte: $strainId'),
      ),
      body: const Center(
        child: Text('Sortendetails werden hier angezeigt.'),
      ),
    );
  }
}
