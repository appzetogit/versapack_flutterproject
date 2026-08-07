import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_commerce_seller/features/auth/presentation/views/registration_screen.dart';

/// A minimal router so `context.go('/registration-success')` resolves without
/// dragging in the real auth redirect.
Future<void> pumpRegistration(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1236, 4200);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    initialLocation: '/registration',
    routes: [
      GoRoute(
        path: '/registration',
        builder: (_, _) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/registration-success',
        builder: (_, _) => const Scaffold(body: Text('SUCCESS')),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(child: MaterialApp.router(routerConfig: router)),
  );
  await tester.pumpAndSettle();
}

Future<void> completeStepOne(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'Tanu Store');
  await tester.tap(find.byType(DropdownButtonFormField<String>).at(0));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Grocery & Staples').last);
  await tester.pumpAndSettle();
  await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Specialty Retailer').last);
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).at(1), '12345678901123');
  await tester.pump();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

void main() {
  group('step 1', () {
    testWidgets('starts on step 1 of 4', (tester) async {
      await pumpRegistration(tester);

      expect(find.text('Step 1 of 4'), findsOneWidget);
      expect(find.text('Business Information'), findsOneWidget);
    });

    testWidgets('Continue with an empty form does not advance', (tester) async {
      await pumpRegistration(tester);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Previously this called refreshSession(), which 401'd and threw.
      expect(find.text('Step 1 of 4'), findsOneWidget);
      expect(find.textContaining('Enter your'), findsWidgets);
    });

    testWidgets('a filled form advances to step 2', (tester) async {
      await pumpRegistration(tester);
      await completeStepOne(tester);

      expect(find.text('Step 2 of 4'), findsOneWidget);
      expect(find.text('Store Address'), findsOneWidget);
    });

    testWidgets('a too-short licence is rejected', (tester) async {
      await pumpRegistration(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'Tanu Store');
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('That looks too short to be valid'), findsOneWidget);
      expect(find.text('Step 1 of 4'), findsOneWidget);
    });
  });

  group('navigation between steps', () {
    testWidgets('back returns to the previous step, not out of the flow', (
      tester,
    ) async {
      await pumpRegistration(tester);
      await completeStepOne(tester);
      expect(find.text('Step 2 of 4'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Step 1 of 4'), findsOneWidget);
    });

    testWidgets('values entered on step 1 survive going back', (tester) async {
      await pumpRegistration(tester);
      await completeStepOne(tester);
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Tanu Store'), findsOneWidget);
    });
  });

  group('step 2 — address', () {
    testWidgets('pincode must be 6 digits', (tester) async {
      await pumpRegistration(tester);
      await completeStepOne(tester);

      await tester.enterText(find.byType(TextFormField).at(0), '12 Main Rd');
      await tester.enterText(find.byType(TextFormField).at(1), 'Vijay Nagar');
      await tester.enterText(find.byType(TextFormField).at(2), 'Indore');
      await tester.enterText(find.byType(TextFormField).at(3), '452');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a 6-digit pincode'), findsOneWidget);
      expect(find.text('Step 2 of 4'), findsOneWidget);
    });

    testWidgets('a valid address advances to payout', (tester) async {
      await pumpRegistration(tester);
      await completeStepOne(tester);

      await tester.enterText(find.byType(TextFormField).at(0), '12 Main Rd');
      await tester.enterText(find.byType(TextFormField).at(1), 'Vijay Nagar');
      await tester.enterText(find.byType(TextFormField).at(2), 'Indore');
      await tester.enterText(find.byType(TextFormField).at(3), '452010');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Step 3 of 4'), findsOneWidget);
      expect(find.text('Payout Details'), findsOneWidget);
    });
  });

  group('step 3 — payout', () {
    Future<void> toPayout(WidgetTester tester) async {
      await completeStepOne(tester);
      await tester.enterText(find.byType(TextFormField).at(0), '12 Main Rd');
      await tester.enterText(find.byType(TextFormField).at(1), 'Vijay Nagar');
      await tester.enterText(find.byType(TextFormField).at(2), 'Indore');
      await tester.enterText(find.byType(TextFormField).at(3), '452010');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }

    testWidgets('a malformed IFSC is rejected', (tester) async {
      await pumpRegistration(tester);
      await toPayout(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'Tanu Chouhan');
      await tester.enterText(find.byType(TextFormField).at(1), '123456789012');
      await tester.enterText(find.byType(TextFormField).at(2), 'NOTANIFSC');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid 11-character IFSC code'), findsOneWidget);
    });

    testWidgets('a valid IFSC advances to documents', (tester) async {
      await pumpRegistration(tester);
      await toPayout(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'Tanu Chouhan');
      await tester.enterText(find.byType(TextFormField).at(1), '123456789012');
      await tester.enterText(find.byType(TextFormField).at(2), 'HDFC0001234');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Step 4 of 4'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Submit application'), findsOneWidget);
    });
  });

  group('step 4 — documents', () {
    Future<void> toDocuments(WidgetTester tester) async {
      await completeStepOne(tester);
      await tester.enterText(find.byType(TextFormField).at(0), '12 Main Rd');
      await tester.enterText(find.byType(TextFormField).at(1), 'Vijay Nagar');
      await tester.enterText(find.byType(TextFormField).at(2), 'Indore');
      await tester.enterText(find.byType(TextFormField).at(3), '452010');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Tanu Chouhan');
      await tester.enterText(find.byType(TextFormField).at(1), '123456789012');
      await tester.enterText(find.byType(TextFormField).at(2), 'HDFC0001234');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }

    testWidgets('submitting without documents is blocked', (tester) async {
      await pumpRegistration(tester);
      await toDocuments(tester);

      await tester.tap(find.text('Submit application'));
      await tester.pumpAndSettle();

      expect(find.text('Step 4 of 4'), findsOneWidget);
      expect(find.text('SUCCESS'), findsNothing);
    });

    testWidgets('document tiles toggle on tap', (tester) async {
      await pumpRegistration(tester);
      await toDocuments(tester);

      expect(find.text('Attached'), findsNothing);
      await tester.tap(find.text('PAN Card'));
      await tester.pumpAndSettle();

      expect(find.text('Attached'), findsOneWidget);
    });

    testWidgets('all documents attached reaches the success screen', (
      tester,
    ) async {
      await pumpRegistration(tester);
      await toDocuments(tester);

      for (final doc in [
        'PAN Card',
        'GSTIN Certificate',
        'FSSAI Licence',
        'Store Photo',
      ]) {
        await tester.tap(find.text(doc));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Submit application'));
      await tester.pumpAndSettle();

      expect(find.text('SUCCESS'), findsOneWidget);
    });
  });
}
