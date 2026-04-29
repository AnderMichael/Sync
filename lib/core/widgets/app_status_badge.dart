import 'package:flutter/material.dart';
import 'package:sync_app/core/theme/app_colors.dart';

class AppStatusBadge extends StatelessWidget {
  final String status;

  const AppStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'synced' => ('Sincronizado', AppColors.statusSynced),
      'syncing' => ('Sincronizando', AppColors.statusSyncing),
      'failed' => ('Fallido', AppColors.statusFailed),
      _ => ('Pendiente', AppColors.statusPending),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
