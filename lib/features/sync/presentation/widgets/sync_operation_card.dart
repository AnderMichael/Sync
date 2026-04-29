import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../domain/entities/sync_operation.dart';

class SyncOperationCard extends StatefulWidget {
  final SyncOperation operation;
  final VoidCallback? onRetry;

  const SyncOperationCard({super.key, required this.operation, this.onRetry});

  @override
  State<SyncOperationCard> createState() => _SyncOperationCardState();
}

class _SyncOperationCardState extends State<SyncOperationCard> {
  static const _maxAttempts = 3;
  late int _prevAttempts;

  @override
  void initState() {
    super.initState();
    _prevAttempts = widget.operation.attempts;
  }

  @override
  void didUpdateWidget(SyncOperationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.operation.attempts != widget.operation.attempts) {
      setState(() => _prevAttempts = oldWidget.operation.attempts);
    }
  }

  int get _remaining =>
      (_maxAttempts - widget.operation.attempts).clamp(0, _maxAttempts);
  int get _prevRemaining =>
      (_maxAttempts - _prevAttempts).clamp(0, _maxAttempts);

  @override
  Widget build(BuildContext context) {
    final op = widget.operation;
    final isCreate = op.operationType == 'create';
    final isSyncing = op.status == 'syncing';
    final isFailed = op.status == 'failed';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
        border: isSyncing
            ? Border.all(color: AppColors.accentLime.withAlpha(120), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isSyncing ? 12 : 6),
            blurRadius: isSyncing ? 14 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  op.managementTitle ?? op.localId,
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
                    AppStatusBadge(status: op.status),
                  ],
                ),
              ],
            ),
          ),

          // ── Body (condicional) ───────────────────────────────
          if (isSyncing)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: _CountdownWidget(
                remaining: _remaining,
                prevRemaining: _prevRemaining,
                maxAttempts: _maxAttempts,
              ),
            )
          else if (isFailed && op.lastError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline,
                      size: 13, color: AppColors.statusFailed),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      op.lastError!,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.statusFailed),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // ── Footer ──────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF7F8FA),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    // UUID
                    const Icon(Icons.fingerprint,
                        size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      op.localId.substring(0, 8).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 1.0,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Spacer(),
                    // Intentos
                    if (op.attempts > 0) ...[
                      const Icon(Icons.refresh,
                          size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${op.attempts} intento${op.attempts != 1 ? 's' : ''}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
                if (isFailed && widget.onRetry != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: OutlinedButton.icon(
                      onPressed: widget.onRetry,
                      icon: const Icon(Icons.refresh,
                          size: 13, color: AppColors.primaryDark),
                      label: const Text(
                        'Reintentar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: const BorderSide(color: AppColors.primaryDark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownWidget extends StatelessWidget {
  final int remaining;
  final int prevRemaining;
  final int maxAttempts;

  const _CountdownWidget({
    required this.remaining,
    required this.prevRemaining,
    required this.maxAttempts,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TweenAnimationBuilder<double>(
          key: ValueKey(remaining),
          tween: Tween(
            begin: prevRemaining / maxAttempts.toDouble(),
            end: remaining / maxAttempts.toDouble(),
          ),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          builder: (context, value, _) {
            return SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    strokeWidth: 3.5,
                    backgroundColor: Colors.grey.withAlpha(30),
                    valueColor: AlwaysStoppedAnimation(
                      remaining > 1
                          ? AppColors.accentLime
                          : remaining == 1
                              ? Colors.orange
                              : AppColors.statusFailed,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: Tween<double>(begin: 0.4, end: 1.0).animate(
                        CurvedAnimation(
                            parent: animation, curve: Curves.elasticOut),
                      ),
                      child:
                          FadeTransition(opacity: animation, child: child),
                    ),
                    child: Text(
                      '$remaining',
                      key: ValueKey(remaining),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: remaining > 1
                            ? AppColors.primaryDark
                            : remaining == 1
                                ? Colors.orange
                                : AppColors.statusFailed,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sincronizando...',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  remaining > 0
                      ? '$remaining ${remaining == 1 ? 'intento restante' : 'intentos restantes'}'
                      : 'Último intento...',
                  key: ValueKey(remaining),
                  style: TextStyle(
                    fontSize: 11,
                    color: remaining > 1
                        ? AppColors.textMuted
                        : remaining == 1
                            ? Colors.orange
                            : AppColors.statusFailed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
