import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/openalex_group.dart';
import '../models/publication.dart';
import '../state/research_controller.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ResearchController>();
    final analysis = controller.analysis;

    if (analysis == null && controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (analysis == null) {
      return const EmptyState(
        icon: Icons.dashboard_outlined,
        title: 'No dashboard data',
        message: 'Search a topic to load research metrics.',
      );
    }

    final activeYear = analysis.mostActiveYear;
    final topJournal = analysis.topJournal;
    final topAuthor = analysis.topAuthor;
    final mostInfluential = analysis.mostInfluentialPaper;

    final activeYearLabel = activeYear == null
        ? 'N/A'
        : '${activeYear.name} (${formatCompactCount(activeYear.count)})';

    return Column(
      children: [
        if (controller.isLoading) const LinearProgressIndicator(),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _HeroBanner(topic: analysis.topic),
              const SizedBox(height: 20),
              _QuickMetricsGrid(
                totalPublications: analysis.totalPublications,
                averageCitations: analysis.averageCitationCount,
                activeYearLabel: activeYearLabel,
              ),
              const SizedBox(height: 20),
              _InfluentialPaperCard(paper: mostInfluential),
              const SizedBox(height: 20),
              _ContributorCards(topJournal: topJournal, topAuthor: topAuthor),
              const SizedBox(height: 20),
              _SnapshotCard(
                loadedPublications: analysis.publications.length,
                influentialRanked: analysis.topInfluential.length,
                trendYears: analysis.trendByYear.length,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.topic});

  final String topic;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.85),
            colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'RESEARCH TREND INSIGHTS',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            topic,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore publication patterns, academic sources, and citation impact from OpenAlex.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickMetricsGrid extends StatelessWidget {
  const _QuickMetricsGrid({
    required this.totalPublications,
    required this.averageCitations,
    required this.activeYearLabel,
  });

  final int totalPublications;
  final double averageCitations;
  final String activeYearLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 3 : 1;

        final children = [
          _CompactMetricCard(
            icon: Icons.library_books_rounded,
            label: 'Total Publications',
            value: formatCount(totalPublications),
            color: colorScheme.primary,
          ),
          _CompactMetricCard(
            icon: Icons.auto_graph_rounded,
            label: 'Average Citations',
            value: averageCitations.toStringAsFixed(1),
            color: colorScheme.secondary,
          ),
          _CompactMetricCard(
            icon: Icons.calendar_today_rounded,
            label: 'Peak Year',
            value: activeYearLabel,
            color: colorScheme.tertiary,
          ),
        ];

        if (columns == 3) {
          return Row(
            children: children
                .map(
                  (card) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: card,
                    ),
                  ),
                )
                .toList(),
          );
        } else {
          return Column(
            children: children
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: card,
                  ),
                )
                .toList(),
          );
        }
      },
    );
  }
}

class _CompactMetricCard extends StatelessWidget {
  const _CompactMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1.5,
      shadowColor: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfluentialPaperCard extends StatelessWidget {
  const _InfluentialPaperCard({required this.paper});

  final Publication? paper;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (paper == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shadowColor: Colors.amber.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.amber.shade700, width: 1.8),
      ),
      color: colorScheme.surface,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(
                Icons.star_rounded,
                size: 90,
                color: Colors.amber.withValues(alpha: 0.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.workspace_premium_rounded,
                              color: Colors.amber,
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'MOST INFLUENTIAL PAPER',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.amber[900] ?? Colors.amber,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${formatCount(paper!.citationCount)} Citations',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    paper!.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (paper!.authors.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.people_alt_rounded,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            paper!.authors.join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${paper!.journalName} • ${paper!.yearLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContributorCards extends StatelessWidget {
  const _ContributorCards({required this.topJournal, required this.topAuthor});

  final OpenAlexGroup? topJournal;
  final OpenAlexGroup? topAuthor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 2 : 1;

        final journalCard = _ContributorCard(
          icon: Icons.stars_rounded,
          iconColor: Colors.deepPurple,
          title: 'TOP JOURNAL',
          name: topJournal?.name ?? 'N/A',
          subtitle: topJournal != null
              ? '${formatCount(topJournal!.count)} publications'
              : 'No data',
        );

        final authorCard = _ContributorCard(
          icon: Icons.school_rounded,
          iconColor: Colors.teal,
          title: 'TOP AUTHOR',
          name: topAuthor?.name ?? 'N/A',
          subtitle: topAuthor != null
              ? '${formatCount(topAuthor!.count)} publications'
              : 'No data',
        );

        if (columns == 2) {
          return Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: journalCard,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: authorCard,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [journalCard, const SizedBox(height: 12), authorCard],
          );
        }
      },
    );
  }
}

class _ContributorCard extends StatelessWidget {
  const _ContributorCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.name,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1.5,
      shadowColor: iconColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: iconColor.withValues(alpha: 0.35), width: 1.5),
      ),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  const _SnapshotCard({
    required this.loadedPublications,
    required this.influentialRanked,
    required this.trendYears,
  });

  final int loadedPublications;
  final int influentialRanked;
  final int trendYears;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dns_rounded, color: colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Database Coverage',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SnapshotItem(
              icon: Icons.cloud_download_rounded,
              iconColor: Colors.blue,
              label: 'Loaded Publications',
              value: formatCount(loadedPublications),
            ),
            const Divider(height: 16),
            _SnapshotItem(
              icon: Icons.star_border_rounded,
              iconColor: Colors.amber,
              label: 'Ranked Influential Papers',
              value: formatCount(influentialRanked),
            ),
            const Divider(height: 16),
            _SnapshotItem(
              icon: Icons.date_range_rounded,
              iconColor: Colors.green,
              label: 'Trend analysis span',
              value: '$trendYears years',
            ),
          ],
        ),
      ),
    );
  }
}

class _SnapshotItem extends StatelessWidget {
  const _SnapshotItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
