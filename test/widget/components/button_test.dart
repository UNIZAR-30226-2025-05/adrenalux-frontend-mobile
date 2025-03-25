import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:adrenalux_frontend_mobile/providers/theme_provider.dart';
import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:adrenalux_frontend_mobile/widgets/button.dart';

class DummyThemeProvider extends ChangeNotifier implements ThemeProvider {
  final ThemeData _theme;
  
  DummyThemeProvider({required ThemeData theme}) : _theme = theme;
  
  @override
  ThemeData get currentTheme => _theme;
  
  @override
  void toggleTheme() {}
  
  @override
  bool get isDarkTheme => false;
  
  @override
  String getLogo() {
    return 'assets/adrenalux_logo_white.png';
  }
}

class TestButtonWidget extends StatelessWidget {
  final bool type;
  final String text;
  final VoidCallback action;
  
  const TestButtonWidget({
    Key? key,
    required this.type,
    required this.text,
    required this.action,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return textButton(context, type, text, action);
  }
}

void main() {
  const testScreenSize = Size(400, 800);

  final dummyTheme = ThemeData(
    primaryColor: Colors.red,
    primaryColorDark: Colors.red[700],
    colorScheme: ColorScheme.light(
      primary: Colors.red,
      onPrimary: Colors.white,
    ),
  );

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: testScreenSize),
        child: ChangeNotifierProvider<ThemeProvider>(
          create: (_) => DummyThemeProvider(theme: dummyTheme),
          child: Builder(
            builder: (context) {
              ScreenSize.of(context);
              return Scaffold(body: Center(child: child));
            },
          ),
        ),
      ),
    );
  }

  testWidgets('textButton muestra el texto y responde al presionado (type true)',
      (WidgetTester tester) async {
    bool pressed = false;

    final widgetUnderTest = TestButtonWidget(
      type: true,
      text: 'Test Button',
      action: () {
        pressed = true;
      },
    );

    await tester.pumpWidget(createTestWidget(widgetUnderTest));
    await tester.pumpAndSettle();

    expect(find.text('Test Button'), findsOneWidget);

    final sizedBoxFinder = find.byWidgetPredicate((widget) =>
        widget is SizedBox && widget.width == testScreenSize.width * 0.75);
    expect(sizedBoxFinder, findsOneWidget, reason: 'El SizedBox no tiene el ancho esperado');

    final containerFinder = find.descendant(
      of: find.byType(TestButtonWidget),
      matching: find.byType(Container),
    );
    expect(containerFinder, findsOneWidget, reason: 'No se encontró el Container');

    final Container containerWidget = tester.widget(containerFinder);
    final decoration = containerWidget.decoration as BoxDecoration;
    expect(decoration.border, isNotNull, reason: 'El borde no está definido en el Container');

    final border = decoration.border as Border;

    expect(border.top.width, equals(0), reason: 'El ancho del borde no es 0 para type true');

    await tester.tap(find.byType(TextButton));
    expect(pressed, isTrue, reason: 'La acción onPressed no se ejecutó al presionar el botón');
  });

  testWidgets('textButton configura correctamente el borde cuando type es false',
      (WidgetTester tester) async {
    bool pressed = false;

    final widgetUnderTest = TestButtonWidget(
      type: false, 
      text: 'Button False',
      action: () {
        pressed = true;
      },
    );

    await tester.pumpWidget(createTestWidget(widgetUnderTest));
    await tester.pumpAndSettle();

    expect(find.text('Button False'), findsOneWidget);

    final containerFinder = find.descendant(
      of: find.byType(TestButtonWidget),
      matching: find.byType(Container),
    );
    expect(containerFinder, findsOneWidget, reason: 'No se encontró el Container');

    final Container containerWidget = tester.widget(containerFinder);
    final decoration = containerWidget.decoration as BoxDecoration;
    expect(decoration.border, isNotNull, reason: 'El borde no está definido en el Container');

    final border = decoration.border as Border;
    expect(border.top.width, equals(1.25),
        reason: 'El ancho del borde no es 1.25 para type false');
  });

  testWidgets('textButton utiliza el tamaño de fuente correcto en el texto',
      (WidgetTester tester) async {
    final expectedFontSize = testScreenSize.height * 0.025; 

    final widgetUnderTest = TestButtonWidget(
      type: true,
      text: 'Fuente Test',
      action: () {},
    );

    await tester.pumpWidget(createTestWidget(widgetUnderTest));
    await tester.pumpAndSettle();

    final textFinder = find.text('Fuente Test');
    expect(textFinder, findsOneWidget);

    final Text textWidget = tester.widget(textFinder);
    expect(textWidget.style?.fontSize, expectedFontSize,
        reason: 'El tamaño de fuente no coincide con el esperado');
  });
}
