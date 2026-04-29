import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../application/cubit/sync_cubit.dart';
import '../../application/cubit/sync_state.dart';
import '../../domain/entities/sync_operation.dart';
import '../widgets/sync_operation_card.dart';
import '../widgets/sync_summary_card.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  final _scrollController = ScrollController();
  String? _lastActiveSyncId;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<SyncOperation> _sorted(List<SyncOperation> ops) {
    const order = {'syncing': 0, 'pending': 1, 'failed': 2, 'synced': 3};
    return [...ops]..sort(
        (a, b) => (order[a.status] ?? 4).compareTo(order[b.status] ?? 4),
      );
  }

  void _scrollToTopIfNewSyncing(List<SyncOperation> ops) {
    final syncing = ops.where((o) => o.status == 'syncing').firstOrNull;
    if (syncing == null) {
      _lastActiveSyncId = null;
      return;
    }
    if (syncing.id != _lastActiveSyncId) {
      _lastActiveSyncId = syncing.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<SyncCubit, SyncState>(
          listenWhen: (_, current) =>
              current is SyncSyncing || current is SyncLoaded,
          listener: (context, state) {
            final ops = switch (state) {
              SyncLoaded(operations: final o) => o,
              SyncSyncing(operations: final o) => o,
              _ => <SyncOperation>[],
            };
            _scrollToTopIfNewSyncing(ops);
          },
          builder: (context, state) {
            final isSyncing = state is SyncSyncing;
            final operations = switch (state) {
              SyncLoaded(operations: final ops) => ops,
              SyncSyncing(operations: final ops) => ops,
              _ => null,
            };
            final summary = switch (state) {
              SyncLoaded(summary: final s) => s,
              SyncSyncing(summary: final s) => s,
              _ => null,
            };
            final sorted = operations != null ? _sorted(operations) : null;
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cola de Sincronización',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Gestiona y sincroniza tus operaciones pendientes.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Modular.to.pushNamed(AppRoutes.bitacora),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDark,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.history_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (summary != null) SyncSummaryCard(summary: summary),
                        const SizedBox(height: 16),
                        AppPrimaryButton(
                          label: isSyncing
                              ? 'Sincronizando...'
                              : 'Sincronizar ahora',
                          onPressed: isSyncing
                              ? null
                              : () =>
                                  BlocProvider.of<SyncCubit>(context).sync(),
                          isLoading: isSyncing,
                        ),
                        const SizedBox(height: 20),
                        if (sorted != null && sorted.isNotEmpty)
                          const Text(
                            'Operaciones',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                if (state is SyncLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryDark),
                    ),
                  )
                else if (sorted != null && sorted.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 52, color: AppColors.statusSynced),
                          SizedBox(height: 12),
                          Text(
                            'Todo sincronizado',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'No hay operaciones pendientes en la cola.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (sorted != null)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    sliver: SliverList.builder(
                      itemCount: sorted.length,
                      itemBuilder: (context, index) {
                        final op = sorted[index];
                        return _AnimatedItem(
                          itemKey: '${op.id}_${op.status}',
                          index: index,
                          child: SyncOperationCard(
                            key: ValueKey(op.id),
                            operation: op,
                            onRetry: op.status == 'failed' && !isSyncing
                                ? () => BlocProvider.of<SyncCubit>(context)
                                    .retrySingle(op.id)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedItem extends StatelessWidget {
  final String itemKey;
  final int index;
  final Widget child;

  const _AnimatedItem({
    required this.itemKey,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(itemKey),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 320 + index * 40),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
