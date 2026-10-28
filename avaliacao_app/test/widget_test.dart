import 'package:avaliacao_app/screens/formulario_produto_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('formulário valida e cabe em telas de 320 e 800 px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: FormularioProdutoScreen()));
    await tester.ensureVisible(find.text('Salvar produto'));
    await tester.tap(find.text('Salvar produto'));
    await tester.pumpAndSettle();

    expect(find.text('Informe o nome.'), findsOneWidget);
    expect(find.text('Informe a descrição.'), findsOneWidget);
    expect(find.text('Informe a categoria.'), findsOneWidget);
    expect(find.text('Informe um preço maior que zero.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(800, 1000);
    await tester.pumpAndSettle();
    expect(find.text('Dados do produto'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
