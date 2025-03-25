import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:adrenalux_frontend_mobile/widgets/achievement_flushbar.dart';

void main() {
  testWidgets('Muestra notificación de logro con parámetros correctos', (WidgetTester tester) async {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          key: scaffoldKey,
          body: const Placeholder(),
        ),
      ),
    );

    final context = scaffoldKey.currentContext!;

    AchievementNotification.show(
      context: context,
      title: 'Nuevo Logro',
      message: 'Has ganado 100 puntos',
      durationSeconds: 5,
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.descendant(
        of: find.byType(Flushbar),
        matching: find.text('Nuevo Logro'),
      ),
      findsOneWidget,
      reason: 'No se encontró el título en el Flushbar',
    );
    
    expect(
      find.descendant(
        of: find.byType(Flushbar),
        matching: find.text('Has ganado 100 puntos'),
      ),
      findsOneWidget,
      reason: 'No se encontró el mensaje en el Flushbar',
    );

    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('El Flushbar se descarta después de la duración establecida', (WidgetTester tester) async {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          key: scaffoldKey,
          body: const Placeholder(),
        ),
      ),
    );

    final context = scaffoldKey.currentContext!;

    AchievementNotification.show(
      context: context,
      title: 'Desaparece',
      message: 'Se cierra automáticamente',
      durationSeconds: 5,
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.byType(Flushbar),
      findsOneWidget,
      reason: 'El Flushbar debería estar visible al inicio',
    );

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(
      find.byType(Flushbar),
      findsNothing,
      reason: 'El Flushbar no se descartó después de la duración establecida',
    );
  });
}