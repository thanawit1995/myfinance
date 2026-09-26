import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/features/import/domain/notion_invest_parser.dart';

void main() {
  group('NotionInvestParser Tests', () {
    test('parses standard Invest-Stocks rows accurately', () {
      final rawRows = [
        [
          'Day',
          'Date',
          'Invested',
          'Rollup',
          'Share price',
          'Shares',
          'Stock',
          'THB invested',
          'Text',
          'USDTHB',
          'Monthly Overview'
        ],
        [
          '@24/06/2024 ',
          'June 24, 2024',
          '\$271.44',
          '32.37',
          '\$53.15',
          '5.1070555',
          'O (https://www.notion.so/O-abc)',
          '8786.5128',
          'THB',
          '',
          ''
        ],
        [
          '@25/06/2024 ',
          'June 25, 2024',
          '\$100.00',
          '32.50',
          '\$50.00',
          '2.0000000',
          'NVDA',
          '3250.00',
          'USD',
          '',
          ''
        ],
        [
          '@26/06/2024 ',
          'June 26, 2024',
          '\$50.00',
          '32.50',
          '\$25.00',
          '2.0000000',
          'JEPQ',
          '1625.00',
          'FCD',
          '',
          ''
        ],
        [
          '@27/06/2024 ',
          'June 27, 2024',
          '\$10.00',
          '32.50',
          '\$10.00',
          '1.0000000',
          'O',
          '325.00',
          'ปันผล',
          '',
          ''
        ],
        [
          '@28/06/2024 ',
          'June 28, 2024',
          '\$20.00',
          '32.50',
          '\$20.00',
          '1.0000000',
          'QQQM',
          '650.00',
          'THB + ปันผล',
          '',
          ''
        ]
      ];

      final results = NotionInvestParser.parseRows(rawRows);

      expect(results.length, 5);

      // Row 1: O
      expect(results[0].ticker, 'O');
      expect(results[0].buyDate, DateTime(2024, 6, 24));
      expect(results[0].amountUsdSatang, 27144);
      expect(results[0].amountThbSatang, 913396);
      expect(results[0].fxRate, Decimal.parse('33.650000'));
      expect(results[0].quantity, Decimal.parse('5.1070555'));
      expect(results[0].paymentType, PaymentType.thb);

      // Row 2: NVDA
      expect(results[1].ticker, 'NVDA');
      expect(results[1].buyDate, DateTime(2024, 6, 25));
      expect(results[1].amountUsdSatang, 10000);
      expect(results[1].paymentType, PaymentType.usd);

      // Row 3: JEPQ
      expect(results[2].ticker, 'JEPQ');
      expect(results[2].paymentType, PaymentType.fcd);

      // Row 4: Dividend
      expect(results[3].ticker, 'O');
      expect(results[3].paymentType, PaymentType.dividend);

      // Row 5: THB + ปันผล
      expect(results[4].ticker, 'QQQM');
      expect(results[4].paymentType, PaymentType.thb);
    });

    test('ignores header repetitions and blank rows', () {
      final rawRows = [
        ['Day', 'Date', 'Invested', 'Rollup', 'Share price', 'Shares', 'Stock', 'THB invested', 'Text'],
        ['', '', '', '', '', '', '', '', ''],
        ['@01/01/2024', 'January 1, 2024', '\$50', '32.0', '\$50', '1.0', 'MSFT', '1600', 'USD'],
      ];

      final results = NotionInvestParser.parseRows(rawRows);
      expect(results.length, 1);
      expect(results[0].ticker, 'MSFT');
    });
  });
}
