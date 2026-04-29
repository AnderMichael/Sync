import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_app/core/theme/app_colors.dart';
import 'package:sync_app/features/bitacora/application/cubit/bitacora_cubit.dart';
import 'package:sync_app/features/bitacora/application/cubit/bitacora_state.dart';
import 'package:sync_app/features/bitacora/presentation/widgets/bitacora_entry_card.dart';

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
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDark,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.arrow_back,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                'Bitácora',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            if (state is BitacoraLoaded &&
                                state.entries.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F3F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${state.entries.length}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Padding(
                          padding: EdgeInsets.only(left: 54),
                          child: Text(
                            'Historial de éxitos y fallos por versión.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
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
                      child: Text(state.message,
                          style: const TextStyle(
                              color: AppColors.statusFailed)),
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
                            'Aquí aparecerán los intentos de sincronización.',
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
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
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
