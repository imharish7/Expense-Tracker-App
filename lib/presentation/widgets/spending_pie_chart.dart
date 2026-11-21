import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/category_item.dart';

class SpendingPieChart extends StatefulWidget {
  final Map<String, double> categoryExpenses;
  final String currencySymbol;

  const SpendingPieChart({
    super.key,
    required this.categoryExpenses,
    required this.currencySymbol,
  });

  @override
  State<SpendingPieChart> createState() => _SpendingPieChartState();
}

class _SpendingPieChartState extends State<SpendingPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    if (widget.categoryExpenses.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: Text(
          'No expense data recorded yet for this period.',
          style: AppTypography.bodyMedium(textMuted),
        ),
      );
    }

    final entries = widget.categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalSpent = entries.fold(0.0, (acc, e) => acc + e.value);

    // Selected item details
    final selectedCategory = (_touchedIndex >= 0 && _touchedIndex < entries.length)
        ? CategoryItem.findById(entries[_touchedIndex].key)
        : null;
    final selectedAmount = (_touchedIndex >= 0 && _touchedIndex < entries.length)
        ? entries[_touchedIndex].value
        : totalSpent;

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 4,
                  centerSpaceRadius: 52,
                  sections: List.generate(entries.length, (i) {
                    final isTouched = i == _touchedIndex;
                    final category = CategoryItem.findById(entries[i].key);
                    final radius = isTouched ? 48.0 : 40.0;

                    return PieChartSectionData(
                      color: category.color,
                      value: entries[i].value,
                      showTitle: false,
                      radius: radius,
                    );
                  }),
                ),
              ),

              // Center label (Dynamic on touch)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedCategory?.name ?? 'TOTAL EXPENSES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(
                      selectedAmount,
                      currencySymbol: widget.currencySymbol,
                      compact: true,
                    ),
                    style: AppTypography.currency(
                      textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (selectedCategory != null && totalSpent > 0)
                    Text(
                      '${((selectedAmount / totalSpent) * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: selectedCategory.color,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Legend chips (Top 4 categories)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(
            entries.length > 5 ? 5 : entries.length,
            (index) {
              final cat = CategoryItem.findById(entries[index].key);
              final pct = totalSpent > 0
                  ? ((entries[index].value / totalSpent) * 100).toStringAsFixed(0)
                  : '0';
              final isHighlighted = index == _touchedIndex;

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    _touchedIndex = _touchedIndex == index ? -1 : index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? cat.color.withAlpha(40)
                        : (isDark ? AppColors.darkSurface : AppColors.lightSurfaceElevated),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isHighlighted ? cat.color : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: isHighlighted ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cat.color,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${cat.name} ($pct%)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                          color: isHighlighted ? cat.color : textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
