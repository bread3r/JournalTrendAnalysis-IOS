import 'package:flutter/material.dart';

import '../models/openalex_group.dart';
import '../utils/formatters.dart';

class RankedList extends StatelessWidget {
  const RankedList({super.key, required this.items, required this.emptyLabel});

  final List<OpenAlexGroup> items;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        emptyLabel,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    final maxCount = items
        .map((item) => item.count)
        .fold<int>(0, (best, current) => current > best ? current : best);

    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _RankedItem(rank: i + 1, item: items[i], maxCount: maxCount),
          if (i < items.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _RankedItem extends StatelessWidget {
  const _RankedItem({
    required this.rank,
    required this.item,
    required this.maxCount,
  });

  final int rank;
  final OpenAlexGroup item;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = maxCount == 0 ? 0.0 : item.count / maxCount;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Text(
            '#$rank',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatCompactCount(item.count),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
