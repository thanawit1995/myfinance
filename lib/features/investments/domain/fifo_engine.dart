import 'package:decimal/decimal.dart';

class InsufficientQuantityException implements Exception {
  final String message;
  InsufficientQuantityException(this.message);

  @override
  String toString() => message;
}

class LotState {
  final String id;
  final String assetId;
  final DateTime buyDate;
  final DateTime createdAt;
  final Decimal quantity;
  Decimal remainingQuantity;
  final int costPerUnitOriginalSatang;
  final Decimal? pricePerUnitOriginal;
  final Decimal fxRate;
  final int costPerUnitThbSatang;
  final int feeThbSatang;
  final int totalCostThbSatang;
  int remainingCostThbSatang;
  String status; // open, partially_closed, closed

  LotState({
    required this.id,
    required this.assetId,
    required this.buyDate,
    required this.createdAt,
    required this.quantity,
    required this.remainingQuantity,
    required this.costPerUnitOriginalSatang,
    this.pricePerUnitOriginal,
    required this.fxRate,
    required this.costPerUnitThbSatang,
    required this.feeThbSatang,
    required this.totalCostThbSatang,
    required this.remainingCostThbSatang,
    required this.status,
  });
}

class LotConsumption {
  final String lotId;
  final Decimal quantitySold;
  final int sellPriceThbSatang;
  final int costThbSatang;
  final int feeThbSatang;
  final int priceGainLossThbSatang;
  final int fxGainLossThbSatang;
  final int realizedGainLossThbSatang;
  final Decimal sellFxRate;
  final Decimal buyFxRate;

  const LotConsumption({
    required this.lotId,
    required this.quantitySold,
    required this.sellPriceThbSatang,
    required this.costThbSatang,
    required this.feeThbSatang,
    required this.priceGainLossThbSatang,
    required this.fxGainLossThbSatang,
    required this.realizedGainLossThbSatang,
    required this.sellFxRate,
    required this.buyFxRate,
  });
}

class FifoSellResult {
  final List<LotConsumption> consumptions;
  final int totalSellPriceThbSatang;
  final int totalCostThbSatang;
  final int totalFeeThbSatang;
  final int totalPriceGainLossThbSatang;
  final int totalFxGainLossThbSatang;
  final int totalRealizedGainLossThbSatang;

  const FifoSellResult({
    required this.consumptions,
    required this.totalSellPriceThbSatang,
    required this.totalCostThbSatang,
    required this.totalFeeThbSatang,
    required this.totalPriceGainLossThbSatang,
    required this.totalFxGainLossThbSatang,
    required this.totalRealizedGainLossThbSatang,
  });
}

class FifoEngine {
  /// Sort lots deterministically by: buyDate ASC, createdAt ASC, id ASC
  static List<LotState> sortLotsForFifo(List<LotState> lots) {
    final sorted = List<LotState>.from(lots);
    sorted.sort((a, b) {
      final dateCmp = a.buyDate.compareTo(b.buyDate);
      if (dateCmp != 0) return dateCmp;
      final createdCmp = a.createdAt.compareTo(b.createdAt);
      if (createdCmp != 0) return createdCmp;
      return a.id.compareTo(b.id);
    });
    return sorted;
  }

  /// Calculates total cost THB for a newly bought lot
  static int calculateBuyTotalCostThbSatang({
    required Decimal quantity,
    required int costPerUnitOriginalSatang,
    Decimal? pricePerUnitOriginal,
    required Decimal fxRate,
    required int feeThbSatang,
  }) {
    if (pricePerUnitOriginal != null) {
      final baseCostThb = (quantity * pricePerUnitOriginal * fxRate * Decimal.fromInt(100)).round().toBigInt().toInt();
      return baseCostThb + feeThbSatang;
    }
    final baseCostThb = (quantity * Decimal.fromInt(costPerUnitOriginalSatang) * fxRate).round().toBigInt().toInt();
    return baseCostThb + feeThbSatang;
  }

  /// Process FIFO Sell across open lots
  static FifoSellResult processSell({
    required List<LotState> openLots,
    required Decimal sellQuantity,
    required int sellPriceOriginalSatang,
    Decimal? pricePerUnitOriginal,
    required Decimal sellFxRate,
    required int sellFeeThbSatang,
  }) {
    if (sellQuantity <= Decimal.zero) {
      throw ArgumentError('จำนวนที่ขายต้องมากกว่า 0');
    }

    final sortedLots = sortLotsForFifo(
      openLots.where((l) => l.status != 'closed' && l.remainingQuantity > Decimal.zero).toList(),
    );

    Decimal totalAvailable = Decimal.zero;
    for (final l in sortedLots) {
      totalAvailable += l.remainingQuantity;
    }

    if (sellQuantity > totalAvailable) {
      throw InsufficientQuantityException(
        'จำนวนที่ต้องการขาย ($sellQuantity) เกินจำนวนหน่วยคงเหลือในพอร์ต ($totalAvailable)',
      );
    }

    // Determine how much quantity is taken from each lot to compute fee pro-rata accurately
    Decimal needed = sellQuantity;
    final lotsToConsume = <Map<String, dynamic>>[];

    for (final lot in sortedLots) {
      if (needed <= Decimal.zero) break;
      final qtyFromLot = needed <= lot.remainingQuantity ? needed : lot.remainingQuantity;
      lotsToConsume.add({
        'lot': lot,
        'quantity': qtyFromLot,
      });
      needed -= qtyFromLot;
    }

    final consumptions = <LotConsumption>[];
    int accumulatedFee = 0;
    int totalSellPriceThb = 0;
    int totalCostThb = 0;
    int totalPriceGainLossThb = 0;
    int totalFxGainLossThb = 0;
    int totalRealizedGainLossThb = 0;

    final Decimal unitSellPrice = pricePerUnitOriginal ??
        (Decimal.fromInt(sellPriceOriginalSatang) * Decimal.parse('0.01'));

    for (int i = 0; i < lotsToConsume.length; i++) {
      final item = lotsToConsume[i];
      final LotState lot = item['lot'] as LotState;
      final Decimal q = item['quantity'] as Decimal;
      final isLastLot = i == lotsToConsume.length - 1;

      // 1. Fee Pro-rata by quantity
      int feeForThisLot;
      if (!isLastLot) {
        feeForThisLot = ((Decimal.fromInt(sellFeeThbSatang) * q) / sellQuantity).toDecimal(scaleOnInfinitePrecision: 10).round().toBigInt().toInt();
        accumulatedFee += feeForThisLot;
      } else {
        // Last lot receives residual fee so sum of fees matches 100%
        feeForThisLot = sellFeeThbSatang - accumulatedFee;
      }

      // 2. Cost calculation with Residual Balance on Lot Close policy
      final bool isClosingLot = q == lot.remainingQuantity;
      int costThbForThisLot;
      if (isClosingLot) {
        costThbForThisLot = lot.remainingCostThbSatang;
        lot.remainingCostThbSatang = 0;
        lot.remainingQuantity = Decimal.zero;
        lot.status = 'closed';
      } else {
        costThbForThisLot = ((Decimal.fromInt(lot.totalCostThbSatang) * q) / lot.quantity).toDecimal(scaleOnInfinitePrecision: 10).round().toBigInt().toInt();
        lot.remainingCostThbSatang -= costThbForThisLot;
        lot.remainingQuantity -= q;
        lot.status = 'partially_closed';
      }

      // 3. Sell revenue in THB
      final int sellPriceThbForLot = (unitSellPrice * q * sellFxRate * Decimal.fromInt(100)).round().toBigInt().toInt();

      // 4. Price P&L and FX P&L separation
      // Price P&L = (P_sell - P_buy) * Q * R_buy
      final Decimal buyUnitPrice = lot.pricePerUnitOriginal ??
          (Decimal.fromInt(lot.costPerUnitOriginalSatang) * Decimal.parse('0.01'));
      final priceDiffOriginal = unitSellPrice - buyUnitPrice;
      final int priceGainLossThb = (priceDiffOriginal * q * lot.fxRate * Decimal.fromInt(100)).round().toBigInt().toInt();

      // FX P&L = P_sell * Q * (R_sell - R_buy)
      final fxDiff = sellFxRate - lot.fxRate;
      final int fxGainLossThb = (unitSellPrice * q * fxDiff * Decimal.fromInt(100)).round().toBigInt().toInt();

      // Net Realized P&L = Sell revenue - Cost (which includes buy fee/residual) - Sell fee
      final realizedGainLossThb = sellPriceThbForLot - costThbForThisLot - feeForThisLot;

      final consumption = LotConsumption(
        lotId: lot.id,
        quantitySold: q,
        sellPriceThbSatang: sellPriceThbForLot,
        costThbSatang: costThbForThisLot,
        feeThbSatang: feeForThisLot,
        priceGainLossThbSatang: priceGainLossThb,
        fxGainLossThbSatang: fxGainLossThb,
        realizedGainLossThbSatang: realizedGainLossThb,
        sellFxRate: sellFxRate,
        buyFxRate: lot.fxRate,
      );

      consumptions.add(consumption);
      totalSellPriceThb += sellPriceThbForLot;
      totalCostThb += costThbForThisLot;
      totalPriceGainLossThb += priceGainLossThb;
      totalFxGainLossThb += fxGainLossThb;
      totalRealizedGainLossThb += realizedGainLossThb;
    }

    return FifoSellResult(
      consumptions: consumptions,
      totalSellPriceThbSatang: totalSellPriceThb,
      totalCostThbSatang: totalCostThb,
      totalFeeThbSatang: sellFeeThbSatang,
      totalPriceGainLossThbSatang: totalPriceGainLossThb,
      totalFxGainLossThbSatang: totalFxGainLossThb,
      totalRealizedGainLossThbSatang: totalRealizedGainLossThb,
    );
  }
}
