import 'package:flutter_test/flutter_test.dart';

extension CustomWaits on WidgetTester {
  Future<void> waitUntilDisappear(
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
    Duration pumpInterval = const Duration(milliseconds: 100),
  }) async {
    bool isPresent = false;
    final endTime = DateTime.now().add(timeout);

    do {
      await pump(pumpInterval);
      isPresent = finder.evaluate().isNotEmpty;
    } while (isPresent && DateTime.now().isBefore(endTime));

    if (finder.evaluate().isNotEmpty) {
      throw Exception('Elemento no desapareció después de $timeout');
    }
  }
}