import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/features/investments/domain/fifo_engine.dart';

void main() {
  group('FifoEngine - Unit Tests', () {
    test('Buy 3 times different prices, sell once consuming across 2 lots', () {
      final now = DateTime(2026, 1, 1);
      final lot1 = LotState(
        id: 'lot-1',
        assetId: 'asset-ptt',
        buyDate: DateTime(2026, 1, 1),
        createdAt: now,
        quantity: Decimal.parse('100'),
        remainingQuantity: Decimal.parse('100'),
        costPerUnitOriginalSatang: 3000, // 30.00 THB
        fxRate: Decimal.parse('1.000000'),
        costPerUnitThbSatang: 3000,
        feeThbSatang: 1000, // 10.00 THB
        totalCostThbSatang: 301000, // (100 * 30.00) + 10 = 3,010.00 THB
        remainingCostThbSatang: 301000,
        status: 'open',
      );

      final lot2 = LotState(
        id: 'lot-2',
        assetId: 'asset-ptt',
        buyDate: DateTime(2026, 1, 10),
        createdAt: now.add(const Duration(days: 9)),
        quantity: Decimal.parse('100'),
        remainingQuantity: Decimal.parse('100'),
        costPerUnitOriginalSatang: 3500, // 35.00 THB
        fxRate: Decimal.parse('1.000000'),
        costPerUnitThbSatang: 3500,
        feeThbSatang: 1000, // 10.00 THB
        totalCostThbSatang: 351000, // (100 * 35.00) + 10 = 3,510.00 THB
        remainingCostThbSatang: 351000,
        status: 'open',
      );

      final lot3 = LotState(
        id: 'lot-3',
        assetId: 'asset-ptt',
        buyDate: DateTime(2026, 1, 20),
        createdAt: now.add(const Duration(days: 19)),
        quantity: Decimal.parse('100'),
        remainingQuantity: Decimal.parse('100'),
        costPerUnitOriginalSatang: 4000, // 40.00 THB
        fxRate: Decimal.parse('1.000000'),
        costPerUnitThbSatang: 4000,
        feeThbSatang: 1000,
        totalCostThbSatang: 401000,
        remainingCostThbSatang: 401000,
        status: 'open',
      );

      // Sell 150 units at 50.00 THB (5000 satang), fee 20.00 THB (2000 satang)
      // Should consume lot1 completely (100 units) + lot2 partially (50 units)
      final result = FifoEngine.processSell(
        openLots: [lot1, lot2, lot3],
        sellQuantity: Decimal.parse('150'),
        sellPriceOriginalSatang: 5000,
        sellFxRate: Decimal.parse('1.000000'),
        sellFeeThbSatang: 2000,
      );

      expect(result.consumptions.length, 2);
      expect(result.consumptions[0].lotId, 'lot-1');
      expect(result.consumptions[0].quantitySold, Decimal.parse('100'));
      expect(result.consumptions[1].lotId, 'lot-2');
      expect(result.consumptions[1].quantitySold, Decimal.parse('50'));

      // Fee pro-rata check: total fee 2000 satang
      // Lot 1: 100/150 * 2000 = 1333 satang
      // Lot 2: 2000 - 1333 = 667 satang (residual absorption)
      expect(result.consumptions[0].feeThbSatang + result.consumptions[1].feeThbSatang, 2000);

      // Status checks
      expect(lot1.status, 'closed');
      expect(lot1.remainingQuantity, Decimal.zero);
      expect(lot1.remainingCostThbSatang, 0);

      expect(lot2.status, 'partially_closed');
      expect(lot2.remainingQuantity, Decimal.parse('50'));
      expect(lot3.status, 'open');
      expect(lot3.remainingQuantity, Decimal.parse('100'));
    });

    test('Sell more than available throws InsufficientQuantityException', () {
      final lot = LotState(
        id: 'lot-1',
        assetId: 'asset-1',
        buyDate: DateTime(2026, 1, 1),
        createdAt: DateTime.now(),
        quantity: Decimal.parse('50'),
        remainingQuantity: Decimal.parse('50'),
        costPerUnitOriginalSatang: 1000,
        fxRate: Decimal.parse('1.000000'),
        costPerUnitThbSatang: 1000,
        feeThbSatang: 0,
        totalCostThbSatang: 50000,
        remainingCostThbSatang: 50000,
        status: 'open',
      );

      expect(
        () => FifoEngine.processSell(
          openLots: [lot],
          sellQuantity: Decimal.parse('60'),
          sellPriceOriginalSatang: 1200,
          sellFxRate: Decimal.parse('1.000000'),
          sellFeeThbSatang: 0,
        ),
        throwsA(isA<InsufficientQuantityException>()),
      );
    });

    test('Sell fractional crypto quantity with 8 decimals', () {
      final lot = LotState(
        id: 'lot-btc',
        assetId: 'btc',
        buyDate: DateTime(2026, 1, 1),
        createdAt: DateTime.now(),
        quantity: Decimal.parse('0.05000000'),
        remainingQuantity: Decimal.parse('0.05000000'),
        costPerUnitOriginalSatang: 300000000, // 3,000,000 THB per BTC
        fxRate: Decimal.parse('1.000000'),
        costPerUnitThbSatang: 300000000,
        feeThbSatang: 0,
        totalCostThbSatang: 15000000, // 0.05 * 3,000,000 = 150,000 THB
        remainingCostThbSatang: 15000000,
        status: 'open',
      );

      final result = FifoEngine.processSell(
        openLots: [lot],
        sellQuantity: Decimal.parse('0.00123456'),
        sellPriceOriginalSatang: 350000000, // 3,500,000 THB per BTC
        sellFxRate: Decimal.parse('1.000000'),
        sellFeeThbSatang: 5000, // 50.00 THB
      );

      expect(result.consumptions.length, 1);
      expect(result.consumptions[0].quantitySold, Decimal.parse('0.00123456'));
      expect(lot.remainingQuantity, Decimal.parse('0.04876544'));
      expect(lot.status, 'partially_closed');
    });

    test('USD FX separation: Buy USD rate 34, Sell USD rate 36 separates Price P&L and FX P&L accurately', () {
      // 1 share bought at 100 USD (10,000 cents/satang) with FX = 34.000000
      // Cost THB = 100 * 34 = 3,400.00 THB (340,000 satang)
      final lot = LotState(
        id: 'lot-us-1',
        assetId: 'aapl',
        buyDate: DateTime(2026, 1, 1),
        createdAt: DateTime.now(),
        quantity: Decimal.parse('1'),
        remainingQuantity: Decimal.parse('1'),
        costPerUnitOriginalSatang: 10000, // 100.00 USD
        fxRate: Decimal.parse('34.000000'),
        costPerUnitThbSatang: 340000,
        feeThbSatang: 0,
        totalCostThbSatang: 340000,
        remainingCostThbSatang: 340000,
        status: 'open',
      );

      // Sell 1 share at 120.00 USD (12,000 cents) with FX = 36.000000, fee 0
      // Revenue THB = 120 * 36 = 4,320.00 THB (432,000 satang)
      // Total Gain = 4320 - 3400 = 920.00 THB (92,000 satang)
      final result = FifoEngine.processSell(
        openLots: [lot],
        sellQuantity: Decimal.parse('1'),
        sellPriceOriginalSatang: 12000,
        sellFxRate: Decimal.parse('36.000000'),
        sellFeeThbSatang: 0,
      );

      final c = result.consumptions.first;

      // Price P&L = (120 - 100) * 34 = 20 * 34 = 680.00 THB (68,000 satang)
      expect(c.priceGainLossThbSatang, 68000);

      // FX P&L = 120 * (36 - 34) = 120 * 2 = 240.00 THB (24,000 satang)
      expect(c.fxGainLossThbSatang, 24000);

      // Price P&L + FX P&L = 680 + 240 = 920.00 THB
      expect(c.priceGainLossThbSatang + c.fxGainLossThbSatang, 92000);

      // Realized Gain THB = 4,320 - 3,400 = 920.00 THB
      expect(c.realizedGainLossThbSatang, 92000);
      expect(lot.status, 'closed');
      expect(lot.remainingCostThbSatang, 0);
    });

    test('Residual Balance on Lot Close ensures zero rounding drift across multiple partial sales', () {
      // 3 units bought for 100.00 THB total (10,000 satang)
      // 10,000 / 3 = 3333.33 satang per unit
      final lot = LotState(
        id: 'lot-drift',
        assetId: 'asset-drift',
        buyDate: DateTime(2026, 1, 1),
        createdAt: DateTime.now(),
        quantity: Decimal.parse('3'),
        remainingQuantity: Decimal.parse('3'),
        costPerUnitOriginalSatang: 3333,
        fxRate: Decimal.parse('1.000000'),
        costPerUnitThbSatang: 3333,
        feeThbSatang: 0,
        totalCostThbSatang: 10000,
        remainingCostThbSatang: 10000,
        status: 'open',
      );

      // Sell 1 unit: cost = round(10000 * 1/3) = 3333 satang. Remaining cost = 10000 - 3333 = 6667
      final sale1 = FifoEngine.processSell(
        openLots: [lot],
        sellQuantity: Decimal.parse('1'),
        sellPriceOriginalSatang: 5000,
        sellFxRate: Decimal.parse('1.000000'),
        sellFeeThbSatang: 0,
      );
      expect(sale1.consumptions.first.costThbSatang, 3333);
      expect(lot.remainingCostThbSatang, 6667);

      // Sell 1 unit: cost = round(10000 * 1/3) = 3333 satang. Remaining cost = 6667 - 3333 = 3334
      final sale2 = FifoEngine.processSell(
        openLots: [lot],
        sellQuantity: Decimal.parse('1'),
        sellPriceOriginalSatang: 5000,
        sellFxRate: Decimal.parse('1.000000'),
        sellFeeThbSatang: 0,
      );
      expect(sale2.consumptions.first.costThbSatang, 3333);
      expect(lot.remainingCostThbSatang, 3334);

      // Sell final 1 unit: closes the lot! Must take ALL remaining cost = 3334 satang!
      final sale3 = FifoEngine.processSell(
        openLots: [lot],
        sellQuantity: Decimal.parse('1'),
        sellPriceOriginalSatang: 5000,
        sellFxRate: Decimal.parse('1.000000'),
        sellFeeThbSatang: 0,
      );
      expect(sale3.consumptions.first.costThbSatang, 3334);
      expect(lot.remainingCostThbSatang, 0);
      expect(lot.status, 'closed');

      // Total cost of 3 sales = 3333 + 3333 + 3334 = exactly 10,000 satang! Zero drift!
      final sumCost = sale1.consumptions.first.costThbSatang +
          sale2.consumptions.first.costThbSatang +
          sale3.consumptions.first.costThbSatang;
      expect(sumCost, 10000);
    });

    test('Deterministic tie-breaker when buyDate is identical', () {
      final sameDate = DateTime(2026, 1, 1);
      final lotA = LotState(
        id: 'lot-a',
        assetId: 'asset-1',
        buyDate: sameDate,
        createdAt: DateTime(2026, 1, 1, 10, 0),
        quantity: Decimal.parse('10'),
        remainingQuantity: Decimal.parse('10'),
        costPerUnitOriginalSatang: 1000,
        fxRate: Decimal.parse('1.000000'),
        costPerUnitThbSatang: 1000,
        feeThbSatang: 0,
        totalCostThbSatang: 10000,
        remainingCostThbSatang: 10000,
        status: 'open',
      );

      final lotB = LotState(
        id: 'lot-b',
        assetId: 'asset-1',
        buyDate: sameDate,
        createdAt: DateTime(2026, 1, 1, 11, 0),
        quantity: Decimal.parse('10'),
        remainingQuantity: Decimal.parse('10'),
        costPerUnitOriginalSatang: 2000,
        fxRate: Decimal.parse('1.000000'),
        costPerUnitThbSatang: 2000,
        feeThbSatang: 0,
        totalCostThbSatang: 20000,
        remainingCostThbSatang: 20000,
        status: 'open',
      );

      // Passed in reverse order [lotB, lotA], but lotA was created earlier (10:00 vs 11:00)
      final sorted = FifoEngine.sortLotsForFifo([lotB, lotA]);
      expect(sorted.first.id, 'lot-a');
      expect(sorted.last.id, 'lot-b');
    });
  });
}
