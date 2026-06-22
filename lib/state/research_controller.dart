import 'package:flutter/foundation.dart';

import '../models/research_analysis.dart';
import '../services/openalex_service.dart';

enum ResearchStatus { idle, loading, loaded, error }

class ResearchController extends ChangeNotifier {
  ResearchController(this._service);

  final OpenAlexService _service;

  ResearchStatus status = ResearchStatus.idle;
  ResearchAnalysis? analysis;
  String currentTopic = '';
  String? errorMessage;

  bool get hasAnalysis => analysis != null;
  bool get isLoading => status == ResearchStatus.loading;

  Future<void> search(String topic) async {
    final normalizedTopic = topic.trim();
    if (normalizedTopic.isEmpty) {
      status = ResearchStatus.error;
      errorMessage = 'Please enter a research topic.';
      notifyListeners();
      return;
    }

    currentTopic = normalizedTopic;
    status = ResearchStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      analysis = await _service.analyzeTopic(normalizedTopic);
      status = ResearchStatus.loaded;
    } on OpenAlexException catch (error) {
      status = ResearchStatus.error;
      errorMessage = error.message;
    } on Object catch (error) {
      status = ResearchStatus.error;
      errorMessage = 'Unexpected error: $error';
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    if (currentTopic.isEmpty) {
      return;
    }
    await search(currentTopic);
  }
}
