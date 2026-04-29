import 'package:equatable/equatable.dart';

class SyncSummary extends Equatable {
  final int pending;
  final int synced;
  final int failed;
  final DateTime? lastSync;

  const SyncSummary({
    required this.pending,
    required this.synced,
    required this.failed,
    this.lastSync,
  });

  factory SyncSummary.empty() =>
      const SyncSummary(pending: 0, synced: 0, failed: 0);

  @override
  List<Object?> get props => [pending, synced, failed, lastSync];
}
