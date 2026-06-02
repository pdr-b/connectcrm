import 'package:cloud_firestore/cloud_firestore.dart';

const interactionTypes = [
  'Contato',
  'Ligação',
  'Reunião',
  'E-mail',
  'Proposta',
];

class ClientInteraction {
  const ClientInteraction({
    required this.id,
    required this.type,
    required this.notes,
    this.createdAt,
  });

  final String id;
  final String type;
  final String notes;
  final DateTime? createdAt;

  factory ClientInteraction.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};
    final createdAt = data['createdAt'];

    return ClientInteraction(
      id: document.id,
      type: (data['type'] ?? interactionTypes.first) as String,
      notes: (data['notes'] ?? '') as String,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }

  factory ClientInteraction.fromMap(Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    return ClientInteraction(
      id: (data['id'] ?? '') as String,
      type: (data['type'] ?? interactionTypes.first) as String,
      notes: (data['notes'] ?? '') as String,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'type': type,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toEmbeddedMap() {
    return {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'type': type,
      'notes': notes,
      'createdAt': Timestamp.now(),
    };
  }
}
