import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../sync/domain/entities/sync_operation.dart';

class BitacoraEntryCard extends StatelessWidget {
  final SyncOperation entry;

  const BitacoraEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isCreate = entry.operationType == 'create';
    final dateStr = entry.syncedAt != null
        ? DateFormat('dd/MM/yyyy HH:mm:ss').format(entry.syncedAt!)
        : DateFormat('dd/MM/yyyy HH:mm:ss').format(entry.updatedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: title + status dot
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.managementTitle ?? entry.localId,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.statusSynced,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Fields grid
          _Field(
            icon: Icons.access_time_outlined,
            label: 'Fecha / Hora',
            value: dateStr,
          ),
          const SizedBox(height: 8),
          _Field(
            icon: isCreate ? Icons.add_circle_outline : Icons.edit_outlined,
            label: 'Tipo de operación',
            value: isCreate ? 'Creación' : 'Actualización',
          ),
          const SizedBox(height: 8),
          _Field(
            icon: Icons.check_circle_outline,
            label: 'Estado final',
            value: 'Sincronizado',
            valueColor: AppColors.statusSynced,
          ),
          if (entry.lastError != null) ...[
            const SizedBox(height: 8),
            _Field(
              icon: Icons.error_outline,
              label: 'Mensaje de error',
              value: entry.lastError!,
              valueColor: AppColors.statusFailed,
            ),
          ],
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _Field({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
