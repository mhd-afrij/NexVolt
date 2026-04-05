import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/distance_log.dart';
import 'package:intl/intl.dart';

class DistanceChartWidget extends StatelessWidget {
  final List<DistanceLog> logs;

  const DistanceChartWidget({
    super.key,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(
        child: Text(
          "No distance data available",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    final maxY = logs.fold<double>(0, (prev, log) => log.distance > prev ? log.distance : prev);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            // Use toolTipBgColor instead of tooltipBgColor to match the fl_chart version. Wait, fl_chart signature can vary.
            // Some recent fl_chart versions use getTooltipColor. I'll use simple tooltip properties.
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()} km\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                children: [
                   TextSpan(
                     text: DateFormat('E').format(logs[groupIndex].date),
                     style: const TextStyle(color: Colors.white70, fontSize: 12),
                   ),
                ]
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < logs.length) {
                  final date = logs[value.toInt()].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('E').format(date),
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4 == 0 ? 1 : maxY / 4,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Colors.white10,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: logs.asMap().entries.map((entry) {
          int index = entry.key;
          DistanceLog log = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: log.distance,
                color: const Color(0xFF00D1B2),
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY * 1.2,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
