import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                        const Text(
                          'Cola de Sincronización',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Gestiona y sincroniza tus operaciones pendientes.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
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
                            'No hay operaciones en la cola.',
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
                      itemBuilder: (context, index) => SyncOperationCard(
                        key: ValueKey(sorted[index].id),
                        operation: sorted[index],
                        onRetry: sorted[index].status == 'failed' && !isSyncing
                            ? () => BlocProvider.of<SyncCubit>(context)
                                .retrySingle(sorted[index].id)
                            : null,
                      ),
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
