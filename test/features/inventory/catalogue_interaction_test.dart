import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_commerce_seller/features/inventory/presentation/views/categories_screen.dart';
import 'package:quick_commerce_seller/features/inventory/presentation/views/products_screen.dart';

/// Both screens are long scrolls; a tall surface keeps every row laid out.
Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(1236, 7200);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ProviderScope(child: MaterialApp(home: screen)));
  await tester.pumpAndSettle();
}

void main() {
  group('CategoriesScreen', () {
    testWidgets('the edit icon sits inside a tap handler', (tester) async {
      await pumpScreen(tester, const CategoriesScreen());

      final editIcon = find.byIcon(Icons.edit_outlined).first;
      expect(
        find.ancestor(of: editIcon, matching: find.byType(InkWell)),
        findsWidgets,
        reason: 'the edit icon was a bare Container with no tap handler',
      );
    });

    testWidgets('the edit icon opens the rename dialog', (tester) async {
      await pumpScreen(tester, const CategoriesScreen());

      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pumpAndSettle();

      expect(find.text('Rename category'), findsOneWidget);
    });

    testWidgets('renaming updates the row immediately', (tester) async {
      await pumpScreen(tester, const CategoriesScreen());

      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Fresh Produce');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Fresh Produce'), findsOneWidget);
      expect(find.text('Fruits & Vegetables'), findsNothing);
    });

    testWidgets('the overflow menu opens the action sheet', (tester) async {
      await pumpScreen(tester, const CategoriesScreen());

      await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
      await tester.pumpAndSettle();

      expect(find.text('Rename'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('marking inactive flips the status badge', (tester) async {
      await pumpScreen(tester, const CategoriesScreen());
      expect(find.text('Inactive'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark inactive'));
      await tester.pumpAndSettle();

      expect(find.text('Inactive'), findsNWidgets(2));
    });

    testWidgets('delete asks for confirmation before removing', (tester) async {
      await pumpScreen(tester, const CategoriesScreen());

      await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete category?'), findsOneWidget);

      // Cancelling must leave the list untouched.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Fruits & Vegetables'), findsOneWidget);
    });

    testWidgets('search filters the category list', (tester) async {
      await pumpScreen(tester, const CategoriesScreen());

      await tester.enterText(find.byType(TextField).first, 'dairy');
      await tester.pumpAndSettle();

      expect(find.text('Dairy & Eggs'), findsOneWidget);
      expect(find.text('Beverages'), findsNothing);
    });

    testWidgets('no match shows the empty state', (tester) async {
      await pumpScreen(tester, const CategoriesScreen());

      await tester.enterText(find.byType(TextField).first, 'zzzz');
      await tester.pumpAndSettle();

      expect(find.text('No categories match'), findsOneWidget);
    });

    testWidgets('the Filter button opens a sheet and applies', (tester) async {
      await pumpScreen(tester, const CategoriesScreen());

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inactive only'));
      await tester.pumpAndSettle();

      expect(find.text('Household Essentials'), findsOneWidget);
      expect(find.text('Beverages'), findsNothing);
    });
  });

  group('ProductsScreen', () {
    testWidgets('the overflow menu opens the action sheet', (tester) async {
      await pumpScreen(tester, const ProductsScreen());

      await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
      await tester.pumpAndSettle();

      expect(find.text('Edit product'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('search filters the product list', (tester) async {
      await pumpScreen(tester, const ProductsScreen());
      expect(find.text('Banana (1 kg)'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'milk');
      await tester.pumpAndSettle();

      expect(find.text('Amul Taaza Milk 500 ml'), findsOneWidget);
      expect(find.text('Banana (1 kg)'), findsNothing);
    });

    testWidgets('search matches on SKU', (tester) async {
      await pumpScreen(tester, const ProductsScreen());

      await tester.enterText(find.byType(TextField).first, 'FRU001');
      await tester.pumpAndSettle();

      expect(find.text('Banana (1 kg)'), findsOneWidget);
    });

    testWidgets('no match shows the empty state', (tester) async {
      await pumpScreen(tester, const ProductsScreen());

      await tester.enterText(find.byType(TextField).first, 'zzzz');
      await tester.pumpAndSettle();

      expect(find.text('No products match'), findsOneWidget);
    });

    testWidgets('the Filter button opens a category sheet', (tester) async {
      await pumpScreen(tester, const ProductsScreen());

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      // The sheet lists every category chip as a radio option.
      expect(find.text('Beverages'), findsWidgets);
    });

    testWidgets('marking a product inactive updates its badge', (tester) async {
      await pumpScreen(tester, const ProductsScreen());

      await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark inactive'));
      await tester.pumpAndSettle();

      expect(find.text('Inactive'), findsWidgets);
    });
  });
}
