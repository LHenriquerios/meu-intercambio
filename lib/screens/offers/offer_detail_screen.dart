import 'package:flutter/material.dart';
import '../../models/offer_model.dart';
import '../../services/offer_service.dart';
import '../../services/auth_service.dart';

class OfferDetailScreen extends StatelessWidget {
  final Offer offer;
  final String currentUserId;

  const OfferDetailScreen({
    super.key,
    required this.offer,
    required this.currentUserId,
  });

  // --- NOVA FUNÇÃO AUXILIAR PARA A MENSAGEM ---
  // Deixei essa função aqui em cima para fácil referência.
  // Ela determina qual mensagem de "aceito" mostrar.
  String _getAcceptedMessage() {
    final bool isMyOffer = offer.userId == currentUserId;
    final bool iAmTheAcceptor = offer.acceptedByUserId == currentUserId;

    if (iAmTheAcceptor) {
      return 'VOCÊ ACEITOU ESTE PLANTÃO';
    }

    if (isMyOffer) {
      // Se a oferta é minha, mostra quem aceitou.
      return 'Plantão aceito por: ${offer.acceptedByUsername ?? 'colega'}';
    }

    // Se a oferta não é minha e não fui eu que aceitei, mas ela está aceita.
    return 'PLANTÃO JÁ ACEITO POR OUTRO COLEGA';
  }


  @override
  Widget build(BuildContext context) {
    final isMyOffer = offer.userId == currentUserId;
    final isAccepted = offer.isAccepted;
    final canAccept = !isMyOffer && !isAccepted;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Oferta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Nenhuma alteração aqui ---
            Text('Data: ${offer.date}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Horário: ${offer.time}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Valor: R\$ ${offer.value.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            if (offer.notes != null && offer.notes!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Observações:', style: TextStyle(fontSize: 18)),
                  Text(offer.notes!, style: const TextStyle(fontSize: 16)),
                ],
              ),
            const Divider(height: 32),
            const Text('Ofertante:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Nome de guerra: ${offer.username}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Instituição: ${offer.institution}', style: const TextStyle(fontSize: 16)),
            
            const Spacer(),

            // --- LÓGICA DE EXIBIÇÃO CORRIGIDA ---
            if (isAccepted)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded( // Adicionado para evitar overflow de texto
                      child: Text(
                        _getAcceptedMessage(), // Chamando a nova função
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

            // --- LÓGICA DO BOTÃO "ACEITAR" CORRIGIDA ---
            if (canAccept)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    try {
                      // 1. Obter os dados do usuário atual (incluindo o nome de guerra)
                      final authService = AuthService();
                      final userData = await authService.getCurrentUserData();
                      
                      if (userData == null || userData['nomeDeGuerra'] == null) {
                        throw Exception('Não foi possível obter os dados do seu usuário para confirmar.');
                      }
                      final acceptorUsername = userData['nomeDeGuerra'];

                      // 2. Aceitar a oferta passando os 3 argumentos corretos
                      final offerService = OfferService();
                      await offerService.acceptOffer(offer.id, currentUserId, acceptorUsername);
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Plantão aceito com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context, true); // Retorna true para a tela anterior saber que precisa atualizar a lista
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao aceitar plantão: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Aceitar Plantão',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

            if (isMyOffer && !isAccepted)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Esta é sua oferta - aguardando aceitação',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
