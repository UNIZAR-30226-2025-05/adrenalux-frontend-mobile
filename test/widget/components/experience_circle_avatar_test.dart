import 'package:adrenalux_frontend_mobile/widgets/experience_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Configuración base para todos los tests
  const testImage = 'test/assets/test_avatar.png';
  const experience = 50;
  const xpMax = 100;

  // Widget wrapper para simular diferentes tamaños de pantalla
  Widget _wrapWithScreenSize(Widget child, double screenWidth) {
    return MediaQuery(
      data: MediaQueryData(size: Size(screenWidth, screenWidth)),
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  group('Pruebas básicas de ExperienceCircleAvatar', () {
    testWidgets('Renderiza los elementos principales', (tester) async {
      await tester.pumpWidget(
        _wrapWithScreenSize(
          ExperienceCircleAvatar(
            imagePath: testImage,
            experience: experience,
            xpMax: xpMax,
          ),
          400,
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Muestra el progreso correcto', (tester) async {
      await tester.pumpWidget(
        _wrapWithScreenSize(
          ExperienceCircleAvatar(
            imagePath: testImage,
            experience: 75,
            xpMax: 150,
          ),
          400,
        ),
      );

      final progress = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progress.value, 75 / 150);
    });
  });

  group('Pruebas de tamaño responsive', () {
  testWidgets('Tamaño pequeño (sm) por defecto', (tester) async {
    const screenWidth = 400.0;
    await tester.pumpWidget(
      _wrapWithScreenSize(
        ExperienceCircleAvatar(
          imagePath: testImage,
          experience: experience,
          xpMax: xpMax,
        ),
        screenWidth,
      ),
    );

    final container = tester.widget<Container>(find.byType(Container).first);
    final constraints = container.constraints as BoxConstraints;
    final boxDecoration = container.decoration as BoxDecoration;

    // Verificar tamaño
    expect(constraints.maxWidth, screenWidth * 0.14);
    
    // Verificar borde
    expect(boxDecoration.border!.top.width, 4.0);
  });

  testWidgets('Tamaño mediano (md)', (tester) async {
    const screenWidth = 400.0;
    await tester.pumpWidget(
      _wrapWithScreenSize(
        ExperienceCircleAvatar(
          imagePath: testImage,
          experience: experience,
          xpMax: xpMax,
          size: 'md',
        ),
        screenWidth,
      ),
    );

    final container = tester.widget<Container>(find.byType(Container).first);
    final constraints = container.constraints as BoxConstraints;
    final boxDecoration = container.decoration as BoxDecoration;

    expect(constraints.maxWidth, screenWidth * 0.2);
    expect(boxDecoration.border!.top.width, 6.0);
  });

  testWidgets('Tamaño grande (lg)', (tester) async {
    const screenWidth = 400.0;
    await tester.pumpWidget(
      _wrapWithScreenSize(
        ExperienceCircleAvatar(
          imagePath: testImage,
          experience: experience,
          xpMax: xpMax,
          size: 'lg',
        ),
        screenWidth,
      ),
    );

    final container = tester.widget<Container>(find.byType(Container).first);
    final constraints = container.constraints as BoxConstraints;
    final boxDecoration = container.decoration as BoxDecoration;

    expect(constraints.maxWidth, screenWidth * 0.35);
    expect(boxDecoration.border!.top.width, 8.0);
  });
});

  group('Pruebas de edge cases', () {
    testWidgets('Manejo de xpMax cero', (tester) async {
      await tester.pumpWidget(
        _wrapWithScreenSize(
          ExperienceCircleAvatar(
            imagePath: testImage,
            experience: 50,
            xpMax: 0,
          ),
          400,
        ),
      );

      final progress = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progress.value, 0.0);
    });

    testWidgets('Experiencia mayor que xpMax', (tester) async {
      await tester.pumpWidget(
        _wrapWithScreenSize(
          ExperienceCircleAvatar(
            imagePath: testImage,
            experience: 150,
            xpMax: 100,
          ),
          400,
        ),
      );

      final progress = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progress.value, 1.0);
    });
  });
}