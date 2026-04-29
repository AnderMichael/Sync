import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../domain/entities/sync_operation.dart';

class SyncOperationCard extends StatelessWidget {
  final SyncOperation operation;

  const SyncOperationCard({super.key, required this.operation});

  @override
  Widget build(BuildContext context) {
    final isCreate = operation.operationType == 'create';

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
          Row(
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
                    color: isCreate ? const Color(0xFF5A7A00) : Colors.blue,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  operation.managementTitle ?? operation.localId,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppStatusBadge(status: operation.status),
            ],
          ),
          if (operation.attempts > 0 || operation.lastError != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.refresh, size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  'Intentos: ${operation.attempts}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
          if (operation.lastError != null) ...[
            const SizedBox(height: 4),
            Text(
              operation.lastError!,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.statusFailed,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
