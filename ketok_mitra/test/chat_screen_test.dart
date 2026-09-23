import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ketok_mitra/screens/chat_screen.dart';

void main() {
  testWidgets('opens a conversation on compact layout', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ChatScreen())),
    );

    await tester.tap(find.text('Andi Pratama'));
    await tester.pumpAndSettle();

    expect(find.text('Pak, saya sudah sampai di bengkel.'), findsOneWidget);
    expect(find.text('Tulis pesan untuk pelanggan...'), findsOneWidget);
  });
}
