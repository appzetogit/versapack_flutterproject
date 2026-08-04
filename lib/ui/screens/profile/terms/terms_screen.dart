import 'package:flutter/material.dart';

import '../privacy_policy/legal_document_screen.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Terms of service',
      lastUpdated: 'January 2026',
      intro:
          'These terms cover your use of Suvio Quick. By placing an order you '
          'agree to them, so they are written to be understood rather than to '
          'be impressive.',
      sections: [
        LegalSection(
          heading: 'Your account',
          body: [
            'You need a verified mobile number to order. Keep access to that '
                'number secure — anyone who can receive its one-time passwords '
                'can place orders on your account.',
            'One account per person. Accounts created to abuse promotions may '
                'be suspended.',
          ],
        ),
        LegalSection(
          heading: 'Orders and pricing',
          body: [
            'Prices, availability and delivery fees are confirmed at the moment '
                'you check out. If a price changes between adding an item and '
                'paying, we show you the difference before you confirm.',
            'The bill shown at checkout is the amount you pay. Item total, '
                'delivery, platform fee, taxes and any discount are itemised '
                'in full.',
            'Occasionally an item is unavailable after you order. If we cannot '
                'fulfil part of your order, that portion is refunded.',
          ],
        ),
        LegalSection(
          heading: 'Delivery',
          body: [
            'Delivery times are estimates based on distance and current demand. '
                'We work hard to meet them but weather, traffic and local '
                'conditions can affect them.',
            'Someone must be available to receive the order at the address you '
                'gave. Your rider may ask for the delivery code shown in the app.',
            'If nobody is reachable after repeated attempts, the order may be '
                'returned and a portion of the fee retained to cover the trip.',
          ],
        ),
        LegalSection(
          heading: 'Cancellations and refunds',
          body: [
            'You can cancel free of charge while an order is still being '
                'confirmed. Once the store has begun packing, cancellation may '
                'not be possible.',
            'Refunds are returned to the original payment method, typically '
                'within three to five working days.',
          ],
        ),
        LegalSection(
          heading: 'Acceptable use',
          body: [
            'Do not use the service to break the law, harass our riders or '
                'store staff, or attempt to disrupt the app or its backend.',
            'Age-restricted products, where offered, require valid proof of age '
                'at delivery.',
          ],
        ),
        LegalSection(
          heading: 'Changes to these terms',
          body: [
            'We may update these terms as the service evolves. Material changes '
                'will be highlighted in the app before they take effect.',
          ],
        ),
      ],
    );
  }
}
