import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../application/cubit/sync_cubit.dart';
import '../../application/cubit/sync_state.dart';
import '../widgets/sync_operation_card.dart';
import '../widgets/sync_summary_card.dart';

class SyncPage extends StatelessWidget {
  const SyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<SyncCubit, SyncState>(
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
            final hasFailed =
                operations?.any((o) => o.status == 'failed') ?? false;

            return CustomScrollView(
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
                        if (summary != null)
                          SyncSummaryCard(summary: summary),
                        const SizedBox(height: 16),
                        AppPrimaryButton(
                          label: isSyncing
                              ? 'Sincronizando...'
                              : 'Sincronizar ahora',
                          onPressed: isSyncing
                              ? null
                              : () => BlocProvider.of<SyncCubit>(context).sync(),
                          isLoading: isSyncing,
                        ),
                        if (hasFailed && !isSyncing) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  BlocProvider.of<SyncCubit>(context).retryFailed(),
                              icon: const Icon(Icons.refresh,
                                  size: 16,
                                  color: AppColors.primaryDark),
                              label: const Text(
                                'Reintentar fallidos',
                                style: TextStyle(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.primaryDark),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        if (operations != null && operations.isNotEmpty)
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
                else if (operations != null && operations.isEmpty)
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
                else if (operations != null)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    sliver: SliverList.builder(
                      itemCount: operations.length,
                      itemBuilder: (context, index) =>
                          SyncOperationCard(operation: operations[index]),
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
