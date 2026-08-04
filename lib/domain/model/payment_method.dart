/// Payment options. The wire values are exactly what the backend accepts on
/// `POST /orders` (`razorpay | razorpay_qr | card | wallet | cash`).
enum PaymentMethod {
  upi('razorpay', 'UPI', 'Pay via any UPI app'),
  card('card', 'Credit / Debit card', 'Visa, Mastercard, RuPay'),
  qr('razorpay_qr', 'Scan & Pay', 'Show a QR to complete payment'),
  wallet('wallet', 'Suvio Wallet', 'Use your wallet balance'),
  cash('cash', 'Cash on Delivery', 'Pay the rider when it arrives');

  const PaymentMethod(this.wireValue, this.label, this.subtitle);

  final String wireValue;
  final String label;
  final String subtitle;

  bool get isOnline => this != PaymentMethod.cash && this != PaymentMethod.wallet;

  static PaymentMethod fromWire(String? value) => PaymentMethod.values.firstWhere(
        (m) => m.wireValue == value,
        orElse: () => PaymentMethod.upi,
      );
}
