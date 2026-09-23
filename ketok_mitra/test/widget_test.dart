// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:ketok_mitra/screens/beranda_screen.dart';
import 'package:ketok_mitra/screens/pesanan_detail_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('BerandaScreen UI basic test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BerandaScreen()));
    expect(find.text('Ketok'), findsOneWidget);
    expect(find.text('MITRA'), findsOneWidget);
  });

  testWidgets('PesananDetailScreen shows order information', (
    WidgetTester tester,
  ) async {
    final order = {
      'id_pesanan': 42,
      'category_name': 'Pembersihan Rumah',
      'customer_name': 'Budi Santoso',
      'lokasi': 'Jl. Merdeka No. 15',
      'jadwal': '2026-09-11T10:00:00.000',
      'status': 'diproses',
      'price': 450000,
      'catatan': 'Tolong datang sebelum siang.',
    };

    await tester.pumpWidget(
      MaterialApp(home: PesananDetailScreen(order: order)),
    );

    expect(find.text('Detail Pesanan'), findsOneWidget);
    expect(find.text('Pembersihan Rumah'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('Jl. Merdeka No. 15'), findsOneWidget);
  });
}
