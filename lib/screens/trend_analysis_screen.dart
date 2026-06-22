import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/publication.dart';
import '../state/research_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/publication_card.dart';
import '../widgets/ranked_list.dart';
import '../widgets/trend_chart.dart';
import 'publication_detail_screen.dart';

class TrendAnalysisScreen extends StatefulWidget {
  const TrendAnalysisScreen({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  State<TrendAnalysisScreen> createState() => _TrendAnalysisScreenState();
}

class _TrendAnalysisScreenState extends State<TrendAnalysisScreen> {
  final _trendChartKey = GlobalKey();
  final _topPapersKey = GlobalKey();
  final _topJournalsKey = GlobalKey();
  final _topAuthorsKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _openPublication(BuildContext context, Publication publication) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PublicationDetailScreen(publication: publication),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ResearchController>();
    final analysis = controller.analysis;

    if (analysis == null && controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (analysis == null) {
      return const EmptyState(
        icon: Icons.stacked_line_chart_outlined,
        title: 'No trend data',
        message: 'Search a topic to load trend analysis.',
      );
    }

    return Column(
      children: [
        if (controller.isLoading) const LinearProgressIndicator(),
        _QuickNavBar(
          onTapTrend: () => _scrollToSection(_trendChartKey),
          onTapPapers: () => _scrollToSection(_topPapersKey),
          onTapJournals: () => _scrollToSection(_topJournalsKey),
          onTapAuthors: () => _scrollToSection(_topAuthorsKey),
        ),
        const Divider(height: 1, thickness: 1),
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeader(
                  key: _trendChartKey,
                  title: 'Publication Trend',
                  subtitle: 'Recent publication volume by year',
                ),
                const SizedBox(height: 10),
                Card(
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
                    child: TrendChart(points: analysis.recentTrendByYear),
                  ),
                ),
                const SizedBox(height: 22),
                _SectionHeader(
                  key: _topPapersKey,
                  title: 'Top Influential Papers',
                  subtitle: 'Ranked by citation count',
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < analysis.topInfluential.length; i++) ...[
                  PublicationCard(
                    publication: analysis.topInfluential[i],
                    rank: i + 1,
                    onTap: () =>
                        _openPublication(context, analysis.topInfluential[i]),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 10),
                _SectionHeader(
                  key: _topJournalsKey,
                  title: 'Top Research Journals',
                  subtitle: 'Sources contributing the most articles',
                ),
                const SizedBox(height: 10),
                Card(
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: RankedList(
                      items: analysis.topJournals,
                      emptyLabel: 'No journal data available.',
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _SectionHeader(
                  key: _topAuthorsKey,
                  title: 'Top Contributing Authors',
                  subtitle: 'Authors with the highest publication counts',
                ),
                const SizedBox(height: 10),
                Card(
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: RankedList(
                      items: analysis.topAuthors,
                      emptyLabel: 'No author data available.',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _QuickNavBar extends StatelessWidget {
  const _QuickNavBar({
    required this.onTapTrend,
    required this.onTapPapers,
    required this.onTapJournals,
    required this.onTapAuthors,
  });

  final VoidCallback onTapTrend;
  final VoidCallback onTapPapers;
  final VoidCallback onTapJournals;
  final VoidCallback onTapAuthors;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _NavChip(
              icon: Icons.bar_chart_rounded,
              label: 'Trend Chart',
              color: colorScheme.primary,
              onTap: onTapTrend,
            ),
            const SizedBox(width: 8),
            _NavChip(
              icon: Icons.article_rounded,
              label: 'Top Papers',
              color: Colors.amber,
              onTap: onTapPapers,
            ),
            const SizedBox(width: 8),
            _NavChip(
              icon: Icons.menu_book_rounded,
              label: 'Top Journals',
              color: Colors.deepPurple,
              onTap: onTapJournals,
            ),
            const SizedBox(width: 8),
            _NavChip(
              icon: Icons.school_rounded,
              label: 'Top Authors',
              color: Colors.teal,
              onTap: onTapAuthors,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  const _NavChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, color: color, size: 14),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      visualDensity: const VisualDensity(horizontal: -2, vertical: -3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      onPressed: onTap,
    );
  }
}
