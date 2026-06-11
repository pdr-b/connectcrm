import '../clients/data/client.dart';

List<Client> clientsWithFollowUps(List<Client> clients) {
  final reminders = clients
      .where((client) => client.nextFollowUp != null)
      .toList();

  reminders.sort((a, b) => a.nextFollowUp!.compareTo(b.nextFollowUp!));
  return reminders;
}

bool isFollowUpOverdue(DateTime date, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final currentDay = DateTime(today.year, today.month, today.day);
  final followUpDay = DateTime(date.year, date.month, date.day);
  return followUpDay.isBefore(currentDay);
}
