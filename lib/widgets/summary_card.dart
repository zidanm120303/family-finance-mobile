import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/helpers/currency_helper.dart';
import 'app_card.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.softColor,
    this.compact = false,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final Color? softColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(compact ? 16 : 20),
      child: Row(
        children: [
          Container(
            width: compact ? 42 : 50,
            height: compact ? 42 : 50,
            decoration: BoxDecoration(
              color: softColor ?? color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    CurrencyHelper.format(amount),
                    style: TextStyle(
                      color: color == AppColors.danger
                          ? AppColors.danger
                          : AppColors.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: compact ? 17 : 21,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
