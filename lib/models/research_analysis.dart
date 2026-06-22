import 'dart:math';

import 'openalex_group.dart';
import 'publication.dart';

class ResearchAnalysis {
  const ResearchAnalysis({
    required this.topic,
    required this.totalPublications,
    required this.publications,
    required this.topInfluential,
    required this.trendByYear,
    required this.topJournals,
    required this.topAuthors,
  });

  final String topic;
  final int totalPublications;
  final List<Publication> publications;
  final List<Publication> topInfluential;
  final List<OpenAlexGroup> trendByYear;
  final List<OpenAlexGroup> topJournals;
  final List<OpenAlexGroup> topAuthors;

  double get averageCitationCount {
    if (publications.isEmpty) {
      return 0;
    }
    final total = publications.fold<int>(
      0,
      (sum, publication) => sum + publication.citationCount,
    );
    return total / publications.length;
  }

  OpenAlexGroup? get mostActiveYear => _maxGroup(trendByYear);

  OpenAlexGroup? get topJournal =>
      topJournals.isEmpty ? null : topJournals.first;

  OpenAlexGroup? get topAuthor => topAuthors.isEmpty ? null : topAuthors.first;

  Publication? get mostInfluentialPaper {
    if (topInfluential.isNotEmpty) {
      return topInfluential.first;
    }
    if (publications.isEmpty) {
      return null;
    }

    return publications.reduce(
      (best, current) =>
          current.citationCount > best.citationCount ? current : best,
    );
  }

  List<OpenAlexGroup> get recentTrendByYear {
    if (trendByYear.length <= 20) {
      return trendByYear;
    }
    return trendByYear.sublist(max(0, trendByYear.length - 20));
  }

  static OpenAlexGroup? _maxGroup(List<OpenAlexGroup> groups) {
    if (groups.isEmpty) {
      return null;
    }
    return groups.reduce((best, current) {
      if (current.count > best.count) {
        return current;
      }
      return best;
    });
  }
}
