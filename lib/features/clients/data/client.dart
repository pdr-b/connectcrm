import 'package:cloud_firestore/cloud_firestore.dart';

const clientStatuses = ['Novo Lead', 'Negociação', 'Fechado'];

class Client {
  const Client({
    required this.id,
    required this.name,
    required this.company,
    required this.phone,
    required this.email,
    required this.status,
    required this.nextFollowUp,
    required this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String company;
  final String phone;
  final String email;
  final String status;
  final DateTime? nextFollowUp;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Client.fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? {};
    return Client(
      id: document.id,
      name: (data['name'] ?? '') as String,
      company: (data['company'] ?? '') as String,
      phone: (data['phone'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      status: (data['status'] ?? clientStatuses.first) as String,
      nextFollowUp: _readDate(data['nextFollowUp']),
      notes: (data['notes'] ?? '') as String,
      createdAt: _readDate(data['createdAt']),
      updatedAt: _readDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'name': name,
      'company': company,
      'phone': phone,
      'email': email,
      'status': status,
      'nextFollowUp': nextFollowUp == null
          ? null
          : Timestamp.fromDate(nextFollowUp!),
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'company': company,
      'phone': phone,
      'email': email,
      'status': status,
      'nextFollowUp': nextFollowUp == null
          ? null
          : Timestamp.fromDate(nextFollowUp!),
      'notes': notes,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Client copyWith({
    String? id,
    String? name,
    String? company,
    String? phone,
    String? email,
    String? status,
    DateTime? nextFollowUp,
    bool clearNextFollowUp = false,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      status: status ?? this.status,
      nextFollowUp: clearNextFollowUp
          ? null
          : nextFollowUp ?? this.nextFollowUp,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _readDate(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }
}
