import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/publication.dart';
import '../state/research_controller.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/publication_card.dart';
import 'publication_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _suggestedTopics = [
    'Artificial Intelligence',
    'Software Engineering',
    'Data Science',
    'Cybersecurity',
    'Internet of Things',
    'Blockchain',
  ];

  final _queryController = TextEditingController();
  var _visibleCount = 15;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _submitSearch(String topic) {
    final query = topic.trim();
    if (query.isEmpty) {
      return;
    }

    _queryController.text = query;
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _visibleCount = 15;
    });

    context.read<ResearchController>().search(query);

    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _openPublication(Publication publication) {
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

    final allPublications = analysis?.publications ?? <Publication>[];
    final shownPublications = allPublications.take(_visibleCount).toList();

    return Column(
      children: [
        if (controller.isLoading) const LinearProgressIndicator(),
        Expanded(
          child: ListView(
            controller: widget.scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _SearchPanel(
                queryController: _queryController,
                suggestedTopics: _suggestedTopics,
                isLoading: controller.isLoading,
                onSubmit: _submitSearch,
              ),
              const SizedBox(height: 18),
              if (controller.status == ResearchStatus.error)
                _ErrorPanel(
                  message: controller.errorMessage ?? 'Unable to load data.',
                  onRetry: controller.currentTopic.isEmpty
                      ? null
                      : () => controller.refresh(),
                ),
              if (analysis == null && controller.status != ResearchStatus.error)
                const SizedBox(
                  height: 360,
                  child: EmptyState(
                    icon: Icons.manage_search_outlined,
                    title: 'Search a research topic',
                    message: 'OpenAlex publications will appear here.',
                  ),
                ),
              if (analysis != null) ...[
                _ResultHeader(
                  topic: analysis.topic,
                  total: analysis.totalPublications,
                  shown: shownPublications.length,
                ),
                const SizedBox(height: 12),
                for (final publication in shownPublications) ...[
                  PublicationCard(
                    publication: publication,
                    onTap: () => _openPublication(publication),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_visibleCount < allPublications.length) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _visibleCount = (_visibleCount + 15).clamp(
                            0,
                            allPublications.length,
                          );
                        });
                      },
                      icon: const Icon(Icons.expand_more_rounded),
                      label: Text(
                        'Load More (${allPublications.length - _visibleCount} remaining)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.queryController,
    required this.suggestedTopics,
    required this.isLoading,
    required this.onSubmit,
  });

  final TextEditingController queryController;
  final List<String> suggestedTopics;
  final bool isLoading;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: queryController,
              enabled: !isLoading,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmit,
              decoration: InputDecoration(
                labelText: 'Research topic',
                hintText: 'Machine learning, IoT, cybersecurity...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Search',
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: isLoading
                      ? null
                      : () => onSubmit(queryController.text),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < suggestedTopics.length; i++) ...[
                    ActionChip(
                      avatar: const Icon(Icons.tag, size: 13),
                      label: Text(
                        suggestedTopics[i],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      visualDensity: const VisualDensity(
                        horizontal: -2,
                        vertical: -3,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      onPressed: isLoading
                          ? null
                          : () => onSubmit(suggestedTopics[i]),
                    ),
                    if (i < suggestedTopics.length - 1)
                      const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({
    required this.topic,
    required this.total,
    required this.shown,
  });

  final String topic;
  final int total;
  final int shown;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${formatCount(total)} database results',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Showing $shown',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
