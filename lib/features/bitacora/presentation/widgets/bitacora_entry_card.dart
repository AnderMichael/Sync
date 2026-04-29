import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sync_app/core/theme/app_colors.dart';
import 'package:sync_app/features/bitacora/domain/entities/sync_log_entry.dart';

class BitacoraEntryCard extends StatelessWidget {
  final SyncLogEntry entry;

  const BitacoraEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isSynced = entry.status == 'synced';
    final isCreate = entry.operationType == 'create';
    final statusColor =
        isSynced ? AppColors.statusSynced : AppColors.statusFailed;
    final v = entry.gestionVersion;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.managementTitle ?? entry.localId,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isCreate
                            ? AppColors.accentLime.withAlpha(40)
                            : Colors.blue.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isCreate ? 'CREAR' : 'ACTUALIZAR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isCreate
                              ? const Color(0xFF5A7A00)
                              : Colors.blue,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isSynced ? 'ÉXITO' : 'FALLIDO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VERSIÓN DE GESTIÓN',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _VersionRow(
                    label: 'Título',
                    value: v['title']?.toString() ?? '—',
                  ),
                  _VersionRow(
                    label: 'Descripción',
                    value: v['description']?.toString() ?? '—',
                  ),
                  _VersionRow(
                    label: 'Monto',
                    value: v['amount'] != null
                        ? 'S/ ${(v['amount'] as num).toStringAsFixed(2)}'
                        : '—',
                  ),
                  _VersionRow(
                    label: 'Fecha',
                    value: v['date'] != null
                        ? DateFormat('dd/MM/yyyy')
                            .format(DateTime.parse(v['date'] as String))
                        : '—',
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),

          if (entry.errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline,
                      size: 13, color: AppColors.statusFailed),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      entry.errorMessage!,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.statusFailed),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF7F8FA),
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.fingerprint,
                    size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  entry.localId.substring(0, 8).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 1.0,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.access_time_outlined,
                    size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yy HH:mm').format(entry.occurredAt),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted),
                ),
                const Spacer(),
                const Icon(Icons.refresh,
                    size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${entry.attempts} intento${entry.attempts != 1 ? 's' : ''}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _VersionRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
