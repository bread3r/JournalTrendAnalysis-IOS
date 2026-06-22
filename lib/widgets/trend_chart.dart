import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/openalex_group.dart';
import '../utils/formatters.dart';

class TrendChart extends StatelessWidget {
  const TrendChart({super.key, required this.points});

  final List<OpenAlexGroup> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No trend data available.')),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final maxCount = points
        .map((point) => point.count)
        .fold<int>(0, (best, current) => current > best ? current : best);
    final interval = points.length <= 8 ? 1 : (points.length / 5).ceil();

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          maxY: maxCount == 0 ? 1 : maxCount * 1.15,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => colorScheme.inverseSurface.withValues(alpha: 0.95),
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final point = points[group.x.toInt()];
                return BarTooltipItem(
                  'Year: ${point.name}\n',
                  TextStyle(
                    color: colorScheme.onInverseSurface.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: '${formatCount(point.count)} papers',
                      style: TextStyle(
                        color: colorScheme.onInverseSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || (value - meta.max).abs() < 1e-3) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Text(
                      formatCompactCount(value),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  if (index % interval != 0 && index != points.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Text(
                      points[index].name,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: points[i].count.toDouble(),
                    width: 12,
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.7),
                        colorScheme.secondary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
