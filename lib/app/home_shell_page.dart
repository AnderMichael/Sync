import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../core/widgets/app_bottom_navigation.dart';
import '../features/managements/application/cubit/managements_cubit.dart';
import '../features/managements/presentation/pages/managements_page.dart';
import '../features/sync/application/cubit/sync_cubit.dart';
import '../features/sync/presentation/pages/sync_page.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  int _currentIndex = 0;
  late final ManagementsCubit _managementsCubit;
  late final SyncCubit _syncCubit;

  @override
  void initState() {
    super.initState();
    _managementsCubit = Modular.get<ManagementsCubit>();
    _syncCubit = Modular.get<SyncCubit>();
  }

  @override
  void dispose() {
    _managementsCubit.close();
    _syncCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _managementsCubit),
        BlocProvider.value(value: _syncCubit),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [ManagementsPage(), SyncPage()],
        ),
        bottomNavigationBar: AppBottomNavigation(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}
