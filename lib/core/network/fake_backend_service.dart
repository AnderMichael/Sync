import 'dart:math';

class FakeBackendService {
  final Random _random = Random();

  // Operations condemned to always fail (decided on first contact)
  final Set<String> _doomedOperations = {};

  Future<void> syncOperation(String operationId) async {
    await Future.delayed(Duration(milliseconds: 400 + _random.nextInt(800)));

    if (!_doomedOperations.contains(operationId)) {
      if (_random.nextDouble() < 0.20) {
        _doomedOperations.add(operationId);
      }
    }

    if (_doomedOperations.contains(operationId)) {
      throw Exception('Operación rechazada por el servidor [ERR_FATAL]');
    }

    if (_random.nextDouble() < 0.3) {
      throw Exception('Error de red simulado');
    }
  }
}
