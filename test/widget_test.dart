import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:swift_shop/widgets/brand_header.dart';

void main() {
  testWidgets('brand header shows cart count badge', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BrandHeader(cartCount: 3, onCartTap: () {})),
      ),
    );

    expect(find.text('SWIFTSHOP'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
  });
}
