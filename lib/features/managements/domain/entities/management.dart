import 'package:equatable/equatable.dart';

class Management extends Equatable {
  final String localId;
  final String title;
  final String description;
  final DateTime date;
  final double amount;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Management({
    required this.localId,
    required this.title,
    required this.description,
    required this.date,
    required this.amount,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  Management copyWith({
    String? title,
    String? description,
    DateTime? date,
    double? amount,
    String? syncStatus,
    DateTime? updatedAt,
  }) {
    return Management(
      localId: localId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        localId,
        title,
        description,
        date,
        amount,
        syncStatus,
        createdAt,
        updatedAt,
      ];
}
