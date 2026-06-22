import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:journal_trend_analyzer/main.dart';
import 'package:journal_trend_analyzer/services/openalex_service.dart';
import 'package:journal_trend_analyzer/state/research_controller.dart';

void main() {
  testWidgets('renders the journal trend analyzer shell', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ResearchController(OpenAlexService()),
        child: const JournalTrendAnalyzerApp(),
      ),
    );

    expect(find.text('Journal Trend Analyzer'), findsOneWidget);
    expect(find.text('Research topic'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Trends'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
