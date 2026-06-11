import 'package:connectcrm/features/clients/data/client.dart';
import 'package:connectcrm/features/funnel/sales_funnel_metrics.dart';
import 'package:connectcrm/features/reminders/reminder_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Funil de vendas', () {
    test('conta clientes por status', () {
      final clients = [
        _client(id: '1', status: 'Novo Lead'),
        _client(id: '2', status: 'Negociação'),
        _client(id: '3', status: 'Fechado'),
        _client(id: '4', status: 'Fechado'),
      ];

      expect(countClientsByStatus(clients, 'Novo Lead'), 1);
      expect(countClientsByStatus(clients, 'Negociação'), 1);
      expect(countClientsByStatus(clients, 'Fechado'), 2);
    });

    test('calcula taxa de conversao com clientes fechados', () {
      final clients = [
        _client(id: '1', status: 'Novo Lead'),
        _client(id: '2', status: 'Negociação'),
        _client(id: '3', status: 'Fechado'),
        _client(id: '4', status: 'Fechado'),
      ];

      expect(calculateConversionRate(clients), 50);
    });

    test('retorna conversao zero quando nao existem clientes', () {
      expect(calculateConversionRate([]), 0);
    });

    test('filtra clientes por etapa do funil', () {
      final clients = [
        _client(id: '1', name: 'Ana', status: 'Novo Lead'),
        _client(id: '2', name: 'Bruno', status: 'Fechado'),
        _client(id: '3', name: 'Carla', status: 'Fechado'),
      ];

      final closedClients = clientsByStatus(clients, 'Fechado');

      expect(closedClients.map((client) => client.name), ['Bruno', 'Carla']);
    });
  });

  group('Lembretes', () {
    test('lista apenas clientes com proximo follow-up', () {
      final clients = [
        _client(id: '1', nextFollowUp: DateTime(2026, 6, 20)),
        _client(id: '2'),
        _client(id: '3', nextFollowUp: DateTime(2026, 6, 18)),
      ];

      final reminders = clientsWithFollowUps(clients);

      expect(reminders.map((client) => client.id), ['3', '1']);
    });

    test('identifica follow-up atrasado comparando apenas a data', () {
      final now = DateTime(2026, 6, 11, 18, 30);

      expect(
        isFollowUpOverdue(DateTime(2026, 6, 10, 23, 59), now: now),
        isTrue,
      );
      expect(isFollowUpOverdue(DateTime(2026, 6, 11, 8), now: now), isFalse);
      expect(isFollowUpOverdue(DateTime(2026, 6, 12), now: now), isFalse);
    });
  });

  group('Modelo Client', () {
    test('copyWith altera apenas os campos enviados', () {
      final client = _client(
        id: '1',
        name: 'Maria',
        status: 'Novo Lead',
        nextFollowUp: DateTime(2026, 6, 20),
      );

      final updatedClient = client.copyWith(status: 'Fechado');

      expect(updatedClient.name, 'Maria');
      expect(updatedClient.status, 'Fechado');
      expect(updatedClient.nextFollowUp, DateTime(2026, 6, 20));
    });

    test('copyWith limpa o follow-up quando solicitado', () {
      final client = _client(id: '1', nextFollowUp: DateTime(2026, 6, 20));

      final updatedClient = client.copyWith(clearNextFollowUp: true);

      expect(updatedClient.nextFollowUp, isNull);
    });
  });
}

Client _client({
  required String id,
  String name = 'Cliente Teste',
  String company = 'Empresa Teste',
  String phone = '11999999999',
  String email = 'cliente@teste.com',
  String status = 'Novo Lead',
  DateTime? nextFollowUp,
  String notes = 'Observacao de teste',
}) {
  return Client(
    id: id,
    name: name,
    company: company,
    phone: phone,
    email: email,
    status: status,
    nextFollowUp: nextFollowUp,
    notes: notes,
  );
}
