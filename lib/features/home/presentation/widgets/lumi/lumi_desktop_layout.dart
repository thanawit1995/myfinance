import 'package:flutter/material.dart';
import '../../../../../core/database/app_database.dart';
import 'budget_hero_card.dart';
import 'credit_card_card.dart';
import 'financial_overview_card.dart';
import 'lumi_tip_card.dart';
import 'portfolio_card.dart';
import 'recent_activity_card.dart';

class LumiHomeDataBundle {
  final int netWorthSatang;
  final double momChangePercent;
  final int cashFlowMonthSatang;
  final int totalIncomeSatang;
  final int totalExpenseSatang;
  final int remainingBudgetSatang;
  final int totalBudgetSatang;
  final int portfolioValueSatang;
  final double portfolioReturnPercent;
  final int creditCardCurrentDebtSatang;
  final String creditCardNextCloseText;
  final List<Transaction> recentTransactions;
  final String attentionMessage;
  final bool attentionIsWarning;

  const LumiHomeDataBundle({
    required this.netWorthSatang,
    required this.momChangePercent,
    required this.cashFlowMonthSatang,
    required this.totalIncomeSatang,
    required this.totalExpenseSatang,
    required this.remainingBudgetSatang,
    required this.totalBudgetSatang,
    required this.portfolioValueSatang,
    required this.portfolioReturnPercent,
    required this.creditCardCurrentDebtSatang,
    required this.creditCardNextCloseText,
    required this.recentTransactions,
    required this.attentionMessage,
    required this.attentionIsWarning,
  });
}

class LumiDesktopLayout extends StatelessWidget {
  final LumiHomeDataBundle data;
  final Widget headerWidget;
  final VoidCallback onNavigateToBudget;
  final VoidCallback onNavigateToMoney;
  final VoidCallback onNavigateToInvest;
  final VoidCallback onNavigateToCreditCards;
  final VoidCallback onNavigateToPlan;
  final VoidCallback onViewMonthlySummary;
  final VoidCallback onAddTransaction;

  const LumiDesktopLayout({
    super.key,
    required this.data,
    required this.headerWidget,
    required this.onNavigateToBudget,
    required this.onNavigateToMoney,
    required this.onNavigateToInvest,
    required this.onNavigateToCreditCards,
    required this.onNavigateToPlan,
    required this.onViewMonthlySummary,
    required this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopGrid = screenWidth >= 1024;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktopGrid ? 32 : 20,
            vertical: 16,
          ),
          children: [
            // 1. Personal greeting header
            headerWidget,
            const SizedBox(height: 20),

            // 2. Main content area: 2 columns on desktop, 1 column on tablet/mobile
            if (isDesktopGrid)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column (55%)
                  Expanded(
                    flex: 55,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Master Budget Hero Card
                        BudgetHeroCard(
                          remainingSatang: data.remainingBudgetSatang,
                          totalBudgetSatang: data.totalBudgetSatang,
                          totalExpenseSatang: data.totalExpenseSatang,
                          onTap: onNavigateToBudget,
                        ),
                        const SizedBox(height: 18),

                        // Lumi Tip / Advice Card
                        LumiTipCard(
                          message: data.attentionMessage,
                          isWarning: data.attentionIsWarning,
                          onTap: onNavigateToBudget,
                        ),
                        const SizedBox(height: 18),

                        // Financial Overview Card (Net Worth & Cash Flow)
                        FinancialOverviewCard(
                          netWorthSatang: data.netWorthSatang,
                          momChangePercent: data.momChangePercent,
                          cashFlowMonthSatang: data.cashFlowMonthSatang,
                          totalIncomeSatang: data.totalIncomeSatang,
                          totalExpenseSatang: data.totalExpenseSatang,
                          onViewMonthlySummary: onViewMonthlySummary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Right Column (45%)
                  Expanded(
                    flex: 45,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Portfolio Summary Card
                        PortfolioCard(
                          portfolioValueSatang: data.portfolioValueSatang,
                          returnPercent: data.portfolioReturnPercent,
                          onTap: onNavigateToInvest,
                        ),
                        const SizedBox(height: 18),

                        // Credit Card Summary Card
                        CreditCardCard(
                          currentDebtSatang: data.creditCardCurrentDebtSatang,
                          nextCloseText: data.creditCardNextCloseText,
                          onTap: onNavigateToCreditCards,
                        ),
                        const SizedBox(height: 18),

                        // Recent Activity Card
                        RecentActivityCard(
                          transactions: data.recentTransactions,
                          onViewAll: onNavigateToMoney,
                          onAddTransaction: onAddTransaction,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              // Single-column layout for mobile / tablet (< 1024px)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BudgetHeroCard(
                    remainingSatang: data.remainingBudgetSatang,
                    totalBudgetSatang: data.totalBudgetSatang,
                    totalExpenseSatang: data.totalExpenseSatang,
                    onTap: onNavigateToBudget,
                  ),
                  const SizedBox(height: 16),
                  LumiTipCard(
                    message: data.attentionMessage,
                    isWarning: data.attentionIsWarning,
                    onTap: onNavigateToBudget,
                  ),
                  const SizedBox(height: 16),
                  FinancialOverviewCard(
                    netWorthSatang: data.netWorthSatang,
                    momChangePercent: data.momChangePercent,
                    cashFlowMonthSatang: data.cashFlowMonthSatang,
                    totalIncomeSatang: data.totalIncomeSatang,
                    totalExpenseSatang: data.totalExpenseSatang,
                    onViewMonthlySummary: onViewMonthlySummary,
                  ),
                  const SizedBox(height: 16),
                  PortfolioCard(
                    portfolioValueSatang: data.portfolioValueSatang,
                    returnPercent: data.portfolioReturnPercent,
                    onTap: onNavigateToInvest,
                  ),
                  const SizedBox(height: 16),
                  CreditCardCard(
                    currentDebtSatang: data.creditCardCurrentDebtSatang,
                    nextCloseText: data.creditCardNextCloseText,
                    onTap: onNavigateToCreditCards,
                  ),
                  const SizedBox(height: 16),
                  RecentActivityCard(
                    transactions: data.recentTransactions,
                    onViewAll: onNavigateToMoney,
                    onAddTransaction: onAddTransaction,
                  ),
                ],
              ),

            const SizedBox(height: 80), // Padding for bottom navigation / FAB
          ],
        ),
      ),
    );
  }
}
