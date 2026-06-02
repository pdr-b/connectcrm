import 'package:cloud_firestore/cloud_firestore.dart';

import 'client.dart';
import 'client_interaction.dart';

class ClientsRepository {
  ClientsRepository({required this.userId, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final String userId;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(userId).collection('clients');

  CollectionReference<Map<String, dynamic>> _interactions(String clientId) =>
      _collection.doc(clientId).collection('interactions');

  Stream<List<Client>> watchClients() {
    return _collection.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      final clients = snapshot.docs.map(Client.fromDocument).toList();
      clients.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return clients;
    });
  }

  Future<void> addClient(Client client) {
    return _collection.add(client.toCreateMap());
  }

  Future<void> updateClient(Client client) {
    return _collection.doc(client.id).update(client.toUpdateMap());
  }

  Stream<List<ClientInteraction>> watchInteractions(String clientId) async* {
    try {
      await for (final snapshot in _interactions(
        clientId,
      ).orderBy('createdAt', descending: true).snapshots()) {
        yield snapshot.docs.map(ClientInteraction.fromDocument).toList();
      }
    } catch (_) {
      yield* _collection.doc(clientId).snapshots().map((snapshot) {
        final data = snapshot.data() ?? {};
        final rawInteractions = data['interactionLog'];
        if (rawInteractions is! List) return const <ClientInteraction>[];

        final interactions = rawInteractions
            .whereType<Map<String, dynamic>>()
            .map(ClientInteraction.fromMap)
            .toList();

        interactions.sort((a, b) {
          final first = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final second = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return second.compareTo(first);
        });

        return interactions;
      });
    }
  }

  Future<void> addInteraction(
    String clientId,
    ClientInteraction interaction,
  ) async {
    try {
      await _interactions(clientId).add(interaction.toCreateMap());
    } catch (_) {
      await _collection.doc(clientId).update({
        'interactionLog': FieldValue.arrayUnion([interaction.toEmbeddedMap()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> deleteInteraction(String clientId, String interactionId) async {
    try {
      await _interactions(clientId).doc(interactionId).delete();
    } catch (_) {
      final clientDocument = await _collection.doc(clientId).get();
      final data = clientDocument.data() ?? {};
      final rawInteractions = data['interactionLog'];
      if (rawInteractions is! List) return;

      final updatedInteractions = rawInteractions.where((interaction) {
        if (interaction is! Map<String, dynamic>) return true;
        return interaction['id'] != interactionId;
      }).toList();

      await _collection.doc(clientId).update({
        'interactionLog': updatedInteractions,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> deleteClient(String clientId) async {
    try {
      final interactions = await _interactions(clientId).get();
      final batch = _firestore.batch();

      for (final interaction in interactions.docs) {
        batch.delete(interaction.reference);
      }

      batch.delete(_collection.doc(clientId));
      await batch.commit();
    } catch (_) {
      await _collection.doc(clientId).delete();
    }
  }
}
