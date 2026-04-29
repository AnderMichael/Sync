import 'package:equatable/equatable.dart';

class SyncOperation extends Equatable {
  final String id;
  final String localId;
  final String operationType;
  final String status;
  final int attempts;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;
  final String? managementTitle;

  const SyncOperation({
    required this.id,
    required this.localId,
    required this.operationType,
    required this.status,
    required this.attempts,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
    this.managementTitle,
  });

  @override
  List<Object?> get props => [
        id,
        localId,
        operationType,
        status,
        attempts,
        lastError,
        createdAt,
        updatedAt,
        syncedAt,
        managementTitle,
      ];
}
