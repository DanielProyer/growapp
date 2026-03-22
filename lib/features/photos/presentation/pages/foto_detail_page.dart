import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/foto.dart';

/// Vollbild-Ansicht für Fotos mit PageView und Pinch-to-Zoom
class FotoDetailPage extends StatefulWidget {
  final List<Foto> fotos;
  final int startIndex;

  const FotoDetailPage({
    super.key,
    required this.fotos,
    required this.startIndex,
  });

  @override
  State<FotoDetailPage> createState() => _FotoDetailPageState();
}

class _FotoDetailPageState extends State<FotoDetailPage> {
  late final PageController _controller;
  late int _aktuellerIndex;

  @override
  void initState() {
    super.initState();
    _aktuellerIndex = widget.startIndex;
    _controller = PageController(initialPage: widget.startIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foto = widget.fotos[_aktuellerIndex];
    final datum = foto.aufgenommenAm ?? foto.erstelltAm;
    final df = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (foto.beschreibung != null && foto.beschreibung!.isNotEmpty)
              Text(
                foto.beschreibung!,
                style: const TextStyle(fontSize: 16),
              ),
            Text(
              df.format(datum),
              style: TextStyle(
                fontSize: foto.beschreibung != null ? 12 : 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          if (widget.fotos.length > 1)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_aktuellerIndex + 1} / ${widget.fotos.length}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.fotos.length,
        onPageChanged: (index) => setState(() => _aktuellerIndex = index),
        itemBuilder: (context, index) {
          final f = widget.fotos[index];
          if (f.bilderUrl == null) {
            return const Center(
              child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
            );
          }
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: f.bilderUrl!,
                fit: BoxFit.contain,
                placeholder: (_, _) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (_, _, _) => const Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
