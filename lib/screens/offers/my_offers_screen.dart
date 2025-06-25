import 'package:flutter/material.dart';
import 'package:meu_intercambio_prototype/models/offer_model.dart';
import 'package:meu_intercambio_prototype/widgets/offer_card.dart';
import 'package:meu_intercambio_prototype/screens/offers/new_offer_screen.dart';
import 'package:meu_intercambio_prototype/services/offer_service.dart';
import 'package:meu_intercambio_prototype/services/auth_service.dart';

class MyOffersScreen extends StatelessWidget {

  const MyOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OfferService offerService = OfferService();
    final AuthService authService = AuthService();
    return StreamBuilder<String?>(
      stream: authService.userIdStream,
      builder: (context, userIdSnapshot) {
        if (!userIdSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userId = userIdSnapshot.data!;

        return StreamBuilder<List<Offer>>(
          stream: offerService.getUserOffers(userId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final myOffers = snapshot.data ?? [];

            return ListView.builder(
              itemCount: myOffers.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(myOffers[index].id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmar'),
                          content: const Text('Deseja realmente remover esta oferta?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Remover'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewOfferScreen(
                            offerToEdit: myOffers[index],
                          ),
                        ),
                      );
                      return false;
                    }
                  },
                  onDismissed: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      await offerService.deleteOffer(myOffers[index].id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Oferta removida')),
                      );
                    }
                  },
                  child: OfferCard(offer: myOffers[index], currentUserId: userId,),
                );
              },
            );
          },
        );
      },
    );
  }
}