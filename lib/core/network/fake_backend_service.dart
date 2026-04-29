import 'dart:math';

class FakeBackendService {
  final Random _random = Random();

  Future<void> syncOperation(String operationId) async {
    await Future.delayed(Duration(milliseconds: 400 + _random.nextInt(800)));
    if (_random.nextDouble() < 0.3) {
      throw Exception('Error de red simulado');
    }
  }
}
