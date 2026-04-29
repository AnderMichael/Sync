import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../application/cubit/managements_cubit.dart';
import '../../application/cubit/managements_state.dart';
import '../widgets/management_card.dart';

class ManagementsPage extends StatefulWidget {
  const ManagementsPage({super.key});

  @override
  State<ManagementsPage> createState() => _ManagementsPageState();
}

class _ManagementsPageState extends State<ManagementsPage> {
  String _selectedFilter = 'all';

  static const _filters = [
    ('all', 'Todos'),
    ('synced', 'Sincronizados'),
    ('pending', 'Pendientes'),
    ('failed', 'Fallidos'),
  ];

  Widget _emptyState() {
    final (icon, title, subtitle) = switch (_selectedFilter) {
      'synced' => (
          Icons.cloud_done_outlined,
          'Sin gestiones sincronizadas',
          'Aún no hay gestiones con sincronización exitosa.',
        ),
      'pending' => (
          Icons.hourglass_empty_outlined,
          'Sin gestiones pendientes',
          'No hay gestiones esperando sincronización.',
        ),
      'failed' => (
          Icons.error_outline,
          'Sin gestiones fallidas',
          'No hay gestiones con errores de sincronización.',
        ),
      _ => (
          Icons.folder_open_outlined,
          'Sin gestiones',
          'Crea tu primera gestión con el botón de arriba.',
        ),
    };

    final iconColor = _selectedFilter == 'failed'
        ? AppColors.statusFailed
        : AppColors.textMuted;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 52, color: iconColor),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestiones Recientes',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Administra tus registros locales y sincronizados.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppPrimaryButton(
                    label: 'Nueva gestión',
                    onPressed: () =>
                        Modular.to.pushNamed('/managements/form'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter.$2),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedFilter = filter.$1);
                        BlocProvider.of<ManagementsCubit>(context)
                            .filterBy(filter.$1);
                      },
                      selectedColor: AppColors.primaryDark,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      backgroundColor: AppColors.cardWhite,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryDark
                            : AppColors.borderLight,
                      ),
                      checkmarkColor: AppColors.accentLime,
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<ManagementsCubit, ManagementsState>(
                builder: (context, state) => switch (state) {
                  ManagementsLoading() => const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryDark),
                    ),
                  ManagementsEmpty() => _emptyState(),
                  ManagementsLoaded(managements: final list) =>
                    ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final m = list[index];
                        return ManagementCard(
                          management: m,
                          onTap: () => Modular.to.pushNamed(
                            '/managements/form',
                            arguments: m.localId,
                          ),
                        );
                      },
                    ),
                  ManagementsError(message: final msg) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: AppColors.statusFailed),
                            const SizedBox(height: 12),
                            Text(
                              msg,
                              style: const TextStyle(
                                  color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
