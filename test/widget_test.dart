import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:branchpad/app/theme.dart';
import 'package:branchpad/product/product_app.dart';

void main() {
  setUp(() {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Widget app() => MaterialApp(theme: AppTheme.build(), home: const ProductApp());

  testWidgets('каталог карт мыслей открывается', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('BranchPad'), findsOneWidget);
    expect(find.text('Запуск мобильного продукта'), findsWidgets);
    expect(find.text('Открыть холст карты'), findsWidgets);
  });

  testWidgets('вкладки переключаются без ошибок', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Холст'));
    await tester.pumpAndSettle();
    expect(find.text('Холст карты'), findsWidgets);

    await tester.tap(find.text('Структура'));
    await tester.pumpAndSettle();
    expect(find.text('Структура карты'), findsWidgets);

    await tester.tap(find.text('Опции'));
    await tester.pumpAndSettle();
    expect(find.text('Настройки'), findsWidgets);
  });

  testWidgets('на узком экране ничего не переполняется', (tester) async {
    tester.view.physicalSize = const Size(720, 1440);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
