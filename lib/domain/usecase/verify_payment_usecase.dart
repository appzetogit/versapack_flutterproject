import 'dart:math';

import '../model/order.dart';
import '../repository/order_repository.dart';

/// Completes a gateway payment.
///
/// No payment SDK is embedded (see the master prompt's scope contract), so the
/// gateway handshake is simulated: we wait, then call the backend's real
/// `verify-payment` endpoint with the identifiers it handed us at creation.
/// The signature the backend checks is produced by the gateway, so a simulated
/// verification is expected to fail signature validation in a live
/// environment — that failure is surfaced honestly rather than faked away.
class VerifyPaymentUseCase {
  const VerifyPaymentUseCase(this._repository, {this.simulatedFailureRate = 0.0});

  final OrderRepository _repository;

  /// Lets the payment screen exercise its retry path in demos.
  final double simulatedFailureRate;

  Future<Order> call(PlacedOrder placed) async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));

    if (simulatedFailureRate > 0 && Random().nextDouble() < simulatedFailureRate) {
      throw const PaymentSimulationFailure();
    }

    final gatewayOrderId = placed.gatewayOrderId;
    if (gatewayOrderId == null) return placed.order;

    return _repository.verifyPayment(
      orderId: placed.order.id,
      gatewayOrderId: gatewayOrderId,
      gatewayPaymentId: 'pay_sim_${DateTime.now().millisecondsSinceEpoch}',
      signature: 'sig_simulated',
    );
  }

  Future<void> abandon(PlacedOrder placed) =>
      _repository.abandonPendingPayment(placed.order.id);
}

class PaymentSimulationFailure implements Exception {
  const PaymentSimulationFailure();

  @override
  String toString() => 'The payment could not be completed.';
}
