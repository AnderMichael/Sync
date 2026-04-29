import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/sync_log_repository.dart';
import 'bitacora_state.dart';

class BitacoraCubit extends Cubit<BitacoraState> {
  final SyncLogRepository _repository;
  StreamSubscription? _subscription;

  BitacoraCubit(this._repository) : super(const BitacoraLoading()) {
    _listen();
  }

  void _listen() {
    _subscription?.cancel();
    _subscription = _repository.watchAll().listen(
      (entries) => emit(BitacoraLoaded(entries)),
      onError: (_) =>
          emit(const BitacoraError('No se pudo cargar la bitácora.')),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
