import express from 'express';
import {
    getPaymentHistoryController,
    getOrderTransactionsController,
    getUserWalletBalanceController,
    getUserWalletTransactionsController,
    getRestaurantWalletController,
    getDeliveryWalletController,
    getAdminWalletController,
    getAdminFinanceSummaryController,
    listSettlementsController,
    createSettlementController,
    processSettlementController,
    listRefundsController,
    getRefundsByOrderController
} from './payment.controller.js';
import { requireRoles } from '../roles/role.middleware.js';

const router = express.Router();

// ─── Payment history for an order (user sees their payment trail) ───
router.get('/orders/:orderId/payments', getPaymentHistoryController);
router.get('/orders/:orderId/transactions', getOrderTransactionsController);
router.get('/orders/:orderId/refunds', getRefundsByOrderController);

// ─── User wallet (new transaction-based endpoints) ───
router.get('/wallet/balance', getUserWalletBalanceController);
router.get('/wallet/transactions', getUserWalletTransactionsController);

// ─── Restaurant wallet ───
router.get('/restaurant/:restaurantId/wallet', requireRoles('RESTAURANT', 'ADMIN'), getRestaurantWalletController);

// ─── Delivery partner wallet ───
router.get('/delivery/:deliveryPartnerId/wallet', requireRoles('DELIVERY_PARTNER', 'ADMIN'), getDeliveryWalletController);

// ─── Admin / Finance ───
router.get('/admin/wallet', requireRoles('ADMIN'), getAdminWalletController);
router.get('/admin/finance/summary', requireRoles('ADMIN'), getAdminFinanceSummaryController);
router.get('/admin/settlements', requireRoles('ADMIN'), listSettlementsController);
router.post('/admin/settlements', requireRoles('ADMIN'), createSettlementController);
router.post('/admin/settlements/:id/process', requireRoles('ADMIN'), processSettlementController);
router.get('/admin/refunds', requireRoles('ADMIN'), listRefundsController);

export default router;
