import 'package:flutter/material.dart';
import 'package:meu_intercambio_prototype/models/offer_model.dart';
import 'package:meu_intercambio_prototype/screens/offers/offer_detail_screen.dart';
import 'package:meu_intercambio_prototype/widgets/offer_card.dart';
import 'package:meu_intercambio_prototype/services/offer_service.dart';
import 'package:meu_intercambio_prototype/services/auth_service.dart';

class OfferListScreen extends StatelessWidget {
  const OfferListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OfferService offerService = OfferService();
    final AuthService authService = AuthService();
    final String? currentUserId = authService.currentUserId;

    return StreamBuilder<List<Offer>>(
      stream: offerService.getAllOffers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final offers = snapshot.data ?? [];

        if (offers.isEmpty) {
          return const Center(child: Text('Nenhuma oferta disponível'));
        }

        return ListView.builder(
          itemCount: offers.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                if (currentUserId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OfferDetailScreen(
                        offer: offers[index],
                        currentUserId: currentUserId,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuário não autenticado'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: currentUserId != null
                  ? OfferCard(
                      offer: offers[index],
                      currentUserId: currentUserId,
                    )
                  : const SizedBox.shrink(), // Ou algum widget de placeholder
            );
          },
        );
      },
    );
  }
}