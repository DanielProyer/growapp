import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/foto.dart';

/// Einzelne Foto-Karte im Grid
class FotoKarte extends StatelessWidget {
  final Foto foto;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const FotoKarte({
    super.key,
    required this.foto,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Bild
            if (foto.bilderUrl != null)
              CachedNetworkImage(
                imageUrl: foto.bilderUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              )
            else
              Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
              ),

            // Delete-Button
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onDelete,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ),

            // Kategorie/Beschreibung-Overlay
            if (foto.kategorie != null ||
                (foto.beschreibung != null && foto.beschreibung!.isNotEmpty))
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                  ),
                  child: Text(
                    foto.kategorie != null
                        ? foto.kategorieLabel
                        : foto.beschreibung!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
