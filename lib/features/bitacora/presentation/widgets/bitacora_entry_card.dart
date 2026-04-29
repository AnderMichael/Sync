import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/sync_log_entry.dart';

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
          // ── Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                      color:
                          isCreate ? const Color(0xFF5A7A00) : Colors.blue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.managementTitle ?? entry.localId,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          ),
          // ── Meta fields ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                _MetaChip(
                  icon: Icons.access_time_outlined,
                  label: DateFormat('dd/MM/yy HH:mm:ss')
                      .format(entry.occurredAt),
                ),
                const SizedBox(width: 8),
                _MetaChip(
                  icon: Icons.refresh,
                  label: '${entry.attempts} intento${entry.attempts != 1 ? 's' : ''}',
                ),
              ],
            ),
          ),
          if (entry.errorMessage != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline,
                      size: 13, color: AppColors.statusFailed),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      entry.errorMessage!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.statusFailed,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // ── Gestión version snapshot ─────────────────────────
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3F5),
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
                _VersionField(
                    label: 'Título', value: v['title']?.toString() ?? '—'),
                _VersionField(
                    label: 'Descripción',
                    value: v['description']?.toString() ?? '—'),
                _VersionField(
                    label: 'Monto',
                    value: v['amount'] != null
                        ? 'S/ ${(v['amount'] as num).toStringAsFixed(2)}'
                        : '—'),
                _VersionField(
                    label: 'Fecha',
                    value: v['date'] != null
                        ? DateFormat('dd/MM/yyyy')
                            .format(DateTime.parse(v['date'] as String))
                        : '—'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.textMuted),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _VersionField extends StatelessWidget {
  final String label;
  final String value;

  const _VersionField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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
