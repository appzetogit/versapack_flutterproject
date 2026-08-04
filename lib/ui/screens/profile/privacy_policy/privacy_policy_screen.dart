import 'package:flutter/material.dart';

import 'legal_document_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Privacy policy',
      lastUpdated: 'January 2026',
      intro:
          'This policy explains what Suvio Quick collects, why we collect it, '
          'and the choices you have. We keep it short because you should be '
          'able to actually read it.',
      sections: [
        LegalSection(
          heading: 'What we collect',
          body: [
            'Account details: your mobile number, and the name and email you '
                'choose to add. Your number is verified by one-time password so '
                'we know an order is really yours.',
            'Delivery details: the addresses you save, including the map pin, '
                'which we use to calculate an accurate delivery time and fee.',
            'Order history: what you ordered, when, and what you paid. This is '
                'what powers reordering and your bill history.',
            'Device basics: app version and a notification token, so delivery '
                'updates reach the right device.',
          ],
        ),
        LegalSection(
          heading: 'What we do not collect',
          body: [
            'We do not store your card number, UPI PIN or bank credentials. '
                'Payments are handled entirely by our payment partner.',
            'We do not read your contacts, photos or messages.',
            'We do not track your location in the background. Location is used '
                'only while you are choosing or confirming a delivery address.',
          ],
        ),
        LegalSection(
          heading: 'How we use it',
          body: [
            'To deliver your order and keep you updated while it is on the way.',
            'To calculate accurate pricing, including distance-based delivery '
                'fees and any coupon you apply.',
            'To provide support when something goes wrong with an order.',
            'To improve the catalog and the app itself, using aggregate '
                'patterns rather than individual profiles.',
          ],
        ),
        LegalSection(
          heading: 'Who we share it with',
          body: [
            'The store fulfilling your order and the rider delivering it see '
                'only what they need: your items, address and contact number.',
            'Our payment partner receives the amount and order reference to '
                'process your payment.',
            'We do not sell your data, and we do not share it for advertising.',
          ],
        ),
        LegalSection(
          heading: 'Your choices',
          body: [
            'You can edit or delete any saved address from the app at any time.',
            'You can turn off order notifications in Settings.',
            'You can delete your account from your profile. Order records we '
                'are legally required to retain are kept, but your personal '
                'details are removed.',
          ],
        ),
        LegalSection(
          heading: 'Contact us',
          body: [
            'Questions about this policy? Reach us through Help and support in '
                'the app, and a real person will reply.',
          ],
        ),
      ],
    );
  }
}
