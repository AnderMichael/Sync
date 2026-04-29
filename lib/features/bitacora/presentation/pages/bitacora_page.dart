import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/cubit/bitacora_cubit.dart';
import '../../application/cubit/bitacora_state.dart';
import '../widgets/bitacora_entry_card.dart';

class BitacoraPage extends StatelessWidget {
  const BitacoraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<BitacoraCubit, BitacoraState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bitácora',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Historial de operaciones sincronizadas.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (state is BitacoraLoaded && state.entries.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.statusSynced.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_outline,
                                    size: 14, color: AppColors.statusSynced),
                                const SizedBox(width: 6),
                                Text(
                                  '${state.entries.length} '
                                  '${state.entries.length == 1 ? 'registro' : 'registros'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.statusSynced,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (state is BitacoraLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryDark),
                    ),
                  )
                else if (state is BitacoraError)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: AppColors.statusFailed),
                      ),
                    ),
                  )
                else if (state is BitacoraLoaded && state.entries.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_outlined,
                              size: 52, color: AppColors.textMuted),
                          SizedBox(height: 12),
                          Text(
                            'Sin registros aún',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Las operaciones sincronizadas aparecerán aquí.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state is BitacoraLoaded)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    sliver: SliverList.builder(
                      itemCount: state.entries.length,
                      itemBuilder: (context, index) => BitacoraEntryCard(
                        key: ValueKey(state.entries[index].id),
                        entry: state.entries[index],
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
