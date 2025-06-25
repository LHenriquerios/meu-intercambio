import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meu_intercambio_prototype/models/offer_model.dart';

class OfferService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Criar nova oferta
  Future<void> createOffer(Offer offer) async {
    await _firestore.collection('offers').add(offer.toMap());
  }

  // Obter todas as ofertas
  Stream<List<Offer>> getAllOffers() {
    return _firestore.collection('offers').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Offer.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Obter ofertas de um usuário específico
  Stream<List<Offer>> getUserOffers(String userId) {
    return _firestore
        .collection('offers')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Offer.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Atualizar oferta
  Future<void> updateOffer(String offerId, Offer offer) async {
    await _firestore.collection('offers').doc(offerId).update(offer.toMap());
  }

  // Deletar oferta
  Future<void> deleteOffer(String offerId) async {
    await _firestore.collection('offers').doc(offerId).delete();
  }

  Future<void> acceptOffer(String offerId, String userId, String acceptorUsername) async {
    await _firestore.collection('offers').doc(offerId).update({
      'acceptedByUserId': userId,
      'acceptedByUsername': acceptorUsername,
    });
  }
}