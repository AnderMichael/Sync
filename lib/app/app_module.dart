import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../core/database/app_database.dart';
import '../core/network/fake_backend_service.dart';
import '../features/managements/application/cubit/management_form_cubit.dart';
import '../features/managements/application/cubit/managements_cubit.dart';
import '../features/managements/domain/repositories/management_repository.dart';
import '../features/managements/infrastructure/repositories/management_repository_impl.dart';
import '../features/managements/presentation/pages/management_form_page.dart';
import '../features/sync/application/cubit/sync_cubit.dart';
import '../features/sync/application/services/sync_engine.dart';
import '../features/sync/domain/repositories/sync_repository.dart';
import '../features/sync/infrastructure/repositories/sync_repository_impl.dart';
import 'home_shell_page.dart';

class AppModule extends Module {
  @override
  void binds(Injector i) {
    i.addLazySingleton<AppDatabase>(AppDatabase.new);
    i.addLazySingleton<FakeBackendService>(FakeBackendService.new);

    i.addLazySingleton<ManagementRepository>(
      () => ManagementRepositoryImpl(Modular.get<AppDatabase>()),
    );
    i.addLazySingleton<SyncRepository>(
      () => SyncRepositoryImpl(Modular.get<AppDatabase>()),
    );
    i.addLazySingleton<SyncEngine>(
      () => SyncEngine(
        Modular.get<SyncRepository>(),
        Modular.get<ManagementRepository>(),
        Modular.get<FakeBackendService>(),
      ),
    );

    i.add<ManagementsCubit>(
      () => ManagementsCubit(Modular.get<ManagementRepository>()),
    );
    i.add<SyncCubit>(
      () => SyncCubit(
        Modular.get<SyncEngine>(),
        Modular.get<SyncRepository>(),
      ),
    );
    i.add<ManagementFormCubit>(
      () => ManagementFormCubit(
        Modular.get<ManagementRepository>(),
        Modular.get<SyncRepository>(),
      ),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const HomeShellPage());
    r.child(
      '/managements/form',
      child: (context) => BlocProvider(
        create: (_) => Modular.get<ManagementFormCubit>(),
        child: ManagementFormPage(
          localId: Modular.args.data as String?,
        ),
      ),
    );
  }
}
