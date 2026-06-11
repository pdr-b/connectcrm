import '../clients/data/client.dart';

int countClientsByStatus(List<Client> clients, String status) {
  return clients.where((client) => client.status == status).length;
}

int calculateConversionRate(List<Client> clients) {
  if (clients.isEmpty) return 0;
  final closedClients = countClientsByStatus(clients, 'Fechado');
  return (closedClients / clients.length * 100).round();
}

List<Client> clientsByStatus(List<Client> clients, String status) {
  return clients.where((client) => client.status == status).toList();
}
