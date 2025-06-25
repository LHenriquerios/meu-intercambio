import 'package:flutter/material.dart';
import 'package:meu_intercambio_prototype/models/offer_model.dart';

class OfferCard extends StatelessWidget {
  final Offer offer;
  final String currentUserId;

  const OfferCard({
    super.key,
    required this.offer,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isAccepted = offer.isAccepted;
    final bool iAmTheAcceptor = offer.acceptedByUserId == currentUserId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isAccepted
              ? (iAmTheAcceptor ? Colors.green[700]! : Colors.amber)
              : const Color(0x339E9E9E),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  offer.date,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'R\$ ${offer.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isAccepted ? Colors.green : Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              offer.time,
              style: const TextStyle(fontSize: 16),
            ),
            if (offer.notes != null && offer.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                offer.notes!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  offer.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (isAccepted)
                  Tooltip(
                    message: iAmTheAcceptor
                        ? 'Você aceitou esta oferta'
                        : 'Oferta já aceita por outro usuário',
                    child: Chip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (iAmTheAcceptor)
                            const Icon(Icons.check_circle, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            iAmTheAcceptor ? 'VOCÊ ACEITOU' : 'ACEITO',
                            style: TextStyle(
                              color: iAmTheAcceptor ? Colors.white : Colors.grey[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: iAmTheAcceptor 
                          ? Colors.green[700] 
                          : Colors.amber[300],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  )
                else
                  Text(
                    offer.institution,
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}