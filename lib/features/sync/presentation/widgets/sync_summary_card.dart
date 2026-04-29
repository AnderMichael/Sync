import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/sync_summary.dart';

class SyncSummaryCard extends StatelessWidget {
  final SyncSummary summary;

  const SyncSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de Sincronización',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(
                label: 'Pendientes',
                count: summary.pending,
                color: AppColors.statusPending,
              ),
              const SizedBox(width: 10),
              _StatChip(
                label: 'Sincronizados',
                count: summary.synced,
                color: AppColors.statusSynced,
              ),
              const SizedBox(width: 10),
              _StatChip(
                label: 'Fallidos',
                count: summary.failed,
                color: AppColors.statusFailed,
              ),
            ],
          ),
          if (summary.lastSync != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 13, color: Colors.white54),
                const SizedBox(width: 6),
                Text(
                  'Última sync: ${DateFormat('dd/MM/yyyy HH:mm').format(summary.lastSync!)}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
