// offer_model.dart (VERSÃO CORRIGIDA E COMPLETA)

class Offer {
  final String id;
  final String date;
  final String entryTime;
  final String exitTime;
  final double value;
  final String? notes;
  final String username; // Nome de quem criou
  final String institution;
  final String userId; // ID do usuário que criou a oferta
  final String? acceptedByUserId; // ID de quem aceitou
  final String? acceptedByUsername; // Nome de quem aceitou

  Offer({
    required this.id,
    required this.date,
    required this.entryTime,
    required this.exitTime,
    required this.value,
    this.notes,
    required this.username,
    required this.institution,
    required this.userId,
    this.acceptedByUserId,
    this.acceptedByUsername,
  });

  // Converter para Map (para Firebase)
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'entryTime': entryTime,
      'exitTime': exitTime,
      'value': value,
      'notes': notes,
      'username': username,
      'institution': institution,
      'userId': userId,
      'acceptedByUserId': acceptedByUserId,
      'acceptedByUsername': acceptedByUsername, // <-- ADICIONE ESTA LINHA
    };
  }

  // Criar a partir de Map (do Firebase)
  factory Offer.fromMap(Map<String, dynamic> map, String id) {
    return Offer(
      id: id,
      date: map['date'] ?? '',
      entryTime: map['entryTime'] ?? '',
      exitTime: map['exitTime'] ?? '',
      value: (map['value'] as num).toDouble(),
      notes: map['notes'],
      username: map['username'] ?? '',
      institution: map['institution'] ?? '',
      userId: map['userId'] ?? '',
      acceptedByUserId: map['acceptedByUserId'],
      acceptedByUsername: map['acceptedByUsername'], // <-- ADICIONE ESTA LINHA
    );
  }

  // Getters (Estes já estão perfeitos!)
  String get time => '$entryTime - $exitTime';
  bool get isAccepted => acceptedByUserId != null;
}