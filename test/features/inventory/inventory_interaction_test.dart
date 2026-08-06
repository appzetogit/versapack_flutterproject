import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_commerce_seller/features/inventory/presentation/views/inventory_screen.dart';

/// The screen is a long scroll; a tall surface keeps all eight rows laid out so
/// finders and taps do not have to scroll first.
Future<void> pumpInventory(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1236, 7200);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: InventoryScreen())),
  );
  await tester.pumpAndSettle();
}

/// "Out of Stock" appears in the filter pill, the status badge and the toggle
/// label. The badge is the 10px bold one — match it precisely so a passing
/// assertion means what it says.
Finder statusBadge(String label) => find.byWidgetPredicate(
  (w) => w is Text && w.data == label && w.style?.fontSize == 10,
);

int switchesOff(WidgetTester tester) => tester
    .widgetList<Switch>(find.byType(Switch))
    .where((s) => s.value == false)
    .length;

void main() {
  group('stock toggle', () {
    testWidgets('every product row exposes a switch', (tester) async {
      await pumpInventory(tester);

      expect(find.byType(Switch), findsNWidgets(8));
    });

    testWidgets('one product is seeded out of stock', (tester) async {
      await pumpInventory(tester);

      expect(switchesOff(tester), 1);
      expect(statusBadge('Out of Stock'), findsOneWidget);
    });

    testWidgets('flipping a switch updates the badge immediately', (
      tester,
    ) async {
      await pumpInventory(tester);

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      // No backend round trip involved — the badge follows the switch.
      expect(switchesOff(tester), 2);
      expect(statusBadge('Out of Stock'), findsNWidgets(2));
    });

    testWidgets('toggling back restores the original stock level', (
      tester,
    ) async {
      await pumpInventory(tester);

      // Britannia Brown Bread is seeded Low Stock. Switching it off and on
      // again must not silently promote it to In Stock.
      expect(statusBadge('Low Stock'), findsNWidgets(3));

      final bread = find.byType(Switch).at(2);
      await tester.tap(bread);
      await tester.pumpAndSettle();
      expect(statusBadge('Low Stock'), findsNWidgets(2));

      await tester.tap(bread);
      await tester.pumpAndSettle();
      expect(statusBadge('Low Stock'), findsNWidgets(3));
    });
  });

  group('edit affordance', () {
    testWidgets('the edit icon sits inside a tap handler', (tester) async {
      await pumpInventory(tester);

      final editIcon = find.byIcon(Icons.edit_outlined).first;
      expect(editIcon, findsOneWidget);

      // The reported bug: the icon was a bare Container with no ancestor able
      // to receive a tap.
      expect(
        find.ancestor(of: editIcon, matching: find.byType(InkWell)),
        findsWidgets,
        reason: 'the edit icon must sit inside a tappable ancestor',
      );
    });

    testWidgets('icon-only actions carry semantic labels', (tester) async {
      await pumpInventory(tester);

      expect(find.bySemanticsLabel(RegExp('^Edit ')), findsWidgets);
      expect(find.bySemanticsLabel('Stock history'), findsWidgets);
    });
  });

  group('search', () {
    testWidgets('typing filters the list down', (tester) async {
      await pumpInventory(tester);
      expect(find.text('Banana (1 kg)'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'milk');
      await tester.pumpAndSettle();

      expect(find.text('Amul Taaza Milk 500 ml'), findsOneWidget);
      expect(find.text('Banana (1 kg)'), findsNothing);
    });

    testWidgets('search matches on SKU as the hint promises', (tester) async {
      await pumpInventory(tester);

      await tester.enterText(find.byType(TextField), 'BEV001');
      await tester.pumpAndSettle();

      expect(find.text('Coca Cola 750 ml'), findsOneWidget);
      expect(find.text('Banana (1 kg)'), findsNothing);
    });

    testWidgets('no matches shows the empty state', (tester) async {
      await pumpInventory(tester);

      await tester.enterText(find.byType(TextField), 'zzzz-no-such-product');
      await tester.pumpAndSettle();

      expect(find.text('No products match'), findsOneWidget);
      expect(find.text('Clear filters'), findsOneWidget);
    });

    testWidgets('Clear filters restores the full list', (tester) async {
      await pumpInventory(tester);

      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear filters'));
      await tester.pumpAndSettle();

      expect(find.text('Banana (1 kg)'), findsOneWidget);
    });
  });

  group('filters', () {
    testWidgets('the Out of Stock pill narrows the list', (tester) async {
      await pumpInventory(tester);

      // The pill row scrolls horizontally and this pill starts off-screen on a
      // phone-width viewport.
      final pill = find.textContaining('Out of Stock (');
      await tester.ensureVisible(pill);
      await tester.pumpAndSettle();
      await tester.tap(pill);
      await tester.pumpAndSettle();

      expect(find.text('Dove Beauty Bar 100g'), findsOneWidget);
      expect(find.text('Banana (1 kg)'), findsNothing);
    });

    testWidgets('the Expiring Soon pill has data behind it', (tester) async {
      await pumpInventory(tester);

      final pill = find.textContaining('Expiring Soon (');
      await tester.ensureVisible(pill);
      await tester.pumpAndSettle();
      await tester.tap(pill);
      await tester.pumpAndSettle();

      // Previously this pill could only ever render the empty state.
      expect(find.text('No products match'), findsNothing);
    });

    testWidgets('the Filter button opens a bottom sheet', (tester) async {
      await pumpInventory(tester);

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      expect(find.text('Filter by status'), findsOneWidget);
    });

    testWidgets('choosing a status in the sheet applies it', (tester) async {
      await pumpInventory(tester);

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Out of Stock (').last);
      await tester.pumpAndSettle();

      expect(find.text('Dove Beauty Bar 100g'), findsOneWidget);
      expect(find.text('Banana (1 kg)'), findsNothing);
    });

    testWidgets('pill counts track the toggle rather than being fixed', (
      tester,
    ) async {
      await pumpInventory(tester);
      expect(find.textContaining('Out of Stock (1)'), findsOneWidget);

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      expect(find.textContaining('Out of Stock (2)'), findsOneWidget);
    });
  });
}
