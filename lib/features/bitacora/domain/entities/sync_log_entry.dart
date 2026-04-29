import 'package:equatable/equatable.dart';

class SyncLogEntry extends Equatable {
  final String id;
  final String localId;
  final String operationType;
  final String status;
  final Map<String, dynamic> gestionVersion;
  final int attempts;
  final String? errorMessage;
  final DateTime occurredAt;

  const SyncLogEntry({
    required this.id,
    required this.localId,
    required this.operationType,
    required this.status,
    required this.gestionVersion,
    required this.attempts,
    this.errorMessage,
    required this.occurredAt,
  });

  String? get managementTitle => gestionVersion['title'] as String?;

  @override
  List<Object?> get props =>
      [id, localId, operationType, status, gestionVersion, attempts, errorMessage, occurredAt];
}
